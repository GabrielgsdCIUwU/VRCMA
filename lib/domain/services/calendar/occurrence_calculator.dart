import 'package:collection/collection.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:vrcma/domain/entities/calendar/enums/planned_occurrence_status.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/calendar/planned_occurrence.dart';
import 'package:vrcma/domain/entities/calendar/remote_calendar_event.dart';

/// Pure domain service that computes upcoming calendar slots for an automation rule.
///
/// Combines recurrence rules, IANA timezone conversions, date exceptions, local
/// execution history, and existing remote VRChat events to prevent duplicate publishing.
class OccurrenceCalculator {
  static const int _maxLookaheadDays = 365;
  static const int _runMatchToleranceSeconds = 60;
  static const int _remoteMatchToleranceMinutes = 15;

  /// Plans up to [visibleSlotLimit] active future slots for [rule].
  ///
  /// When [includeCancelled] is true, skipped dates are included in the returned
  /// list without consuming active slot capacity (useful for UI previews).
  List<PlannedOccurrence> planUpcomingOccurrences({
    required CalendarAutomationRule rule,
    required List<CalendarOccurrenceRun> pastRuns,
    required int visibleSlotLimit,
    List<RemoteCalendarEvent> remoteEvents = const [],
    DateTime? referenceNowUtc,
    bool includeCancelled = false,
  }) {
    if (visibleSlotLimit <= 0) return const [];
    if (_isCompletedOnceRule(rule, pastRuns)) return const [];

    final nowUtc = (referenceNowUtc ?? DateTime.now()).toUtc();
    final location = _resolveLocation(rule.schedule.timezoneIana);
    final bounds = _ScheduleBounds.fromRule(rule, nowUtc, location);

    return _scanDays(
      rule: rule,
      pastRuns: pastRuns,
      remoteEvents: remoteEvents,
      bounds: bounds,
      location: location,
      visibleSlotLimit: visibleSlotLimit,
      includeCancelled: includeCancelled,
    );
  }

  List<PlannedOccurrence> _scanDays({
    required CalendarAutomationRule rule,
    required List<CalendarOccurrenceRun> pastRuns,
    required List<RemoteCalendarEvent> remoteEvents,
    required _ScheduleBounds bounds,
    required tz.Location location,
    required int visibleSlotLimit,
    required bool includeCancelled,
  }) {
    final planned = <PlannedOccurrence>[];
    int occupiedSlots = 0;

    for (int offset = 0; offset <= _maxLookaheadDays; offset++) {
      if (occupiedSlots >= visibleSlotLimit) break;

      final candidateDay = bounds.firstDay.add(Duration(days: offset));
      if (bounds.isAfterEnd(candidateDay)) break;

      final outcome = _evaluateDay(
        rule: rule,
        candidateDay: candidateDay,
        bounds: bounds,
        location: location,
        pastRuns: pastRuns,
        remoteEvents: remoteEvents,
        includeCancelled: includeCancelled,
      );

      if (outcome == null) continue;

      planned.add(outcome);
      if (outcome.status != PlannedOccurrenceStatus.cancelledByException) {
        occupiedSlots++;
      }
      if (rule.recurrence.type == RecurrenceType.once) break;
    }

    return planned;
  }

  PlannedOccurrence? _evaluateDay({
    required CalendarAutomationRule rule,
    required DateTime candidateDay,
    required _ScheduleBounds bounds,
    required tz.Location location,
    required List<CalendarOccurrenceRun> pastRuns,
    required List<RemoteCalendarEvent> remoteEvents,
    required bool includeCancelled,
  }) {
    if (!_matchesRecurrence(rule, candidateDay, bounds.ruleStartDay)) {
      return null;
    }

    final exception = rule.getExceptionFor(candidateDay);
    final startUtc = _computeCandidateUtc(rule, candidateDay, location, exception);

    if (bounds.isOutsideUtcWindow(startUtc)) return null;

    if (exception != null && exception.isCancelled) {
      return includeCancelled
          ? PlannedOccurrence(
        startUtc: startUtc,
        status: PlannedOccurrenceStatus.cancelledByException,
      )
          : null;
    }

    return _resolveSlotStatus(
      rule: rule,
      startUtc: startUtc,
      pastRuns: pastRuns,
      remoteEvents: remoteEvents,
      titleOverride: exception?.titleOverride,
    );
  }

  PlannedOccurrence _resolveSlotStatus({
    required CalendarAutomationRule rule,
    required DateTime startUtc,
    required List<CalendarOccurrenceRun> pastRuns,
    required List<RemoteCalendarEvent> remoteEvents,
    String? titleOverride,
  }) {
    final matchedRun = _findMatchingRun(pastRuns, startUtc);
    if (matchedRun != null) {
      return PlannedOccurrence(
        startUtc: startUtc,
        status: PlannedOccurrenceStatus.alreadyPublished,
        existingRemoteEventId: matchedRun.createdVrcEventId,
      );
    }

    final matchedRemote = _findMatchingRemoteEvent(rule, remoteEvents, startUtc);
    if (matchedRemote != null) {
      return PlannedOccurrence(
        startUtc: startUtc,
        status: PlannedOccurrenceStatus.alreadyPublished,
        existingRemoteEventId: matchedRemote.id,
      );
    }

    return PlannedOccurrence(
      startUtc: startUtc,
      status: PlannedOccurrenceStatus.pendingPublish,
      titleOverride: titleOverride,
    );
  }

  bool _isCompletedOnceRule(
      CalendarAutomationRule rule,
      List<CalendarOccurrenceRun> pastRuns,
      ) {
    return rule.recurrence.type == RecurrenceType.once && pastRuns.isNotEmpty;
  }

  tz.Location _resolveLocation(String timezoneIana) {
    try {
      return tz.getLocation(timezoneIana);
    } catch (_) {
      return tz.UTC;
    }
  }

  DateTime _computeCandidateUtc(
      CalendarAutomationRule rule,
      DateTime localDay,
      tz.Location location,
      dynamic exception,
      ) {
    final targetTime = exception?.rescheduledTime ?? rule.schedule.startTime;
    final scheduledLocal = tz.TZDateTime(
      location,
      localDay.year,
      localDay.month,
      localDay.day,
      targetTime.hour,
      targetTime.minute,
    );
    return scheduledLocal.toUtc();
  }

  bool _matchesRecurrence(
      CalendarAutomationRule rule,
      DateTime localDay,
      DateTime? ruleStartDay,
      ) {
    switch (rule.recurrence.type) {
      case RecurrenceType.once:
        return ruleStartDay == null || localDay == ruleStartDay;
      case RecurrenceType.daily:
        return true;
      case RecurrenceType.weekly:
        return rule.recurrence.daysOfWeek.isEmpty ||
            rule.recurrence.daysOfWeek.contains(localDay.weekday);
      case RecurrenceType.monthly:
        return rule.recurrence.daysOfMonth.isEmpty ||
            rule.recurrence.daysOfMonth.contains(localDay.day);
    }
  }

  CalendarOccurrenceRun? _findMatchingRun(
      List<CalendarOccurrenceRun> pastRuns,
      DateTime candidateUtc,
      ) {
    return pastRuns.firstWhereOrNull((run) {
      final delta = run.calculatedOccurrenceUtc.toUtc().difference(candidateUtc).abs();
      return delta.inSeconds <= _runMatchToleranceSeconds;
    });
  }

  RemoteCalendarEvent? _findMatchingRemoteEvent(
      CalendarAutomationRule rule,
      List<RemoteCalendarEvent> remoteEvents,
      DateTime candidateUtc,
      ) {
    final basePrefix = _extractStaticTitlePrefix(rule.titleTemplate);

    return remoteEvents.firstWhereOrNull((event) {
      final delta = event.startsAtUtc.toUtc().difference(candidateUtc).abs();
      if (delta.inMinutes > _remoteMatchToleranceMinutes) return false;
      if (basePrefix.isEmpty) return true;

      return event.title.toLowerCase().contains(basePrefix.toLowerCase());
    });
  }

  String _extractStaticTitlePrefix(String template) {
    return template.split('{{incremental}}').first.trim();
  }
}

/// Holds normalized local day bounds and UTC limits for a single evaluation pass.
class _ScheduleBounds {
  final DateTime firstDay;
  final DateTime? ruleStartDay;
  final DateTime? ruleEndDay;
  final DateTime nowUtc;
  final DateTime maxFutureUtc;

  const _ScheduleBounds({
    required this.firstDay,
    required this.ruleStartDay,
    required this.ruleEndDay,
    required this.nowUtc,
    required this.maxFutureUtc,
  });

  factory _ScheduleBounds.fromRule(
      CalendarAutomationRule rule,
      DateTime nowUtc,
      tz.Location location,
      ) {
    final nowLocal = tz.TZDateTime.from(nowUtc, location);
    final todayLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final startDay = _toDateOnly(rule.schedule.startDate);
    final endDay = _toDateOnly(rule.schedule.endDate);
    final firstDay =
    (startDay != null && startDay.isAfter(todayLocal)) ? startDay : todayLocal;

    return _ScheduleBounds(
      firstDay: firstDay,
      ruleStartDay: startDay,
      ruleEndDay: endDay,
      nowUtc: nowUtc,
      maxFutureUtc: nowUtc.add(const Duration(days: 365)),
    );
  }

  bool isAfterEnd(DateTime day) {
    return ruleEndDay != null && day.isAfter(ruleEndDay!);
  }

  bool isOutsideUtcWindow(DateTime candidateUtc) {
    return candidateUtc.isBefore(nowUtc) || candidateUtc.isAfter(maxFutureUtc);
  }

  static DateTime? _toDateOnly(DateTime? date) {
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }
}