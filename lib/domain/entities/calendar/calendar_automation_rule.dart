import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/calendar_event_platform.dart';
import 'package:vrcma/domain/entities/calendar/enums/creation_strategy.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';

/// Aggregate root representing the high-level business rules for automatic VRChat calendar management.
class CalendarAutomationRule extends Equatable {
  final int? id;
  final String name;
  final String groupId;
  final String titleTemplate;
  final String? descriptionTemplate;
  final GroupEventCategory category;
  final GroupEventAccessType accessType;
  final TimezoneSchedule schedule;
  final RecurrencePattern recurrence;
  final IncrementalConfig incrementalConfig;
  final bool isActive;
  final bool sendNotification;
  final CreationStrategy strategy;
  final int maxVisibleFutureEvents;
  final InstanceLinkTemplate? instanceTemplate;
  final List<String> allowedVrcRoleIds;
  final List<CalendarEventPlatform> platforms;
  final List<String> languages;
  final List<String> tags;
  final int? hostEarlyJoinMinutes;
  final int? guestEarlyJoinMinutes;
  final int? closeInstanceAfterEndMinutes;
  final bool usesInstanceOverflow;
  final List<CalendarException> exceptions;

  const CalendarAutomationRule({
    this.id,
    required this.name,
    required this.groupId,
    required this.titleTemplate,
    this.descriptionTemplate,
    required this.category,
    required this.accessType,
    required this.schedule,
    required this.recurrence,
    required this.incrementalConfig,
    this.isActive = false,
    this.sendNotification = false,
    this.strategy = CreationStrategy.lazy,
    this.maxVisibleFutureEvents = 1,
    this.instanceTemplate,
    this.allowedVrcRoleIds = const [],
    this.platforms = const [],
    this.languages = const [],
    this.tags = const [],
    this.hostEarlyJoinMinutes,
    this.guestEarlyJoinMinutes,
    this.closeInstanceAfterEndMinutes,
    this.usesInstanceOverflow = false,
    this.exceptions = const [],
  });

  /// Evaluates if there's an exception configured for a target date.
  bool hasExceptionFor(DateTime date) {
    return getExceptionFor(date) != null;
  }

  /// Retrieves the exception details if configured for a target date.
  CalendarException? getExceptionFor(DateTime date) {
    return exceptions.firstWhereOrNull(
      (e) => e.exceptionDate.year == date.year
        && e.exceptionDate.month == date.month
        && e.exceptionDate.day == date.day,
    );
  }

  CalendarAutomationRule copyWith({
    int? id,
    String? name,
    String? groupId,
    String? titleTemplate,
    String? Function()? descriptionTemplate,
    GroupEventCategory? category,
    GroupEventAccessType? accessType,
    TimezoneSchedule? schedule,
    RecurrencePattern? recurrence,
    IncrementalConfig? incrementalConfig,
    bool? isActive,
    bool? sendNotification,
    CreationStrategy? strategy,
    int? maxVisibleFutureEvents,
    InstanceLinkTemplate? Function()? instanceTemplate,
    List<String>? allowedVrcRoleIds,
    List<CalendarEventPlatform>? platforms,
    List<String>? languages,
    List<String>? tags,
    int? Function()? hostEarlyJoinMinutes,
    int? Function()? guestEarlyJoinMinutes,
    int? Function()? closeInstanceAfterEndMinutes,
    bool? usesInstanceOverflow,
    List<CalendarException>? exceptions,
  }) {
    return CalendarAutomationRule(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      descriptionTemplate: descriptionTemplate != null ? descriptionTemplate() : this.descriptionTemplate,
      category: category ?? this.category,
      accessType: accessType ?? this.accessType,
      schedule: schedule ?? this.schedule,
      recurrence: recurrence ?? this.recurrence,
      incrementalConfig: incrementalConfig ?? this.incrementalConfig,
      isActive: isActive ?? this.isActive,
      sendNotification: sendNotification ?? this.sendNotification,
      strategy: strategy ?? this.strategy,
      maxVisibleFutureEvents: maxVisibleFutureEvents ?? this.maxVisibleFutureEvents,
      instanceTemplate: instanceTemplate != null ? instanceTemplate() : this.instanceTemplate,
      allowedVrcRoleIds: allowedVrcRoleIds ?? this.allowedVrcRoleIds,
      platforms: platforms ?? this.platforms,
      languages: languages ?? this.languages,
      tags: tags ?? this.tags,
      hostEarlyJoinMinutes: hostEarlyJoinMinutes != null ? hostEarlyJoinMinutes() : this.hostEarlyJoinMinutes,
      guestEarlyJoinMinutes: guestEarlyJoinMinutes != null ? guestEarlyJoinMinutes() : this.guestEarlyJoinMinutes,
      closeInstanceAfterEndMinutes: closeInstanceAfterEndMinutes != null ? closeInstanceAfterEndMinutes() : this.closeInstanceAfterEndMinutes,
      usesInstanceOverflow: usesInstanceOverflow ?? this.usesInstanceOverflow,
      exceptions: exceptions ?? this.exceptions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        groupId,
        titleTemplate,
        descriptionTemplate,
        category,
        accessType,
        schedule,
        recurrence,
        incrementalConfig,
        isActive,
        sendNotification,
        strategy,
        maxVisibleFutureEvents,
        instanceTemplate,
        allowedVrcRoleIds,
        platforms,
        languages,
        tags,
        hostEarlyJoinMinutes,
        guestEarlyJoinMinutes,
        closeInstanceAfterEndMinutes,
        usesInstanceOverflow,
        exceptions,
  ];
}