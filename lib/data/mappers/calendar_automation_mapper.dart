import 'dart:convert';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/calendar_event_platform.dart';
import 'package:vrcma/domain/entities/calendar/enums/creation_strategy.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/instance_region.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';

class CalendarAutomationMapper {
  static CalendarAutomationRule fromDatabaseMaps(
    Map<String, dynamic> row,
    List<CalendarException> exceptions,
  ) {
    final recurrenceData = row['recurrence_data'] != null
        ? jsonDecode(row['recurrence_data'] as String) as Map<String, dynamic>
        : const <String, dynamic>{};

    final daysOfWeek = List<int>.from(recurrenceData['days_of_week'] as List? ?? const []);
    final daysOfMonth = List<int>.from(recurrenceData['days_of_month'] as List? ?? const []);

    final allowedVrcRoleIdsJson = row['allowed_vrc_role_ids'] as String?;
    final allowedVrcRoleIds = allowedVrcRoleIdsJson != null
        ? List<String>.from(jsonDecode(allowedVrcRoleIdsJson) as List)
        : const <String>[];

    final platformsJson = row['platforms'] as String;
    final platforms = (jsonDecode(platformsJson) as List)
        .map((e) => CalendarEventPlatform.fromString(e as String))
        .toList();

    final languagesJson = row['languages'] as String?;
    final languages = languagesJson != null
        ? List<String>.from(jsonDecode(languagesJson) as List)
        : const <String>[];

    final tagsJson = row['tags'] as String?;
    final tags = tagsJson != null
        ? List<String>.from(jsonDecode(tagsJson) as List)
        : const <String>[];

    InstanceLinkTemplate? instanceTemplate;
    if (row['world_id'] != null) {
      final rawAccessType = row['instance_access_type'] as String? ?? 'unknown';
      final parsedAccessType = InstanceAccessType.values.firstWhere(
        (e) => e.name == rawAccessType,
        orElse: () => InstanceAccessType.unknown,
      );

      instanceTemplate = InstanceLinkTemplate(
        worldId: WorldId(row['world_id'] as String),
        accessType: parsedAccessType,
        region: InstanceRegion.fromString(row['instance_region'] as String? ?? 'eu'),
      );
    }

    return CalendarAutomationRule(
      id: row['id'] as int?,
      name: row['name'] as String,
      groupId: row['group_id'] as String,
      titleTemplate: row['title_template'] as String,
      descriptionTemplate: row['description_template'] as String?,
      category: GroupEventCategory.fromString(row['category'] as String),
      accessType: GroupEventAccessType.fromString(row['access_type'] as String),
      schedule: TimezoneSchedule(
        startTime: TimeOfDayValue.parse(row['start_time_of_day'] as String),
        durationMinutes: row['duration_minutes'] as int,
        timezoneIana: row['timezone'] as String,
      ),
      recurrence: RecurrencePattern(
        type: RecurrenceType.fromString(row['recurrence_type'] as String),
        daysOfWeek: daysOfWeek,
        daysOfMonth: daysOfMonth,
      ),
      incrementalConfig: IncrementalConfig(
        isEnabled: row['is_incremental_enabled'] == 1,
        startValue: row['incremental_start'] as int? ?? 1,
        stepValue: row['incremental_step'] as int? ?? 1,
        currentValue: row['current_increment'] as int? ?? 1,
      ),
      isActive: row['is_active'] == 1,
      sendNotification: row['send_notification'] == 1,
      strategy: CreationStrategy.fromString(row['creation_strategy'] as String? ?? 'lazy'),
      maxVisibleFutureEvents: row['max_visible_future_events'] as int? ?? 1,
      instanceTemplate: instanceTemplate,
      allowedVrcRoleIds: allowedVrcRoleIds,
      platforms: platforms,
      languages: languages,
      tags: tags,
      hostEarlyJoinMinutes: row['host_early_join_minutes'] as int?,
      guestEarlyJoinMinutes: row['guest_early_join_minutes'] as int?,
      closeInstanceAfterEndMinutes: row['close_instance_after_end_minutes'] as int?,
      usesInstanceOverflow: row['uses_instance_overflow'] == 1,
      exceptions: exceptions,
    );
  }

  static Map<String, dynamic> toDatabaseMap(CalendarAutomationRule rule) {
    final recurrenceData = {
      'days_of_week': rule.recurrence.daysOfWeek,
      'days_of_month': rule.recurrence.daysOfMonth,
    };

    return {
      if (rule.id != null) 'id': rule.id,
      'name': rule.name,
      'group_id': rule.groupId,
      'title_template': rule.titleTemplate,
      'description_template': rule.descriptionTemplate,
      'category': rule.category.apiValue,
      'access_type': rule.accessType.apiValue,
      'start_time_of_day': rule.schedule.startTime.formatted,
      'duration_minutes': rule.schedule.durationMinutes,
      'timezone': rule.schedule.timezoneIana,
      'recurrence_type': rule.recurrence.type.apiValue,
      'recurrence_data': jsonEncode(recurrenceData),
      'is_incremental_enabled': rule.incrementalConfig.isEnabled ? 1 : 0,
      'incremental_start': rule.incrementalConfig.startValue,
      'incremental_step': rule.incrementalConfig.stepValue,
      'current_increment': rule.incrementalConfig.currentValue,
      'is_active': rule.isActive ? 1 : 0,
      'send_notification': rule.sendNotification ? 1 : 0,
      'creation_strategy': rule.strategy.apiValue,
      'max_visible_future_events': rule.maxVisibleFutureEvents,
      'world_id': rule.instanceTemplate?.worldId.value,
      'instance_access_type': rule.instanceTemplate?.accessType.name,
      'instance_region': rule.instanceTemplate?.region.apiValue,
      'allowed_vrc_role_ids': jsonEncode(rule.allowedVrcRoleIds),
      'platforms': jsonEncode(rule.platforms.map((e) => e.apiValue).toList()),
      'languages': jsonEncode(rule.languages),
      'tags': jsonEncode(rule.tags),
      'host_early_join_minutes': rule.hostEarlyJoinMinutes,
      'guest_early_join_minutes': rule.guestEarlyJoinMinutes,
      'close_instance_after_end_minutes': rule.closeInstanceAfterEndMinutes,
      'uses_instance_overflow': rule.usesInstanceOverflow ? 1 : 0,
    };
  }
}