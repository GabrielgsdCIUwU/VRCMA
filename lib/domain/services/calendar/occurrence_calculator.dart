import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';

/// Evaluate rules and exceptions to generate upcoming event runs.
class OccurrenceCalculator {
  /// Calculates pending occurrences in UTC.
  List<DateTime> calculatePendingOccurrences(
    CalendarAutomationRule rule,
    List<CalendarOccurrenceRun> pastRuns,
    int countLimit,
  ) {
    final nowUtc = DateTime.now().toUtc();
    final maxFutureLimitUtc = nowUtc.add(const Duration(days: 365));
    final pendingOccurrences = <DateTime>[];

    final pastRunUtcTimes = _extractPastRunUtcTimes(pastRuns);

    final timeParts = rule.schedule.startTimeOfDay.split(':');
    if (timeParts.length != 2) return [];

    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final location = _resolveLocation(rule.schedule.timezoneIana);

    var dateCursor = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

    while (dateCursor.isBefore(maxFutureLimitUtc) && pendingOccurrences.length < countLimit) {
      if (_matchesRecurrence(rule.recurrence, dateCursor)) {
        final candidateUtc = _computeUtcOccurrence(
          date: dateCursor,
          location: location,
          hour: hour,
          minute: minute,
          nowUtc: nowUtc,
          maxFuturelimitUtc: maxFutureLimitUtc,
          rule: rule,
        );

        if (candidateUtc != null && !pastRunUtcTimes.contains(candidateUtc)) {
          pendingOccurrences.add(candidateUtc);
        }
      }

      dateCursor = dateCursor.add(const Duration(days: 1));
    }

    return pendingOccurrences;
  }

  Set<DateTime> _extractPastRunUtcTimes(List<CalendarOccurrenceRun> pastRuns) {
    return pastRuns
      .map((run) => run.calculatedOccurrenceUtc.toUtc()).toSet();
  }

  tz.Location _resolveLocation(String timezoneIana) {
    try {
      return tz.getLocation(timezoneIana);
    } catch (_) {
      return tz.UTC;
    }
  }

  bool _matchesRecurrence(RecurrencePattern recurrence, DateTime date) {
    switch (recurrence.type) {
      case RecurrenceType.once:
        return recurrence.daysOfMonth.isEmpty || recurrence.daysOfMonth.contains(date.day);
      
      case RecurrenceType.daily:
        return true;
      
      case RecurrenceType.weekly:
        return recurrence.daysOfWeek.isEmpty || recurrence.daysOfWeek.contains(date.weekday);
      
      case RecurrenceType.monthly:
        return recurrence.daysOfMonth.isEmpty || recurrence.daysOfMonth.contains(date.day);
    }
  }

  /// Computes the exact UTC occurrence for a candidate day, considering exceptions and limits.
  DateTime? _computeUtcOccurrence({
    required DateTime date,
    required tz.Location location,
    required int hour,
    required int minute,
    required DateTime nowUtc,
    required DateTime maxFuturelimitUtc,
    required CalendarAutomationRule rule,
  }) {
    final scheduledLocal = tz.TZDateTime(location, date.year, date.month, date.day, hour, minute);
    final candidateUtc = scheduledLocal.toUtc();

    if (candidateUtc.isBefore(nowUtc) || candidateUtc.isAfter(maxFuturelimitUtc)) {
      return null;
    }

    final dateToExclude = rule.getExceptionFor(date);
    if (dateToExclude != null && dateToExclude.isCancelled) {
      return null;
    }

    if (dateToExclude == null || dateToExclude.rescheduledTime == null) {
      return candidateUtc;
    }

    return _applyExceptionRescheduling(
      exception: dateToExclude,
      location: location,
      date: date,
      defaultHour: hour,
      defaultMinute: minute,
    );
  }

  DateTime _applyExceptionRescheduling({
    required CalendarException exception,
    required tz.Location location,
    required DateTime date,
    required int defaultHour,
    required int defaultMinute,
  }) {
    final timeParts = exception.rescheduledTime!.split(':');
    if (timeParts.length != 2) {
      return tz.TZDateTime(location, date.year, date.month, date.day, defaultHour, defaultMinute).toUtc();
    }

    final reschedHour = int.tryParse(timeParts[0]) ?? defaultHour;
    final reschedMinute = int.tryParse(timeParts[1]) ?? defaultMinute;

    return tz.TZDateTime(location, date.year, date.month, date.day, reschedHour, reschedMinute).toUtc();
  }
}