import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/services/calendar/occurrence_calculator.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('OccurrenceCalculator Engine', () {
    final calculator = OccurrenceCalculator();

    CalendarAutomationRule createDummyRule(RecurrenceType type, List<int> daysOfWeek, List<CalendarException> exceptions) {
      return CalendarAutomationRule(
        name: 'Test Rule',
        groupId: 'grp_123',
        titleTemplate: 'Test Event',
        category: GroupEventCategory.other,
        accessType: GroupEventAccessType.public,
        schedule: TimezoneSchedule(startTimeOfDay: '20:00', durationMinutes: 60, timezoneIana: 'UTC'),
        recurrence: RecurrencePattern(type: type, daysOfWeek: daysOfWeek),
        incrementalConfig: IncrementalConfig(isEnabled: false),
        exceptions: exceptions,
      );
    }

    test('should calculate daily occurrences correctly enforcing the limit', () {
      final rule = createDummyRule(RecurrenceType.daily, [], []);

      final occurrences = calculator.calculatePendingOccurrences(rule, [], 3);

      expect(occurrences.length, 3);

      final diff1 = occurrences[1].difference(occurrences[0]).inDays;
      final diff2 = occurrences[2].difference(occurrences[1]).inDays;
      expect(diff1, 1);
      expect(diff2, 1);
    });

    test('should calculate weekly occurrences strictly on the designated weekday', () {
      final friday = 5;
      final rule = createDummyRule(RecurrenceType.weekly, [friday], []);
      
      final occurrences = calculator.calculatePendingOccurrences(rule, [], 2);

      expect(occurrences.length, 2);
      expect(occurrences[0].weekday, DateTime.friday);
      expect(occurrences[1].weekday, DateTime.friday);
      expect(occurrences[1].difference(occurrences[0]).inDays, 7);
    });

    test('should exclude occurences matching a cancellation exception', () {
      final rule = createDummyRule(RecurrenceType.daily, [], [
        CalendarException(
          exceptionDate: DateTime.now().toUtc().add(const Duration(days: 1)),
          isCancelled: true,
        )
      ]);

      final occurrences = calculator.calculatePendingOccurrences(rule, [], 3);

      expect(occurrences.length, 3);
      final diff1 = occurrences[1].difference(occurrences[0]).inDays;
      expect(diff1, 2);
    });

    test('should ignore occurrences that were already published (pastRuns)', () {
      final rule = createDummyRule(RecurrenceType.daily, [], []);

      final firstBatch = calculator.calculatePendingOccurrences(rule, [], 1);

      final mockPastRuns = firstBatch.map((dt) => 
        CalendarOccurrenceRun(
          calculatedOccurrenceUtc: dt,
          createdVrcEventId: 'evt_dummy',
          publishedAt: DateTime.now().toUtc(),
        )
      ).toList();

      final secondBatch = calculator.calculatePendingOccurrences(rule, mockPastRuns, 1);

      expect(firstBatch[0], isNot(equals(secondBatch[0])));
      expect(secondBatch[0].isAfter(firstBatch[0]), isTrue);
    });
  });
}