import 'package:pool/pool.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vrcma/core/di/network_repository_provider.dart';
import 'package:vrcma/core/di/usecase_provider.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/calendar_event_platform.dart';
import 'package:vrcma/domain/entities/calendar/enums/creation_strategy.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/social/vrc_group.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';


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
  
  void updateTitleTemplate(String title) => state = state.copyWith(titleTemplate: title);
  
  void updateDescriptionTemplate(String? desc) => state = state.copyWith(descriptionTemplate: () => desc);
  
  void updateCategory(GroupEventCategory cat) => state = state.copyWith(category: cat);
  
  void updateAccessType(GroupEventAccessType access) => state = state.copyWith(accessType: access);
  
  void updateTime(String time) => state = state.copyWith(
    schedule: TimezoneSchedule(
      startTimeOfDay: time,
      durationMinutes: state.schedule.durationMinutes,
      timezoneIana: state.schedule.timezoneIana,
    ),
  );
  
  void updateDuration(int duration) => state = state.copyWith(
    schedule: TimezoneSchedule(
      startTimeOfDay: state.schedule.startTimeOfDay,
      durationMinutes: duration,
      timezoneIana: state.schedule.timezoneIana,
    ),
  );
  
  void updateTimezone(String tz) => state = state.copyWith(
    schedule: TimezoneSchedule(
      startTimeOfDay: state.schedule.startTimeOfDay,
      durationMinutes: state.schedule.durationMinutes,
      timezoneIana: tz,
    ),
  );
  
  void updateRecurrence(RecurrencePattern recurrence) => state = state.copyWith(recurrence: recurrence);
  
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
      ),
    );

    await ref.read(calendarAutomationListProvider.notifier).save(synchronizedRule);
  }
}

@riverpod
Future<List<VrcGroup>> permittedGroups(Ref ref) async {
  final authUser = await ref.watch(authStateProvider.future);
  if (authUser == null) return [];
  
  final socialRepo = await ref.watch(socialRepositoryProvider.future);
  final groupsResult = await socialRepo.getUserGroups(authUser.id);
  
  final allGroups = groupsResult.fold((l) => <VrcGroup>[], (r) => r);
  if (allGroups.isEmpty) return [];
  
  final validateUseCase = await ref.watch(validateGroupPermissionsUseCaseProvider.future);
  final permittedGroups = <VrcGroup>[];
  
  final pool = Pool(3);
  
  await Future.wait(allGroups.map((group) => pool.withResource(() async {
    final hasPermission = await validateUseCase.execute(userId: authUser.id, groupId: group.id);
    if (hasPermission) {
      permittedGroups.add(group);
    }
  })));
  return permittedGroups;
}