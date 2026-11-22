import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/services/calendar/event_title_resolver.dart';

void main() {
  group('EventTitleResolver - Template Parsing', () {
    final resolver = EventTitleResolver();

    CalendarAutomationRule createRule(String title, String? desc, {required int incrementValue}) {
      return CalendarAutomationRule(
        name: 'Test',
        groupId: 'grp_123',
        titleTemplate: title,
        descriptionTemplate: desc,
        category: GroupEventCategory.other,
        accessType: GroupEventAccessType.public,
        schedule: TimezoneSchedule(
          startTime: TimeOfDayValue(hour: 12, minute: 0),
          durationMinutes: 60,
          timezoneIana: 'UTC'
        ),
        recurrence: const RecurrencePattern(type: RecurrenceType.once),
        incrementalConfig: IncrementalConfig(isEnabled: true, currentValue: incrementValue)
      );
    }

    test('should replace {{incremental}} placeholder in title and description', () {
      final rule = createRule('Weekly Meeting #{{incremental}}', 'Episode {{incremental}} notes', incrementValue: 42);

      final result = resolver.resolve(rule);

      expect(result.title, 'Weekly Meeting #42');
      expect(result.description, 'Episode 42 notes');
    });

    test('should return raw strings if no placeholder is present', () {
      final rule = createRule('Standard event', 'Standard description', incrementValue: 99);

      final result = resolver.resolve(rule);

      expect(result.title, 'Standard event');
      expect(result.description, 'Standard description');
    });

    test('should handle null description gracefully', () {
      final rule = createRule('Title {{incremental}}', null, incrementValue: 5);

      final result = resolver.resolve(rule);

      expect(result.title, 'Title 5');
      expect(result.description, isNull);
    });
  });
}