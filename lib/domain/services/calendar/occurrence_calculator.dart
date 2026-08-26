import 'package:timezone/timezone.dart' as tz;
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';

class OccurrenceCalculator {
  List<DateTime> calculatePendingOccurrences(
    CalendarAutomationRule rule,
    List<CalendarOccurrenceRun> pastRuns,
    int windowSize,
  ) {
    if (windowSize <= 0) return const [];

    final nowUtc = DateTime.now().toUtc();
    final maxFutureLimitUtc = nowUtc.add(const Duration(days: 365));
    final pastRunUtcTimes = _extractPastRunUtcTimes(pastRuns);

    final location = _resolveLocation(rule.schedule.timezoneIana);
    final (hour, minute) = _parseStartTime(rule.schedule.startTimeOfDay);

    final upcomingHorizon = <DateTime>[];
    var dateCursor = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

    while (dateCursor.isBefore(maxFutureLimitUtc) && upcomingHorizon.length < windowSize) {
      if (_isWithinScheduleRange(rule.schedule, dateCursor) && _matchesRecurrence(rule.recurrence, dateCursor)) {
        final candidateUtc = _computeUtcOccurrence(
          date: dateCursor,
          location: location,
          hour: hour,
          minute: minute,
          nowUtc: nowUtc,
          maxFutureLimitUtc: maxFutureLimitUtc,
          rule: rule,
        );

        if (candidateUtc != null) {
          upcomingHorizon.add(candidateUtc);
        }
      }

      dateCursor = dateCursor.add(const Duration(days: 1));
    }

    return upcomingHorizon
        .where((occurrenceUtc) => !pastRunUtcTimes.contains(occurrenceUtc))
        .toList();
  }

  (int, int) _parseStartTime(String startTimeOfDay) {
    final parts = startTimeOfDay.split(':');
    if (parts.length != 2) return (0, 0);
    return (int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
  }

  bool _isWithinScheduleRange(TimezoneSchedule schedule, DateTime date) {
    if (schedule.startDate != null) {
      final startUtc = DateTime.utc(
        schedule.startDate!.year,
        schedule.startDate!.month,
        schedule.startDate!.day,
      );
      if (date.isBefore(startUtc)) return false;
    }

    if (schedule.endDate != null) {
      final endUtc = DateTime.utc(
        schedule.endDate!.year,
        schedule.endDate!.month,
        schedule.endDate!.day,
        23, 59, 59,
      );
      if (date.isAfter(endUtc)) return false;
    }

    return true;
  }

  Set<DateTime> _extractPastRunUtcTimes(List<CalendarOccurrenceRun> pastRuns) {
    return pastRuns
        .map((run) => run.calculatedOccurrenceUtc.toUtc())
        .toSet();
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
    required DateTime maxFutureLimitUtc,
    required CalendarAutomationRule rule,
  }) {
    final scheduledLocal = tz.TZDateTime(location, date.year, date.month, date.day, hour, minute);
    final candidateUtc = scheduledLocal.toUtc();

    if (candidateUtc.isBefore(nowUtc) || candidateUtc.isAfter(maxFutureLimitUtc)) {
      return null;
    }

    final exception = rule.getExceptionFor(date);
    if (exception != null && exception.isCancelled) {
      return null;
    }

    if (exception == null || exception.rescheduledTime == null) {
      return candidateUtc;
    }

    return _applyExceptionRescheduling(
      exception: exception,
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