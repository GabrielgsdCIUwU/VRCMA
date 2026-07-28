import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pool/pool.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vrcma/core/di/network_repository_provider.dart';
import 'package:vrcma/core/di/usecase_provider.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/enums/calendar_event_platform.dart';
import 'package:vrcma/domain/entities/calendar/enums/creation_strategy.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/social/vrc_group.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/calendar_scheduler_provider.dart';


part 'calendar_automation_provider.g.dart';

@riverpod
class CalendarAutomationList extends _$CalendarAutomationList {
  @override
  FutureOr<List<CalendarAutomationRule>> build() async {
    final repo = await ref.watch(localCalendarRepositoryProvider.future);
    return repo.getAllRules();
  }
  
  Future<void> save(CalendarAutomationRule rule) async {
    state = const AsyncLoading();
    final repo = await ref.read(localCalendarRepositoryProvider.future);
    await repo.saveRule(rule);
    ref.invalidateSelf();
  }
  
  Future<void> delete(int id) async {
    state = const AsyncLoading();
    final repo = await ref.read(localCalendarRepositoryProvider.future);
    await repo.deleteRule(id);
    ref.invalidateSelf();
  }
  
  Future<void> toggleActive(CalendarAutomationRule rule) async {
    final updateRule = rule.copyWith(isActive: !rule.isActive);
    await save(updateRule);
    if (updateRule.isActive) {
      ref.read(calendarSchedulerProvider.notifier).evaluateNow();
    }
  }
}

@riverpod
class CalendarAutomationEditor extends _$CalendarAutomationEditor {
  late CalendarAutomationRule _initialRule;
  
  @override
  CalendarAutomationRule build(CalendarAutomationRule? initial) {
    _initialRule = initial ?? CalendarAutomationRule(
      name: '',
      groupId: '',
      titleTemplate: '',
      category: GroupEventCategory.other,
      accessType: GroupEventAccessType.group,
      schedule: TimezoneSchedule(
        startTimeOfDay: '20:00',
        durationMinutes: 60,
        timezoneIana: tz.local.name,
      ),
      recurrence: RecurrencePattern(
        type: RecurrenceType.weekly,
        daysOfWeek: [5],
      ),
      incrementalConfig: IncrementalConfig(isEnabled: false),
    );
    return _initialRule;
  }
  
  bool get hasChanges => state != _initialRule;
  
  bool get isValid => state.name.trim().isNotEmpty && state.groupId.trim().isNotEmpty && state.titleTemplate.trim().isNotEmpty;
  
  void updateName(String name) => state = state.copyWith(name: name);
  
  void updateGroupId(String groupId) => state = state.copyWith(groupId: groupId);
  
  Future<bool> validateAndSetGroup(String groupId) async {
    final authUser = await ref.read(authStateProvider.future);
    if (authUser == null) return false;
    
    final validateUseCase = await ref.read(validateGroupPermissionsUseCaseProvider.future);
    final hasPermission = await validateUseCase.execute(userId: authUser.id, groupId: groupId);
    
    if (hasPermission) {
      updateGroupId(groupId);
      return true;
    }
    return false;
  }
  
  void updateTitleTemplate(String title) => state = state.copyWith(titleTemplate: title);
  
  void updateDescriptionTemplate(String? desc) => state = state.copyWith(descriptionTemplate: () => desc);
  
  void updateCategory(GroupEventCategory cat) => state = state.copyWith(category: cat);
  
  void updateAccessType(GroupEventAccessType access) => state = state.copyWith(accessType: access);
  
  void updateTime(String time) => state = state.copyWith(
    schedule: TimezoneSchedule(
      startTimeOfDay: time,
      durationMinutes: state.schedule.durationMinutes,
      timezoneIana: state.schedule.timezoneIana,
      startDate: state.schedule.startDate,
      endDate: state.schedule.endDate,
    ),
  );
  
  void updateDuration(int duration) => state = state.copyWith(
    schedule: TimezoneSchedule(
      startTimeOfDay: state.schedule.startTimeOfDay,
      durationMinutes: duration,
      timezoneIana: state.schedule.timezoneIana,
      startDate: state.schedule.startDate,
      endDate: state.schedule.endDate,
    ),
  );
  
  void updateTimezone(String tz) => state = state.copyWith(
    schedule: TimezoneSchedule(
      startTimeOfDay: state.schedule.startTimeOfDay,
      durationMinutes: state.schedule.durationMinutes,
      timezoneIana: tz,
      startDate: state.schedule.startDate,
      endDate: state.schedule.endDate,
    ),
  );
  
  void updateRecurrence(RecurrencePattern recurrence) => state = state.copyWith(recurrence: recurrence);

  void updateStartDate(DateTime? date) => state = state.copyWith(
    schedule: TimezoneSchedule(
      startTimeOfDay: state.schedule.startTimeOfDay,
      durationMinutes: state.schedule.durationMinutes,
      timezoneIana: state.schedule.timezoneIana,
      startDate: date,
      endDate: state.schedule.endDate,
    ),
  );

  void updateEndDate(DateTime? date) => state = state.copyWith(
    schedule: TimezoneSchedule(
      startTimeOfDay: state.schedule.startTimeOfDay,
      durationMinutes: state.schedule.durationMinutes,
      timezoneIana: state.schedule.timezoneIana,
      startDate: state.schedule.startDate,
      endDate: date,
    ),
  );

  void addException(CalendarException exception) {
    state = state.copyWith(exceptions: [...state.exceptions, exception]);
  }

  void removeException(CalendarException exception) {
    state = state.copyWith(
      exceptions: state.exceptions.where((e) => e != exception).toList(),
    );
  }
  
  void updateIncrementalConfig(IncrementalConfig config) => state = state.copyWith(incrementalConfig: config);
  
  void toggleSendNotification() => state = state.copyWith(sendNotification: !state.sendNotification);
  
  void updateStrategy(CreationStrategy strat) => state = state.copyWith(strategy: strat);
  
  void updateMaxVisibleFutureEvents(int max) => state = state.copyWith(maxVisibleFutureEvents: max);
  
  void togglePlatform(CalendarEventPlatform platform) {
    final List<CalendarEventPlatform> allStatePlatforms = List.from(state.platforms);
    if (allStatePlatforms.contains(platform)) {
      allStatePlatforms.remove(platform);
    } else {
      allStatePlatforms.add(platform);
    }
    state = state.copyWith(platforms: allStatePlatforms);
  }
  
  void addLanguage(String lang) {
    if (!state.languages.contains(lang)) {
      state = state.copyWith(languages: [...state.languages, lang]);
    }
  }
  
  void removeLanguage(String lang) {
    state = state.copyWith(languages: state.languages.where((l) => l != lang).toList());
  }
  
  void toggleInstanceOverflow() => state = state.copyWith(usesInstanceOverflow: !state.usesInstanceOverflow);
  
  void updateTolerances({
    int? hostMinutes,
    int? guestMinutes,
    int? closeMinutes,
  }) {
    state = state.copyWith(
      hostEarlyJoinMinutes: () => hostMinutes,
      guestEarlyJoinMinutes: () => guestMinutes,
      closeInstanceAfterEndMinutes: () => closeMinutes,
    );
  }
  
  Future<void> saveAndClose() async {
    if (!isValid) return;

    final synchronizedRule = state.copyWith(
      schedule: TimezoneSchedule(
        startTimeOfDay: state.schedule.startTimeOfDay,
        durationMinutes: state.schedule.durationMinutes,
        timezoneIana: tz.local.name,
        startDate: state.schedule.startDate,
        endDate: state.schedule.endDate,
      ),
    );

    await ref.read(calendarAutomationListProvider.notifier).save(synchronizedRule);
  }
}

@riverpod
Future<List<VrcGroup>> userGroups(Ref ref) async {
  final keepAliveLink = ref.keepAlive();
  Timer? timer;

  ref.onDispose(() => timer?.cancel());
  ref.onCancel(() {
    timer = Timer(const Duration(minutes: 5), () => keepAliveLink.close());
  });
  ref.onResume(() {
    timer?.cancel();
  });

  final authUser = await ref.watch(authStateProvider.future);
  if (authUser == null) return [];
  
  final socialRepo = await ref.watch(socialRepositoryProvider.future);
  final groupsResult = await socialRepo.getUserGroups(authUser.id);
  
  return groupsResult.fold((l) => <VrcGroup>[], (r) => r);
}