import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/planned_occurrence_status.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/calendar/remote_calendar_event.dart';
import 'package:vrcma/domain/services/calendar/occurrence_calculator.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('OccurrenceCalculator Engine', () {
    final calculator = OccurrenceCalculator();
    final fixedNowUtc = DateTime.utc(2026, 11, 20, 10, 0);

    CalendarAutomationRule createRule({
      required RecurrenceType type,
      String titleTemplate = 'Test Event',
      String timezoneIana = 'UTC',
      int hour = 20,
      DateTime? startDate,
      DateTime? endDate,
      List<int> daysOfWeek = const [],
      List<CalendarException> exceptions = const [],
    }) {
      return CalendarAutomationRule(
        name: 'Test Rule',
        groupId: 'grp_123',
        titleTemplate: titleTemplate,
        category: GroupEventCategory.other,
        accessType: GroupEventAccessType.public,
        schedule: TimezoneSchedule(
          startTime: TimeOfDayValue(hour: hour, minute: 0),
          durationMinutes: 60,
          timezoneIana: timezoneIana,
          startDate: startDate,
          endDate: endDate,
        ),
        recurrence: RecurrencePattern(type: type, daysOfWeek: daysOfWeek),
        incrementalConfig: IncrementalConfig(isEnabled: false),
        exceptions: exceptions,
      );
    }

    test('should calculate daily occurrences enforcing visibleSlotLimit', () {
      final rule = createRule(type: RecurrenceType.daily);

      final planned = calculator.planUpcomingOccurrences(
        rule: rule,
        pastRuns: const [],
        visibleSlotLimit: 3,
        referenceNowUtc: fixedNowUtc,
      );

      expect(planned.length, 3);
      expect(
        planned.every((p) => p.status == PlannedOccurrenceStatus.pendingPublish),
        isTrue,
      );
      expect(planned[1].startUtc.difference(planned[0].startUtc).inDays, 1);
      expect(planned[2].startUtc.difference(planned[1].startUtc).inDays, 1);
    });

    test('should calculate weekly occurrences strictly on designated weekday', () {
      final rule = createRule(
        type: RecurrenceType.weekly,
        daysOfWeek: const [DateTime.friday],
      );

      final planned = calculator.planUpcomingOccurrences(
        rule: rule,
        pastRuns: const [],
        visibleSlotLimit: 2,
        referenceNowUtc: fixedNowUtc,
      );

      expect(planned.length, 2);
      expect(planned[0].startUtc.weekday, DateTime.friday);
      expect(planned[1].startUtc.weekday, DateTime.friday);
      expect(planned[1].startUtc.difference(planned[0].startUtc).inDays, 7);
    });

    test('should generate only one slot for once recurrence and stop after run exists', () {
      final rule = createRule(
        type: RecurrenceType.once,
        startDate: DateTime(2026, 11, 22),
      );

      final firstPass = calculator.planUpcomingOccurrences(
        rule: rule,
        pastRuns: const [],
        visibleSlotLimit: 5,
        referenceNowUtc: fixedNowUtc,
      );

      expect(firstPass.length, 1);
      expect(firstPass.first.startUtc, DateTime.utc(2026, 11, 22, 20, 0));

      final pastRuns = [
        CalendarOccurrenceRun(
          calculatedOccurrenceUtc: firstPass.first.startUtc,
          createdVrcEventId: 'cal_once_1',
          publishedAt: fixedNowUtc,
        ),
      ];

      final secondPass = calculator.planUpcomingOccurrences(
        rule: rule,
        pastRuns: pastRuns,
        visibleSlotLimit: 5,
        referenceNowUtc: fixedNowUtc,
      );

      expect(secondPass, isEmpty);
    });

    test('should exclude dates within a multi-day cancellation exception range', () {
      final rule = createRule(
        type: RecurrenceType.daily,
        exceptions: [
          CalendarException(
            exceptionDate: DateTime(2026, 11, 21),
            exceptionEndDate: DateTime(2026, 11, 22),
            isCancelled: true,
          ),
        ],
      );

      final planned = calculator.planUpcomingOccurrences(
        rule: rule,
        pastRuns: const [],
        visibleSlotLimit: 2,
        referenceNowUtc: fixedNowUtc,
      );

      expect(planned.length, 2);
      expect(planned[0].startUtc, DateTime.utc(2026, 11, 20, 20, 0));
      expect(planned[1].startUtc, DateTime.utc(2026, 11, 23, 20, 0));
    });

    test('should cap total future visible slots instead of creating unlimited batch runs', () {
      final rule = createRule(type: RecurrenceType.daily);
      final pastRuns = [
        CalendarOccurrenceRun(
          calculatedOccurrenceUtc: DateTime.utc(2026, 11, 20, 20, 0),
          createdVrcEventId: 'evt_1',
          publishedAt: fixedNowUtc,
        ),
        CalendarOccurrenceRun(
          calculatedOccurrenceUtc: DateTime.utc(2026, 11, 21, 20, 0),
          createdVrcEventId: 'evt_2',
          publishedAt: fixedNowUtc,
        ),
      ];

      final planned = calculator.planUpcomingOccurrences(
        rule: rule,
        pastRuns: pastRuns,
        visibleSlotLimit: 3,
        referenceNowUtc: fixedNowUtc,
      );

      final pending = planned
          .where((s) => s.status == PlannedOccurrenceStatus.pendingPublish)
          .toList();

      expect(planned.length, 3);
      expect(pending.length, 1);
      expect(pending.first.startUtc, DateTime.utc(2026, 11, 22, 20, 0));
    });

    test('should mark slot as alreadyPublished when matching event exists on VRChat', () {
      final rule = createRule(
        type: RecurrenceType.daily,
        titleTemplate: 'Chill Meetup #{{incremental}}',
      );

      final remoteEvents = [
        RemoteCalendarEvent(
          id: 'vrc_remote_99',
          title: 'Chill Meetup #4',
          startsAtUtc: DateTime.utc(2026, 11, 20, 20, 5),
          endsAtUtc: DateTime.utc(2026, 11, 20, 21, 5),
        ),
      ];

      final planned = calculator.planUpcomingOccurrences(
        rule: rule,
        pastRuns: const [],
        visibleSlotLimit: 2,
        remoteEvents: remoteEvents,
        referenceNowUtc: fixedNowUtc,
      );

      expect(planned.length, 2);
      expect(planned[0].status, PlannedOccurrenceStatus.alreadyPublished);
      expect(planned[0].existingRemoteEventId, 'vrc_remote_99');
      expect(planned[1].status, PlannedOccurrenceStatus.pendingPublish);
    });
  });
}