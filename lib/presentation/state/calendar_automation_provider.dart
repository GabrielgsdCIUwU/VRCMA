import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';
import 'package:vrcma/core/di/usecase_provider.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/calendar_event_platform.dart';
import 'package:vrcma/domain/entities/calendar/enums/creation_strategy.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/calendar/planned_occurrence.dart';
import 'package:vrcma/domain/entities/calendar/remote_calendar_event.dart';
import 'package:vrcma/domain/entities/social/vrc_group.dart';
import 'package:vrcma/domain/services/calendar/occurrence_calculator.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/calendar_scheduler_provider.dart';

part 'calendar_automation_provider.g.dart';

/// Manages persisted calendar automation rules in local SQLite storage.
@riverpod
class CalendarAutomationList extends _$CalendarAutomationList {
  @override
  FutureOr<List<CalendarAutomationRule>> build() async {
    final repo = await ref.watch(localCalendarRepositoryProvider.future);
    return repo.getAllRules();
  }

  /// Persists [rule] and refreshes the cached rule list.
  Future<void> save(CalendarAutomationRule rule) async {
    final repo = await ref.read(localCalendarRepositoryProvider.future);
    await repo.saveRule(rule);
    ref.invalidateSelf();
    await future;
  }

  /// Deletes the rule identified by [id] and refreshes the list.
  Future<void> delete(int id) async {
    final repo = await ref.read(localCalendarRepositoryProvider.future);
    await repo.deleteRule(id);
    ref.invalidateSelf();
    await future;
  }

  /// Toggles the active state of [rule] and triggers immediate evaluation when enabled.
  Future<void> toggleActive(CalendarAutomationRule rule) async {
    final updatedRule = rule.copyWith(isActive: !rule.isActive);
    await save(updatedRule);

    if (updatedRule.isActive) {
      await ref.read(calendarSchedulerProvider.notifier).evaluateNow();
    }
  }
}

/// Holds draft state while creating or editing a [CalendarAutomationRule].
@riverpod
class CalendarAutomationEditor extends _$CalendarAutomationEditor {
  late CalendarAutomationRule _initialRule;

  @override
  CalendarAutomationRule build(CalendarAutomationRule? initial) {
    _initialRule = initial ?? _buildDefaultRule();
    return _initialRule;
  }

  CalendarAutomationRule _buildDefaultRule() {
    return CalendarAutomationRule(
      name: '',
      groupId: '',
      titleTemplate: '',
      category: GroupEventCategory.other,
      accessType: GroupEventAccessType.group,
      schedule: TimezoneSchedule(
        startTime: TimeOfDayValue(hour: 20),
        durationMinutes: 60,
        timezoneIana: tz.local.name,
      ),
      recurrence: const RecurrencePattern(
        type: RecurrenceType.weekly,
        daysOfWeek: [DateTime.friday],
      ),
      incrementalConfig: IncrementalConfig(isEnabled: false),
    );
  }

  bool get hasChanges => state != _initialRule;

  bool get isValid {
    return state.name.trim().isNotEmpty &&
        state.groupId.trim().isNotEmpty &&
        state.titleTemplate.trim().isNotEmpty;
  }

  void updateName(String name) => state = state.copyWith(name: name);

  void updateGroupId(String groupId) => state = state.copyWith(groupId: groupId);

  /// Validates calendar management permissions for [groupId] and selects it if allowed.
  Future<bool> validateAndSetGroup(String groupId) async {
    final authUser = await ref.read(authStateProvider.future);
    if (authUser == null) return false;

    final validateUseCase =
    await ref.read(validateGroupPermissionsUseCaseProvider.future);
    final hasPermission =
    await validateUseCase.execute(userId: authUser.id, groupId: groupId);

    if (hasPermission) {
      updateGroupId(groupId);
    }
    return hasPermission;
  }

  void updateTitleTemplate(String title) =>
      state = state.copyWith(titleTemplate: title);

  void updateDescriptionTemplate(String? desc) =>
      state = state.copyWith(descriptionTemplate: () => desc);

  void updateCategory(GroupEventCategory cat) =>
      state = state.copyWith(category: cat);

  void updateAccessType(GroupEventAccessType access) =>
      state = state.copyWith(accessType: access);

  void updateTime(TimeOfDayValue time) {
    state = state.copyWith(
      schedule: state.schedule.copyWith(startTime: time),
    );
  }

  void updateDuration(int duration) {
    if (duration <= 0) return;
    state = state.copyWith(
      schedule: state.schedule.copyWith(durationMinutes: duration),
    );
  }

  void updateTimezone(String timezoneIana) {
    if (timezoneIana.trim().isEmpty) return;
    state = state.copyWith(
      schedule: state.schedule.copyWith(timezoneIana: timezoneIana),
    );
  }

  void updateRecurrence(RecurrencePattern recurrence) =>
      state = state.copyWith(recurrence: recurrence);

  void updateStartDate(DateTime? date) {
    final normalized = _normalizeDateOnly(date);
    final currentEnd = state.schedule.endDate;
    final adjustedEnd =
    (normalized != null && currentEnd != null && normalized.isAfter(currentEnd))
        ? normalized
        : currentEnd;

    state = state.copyWith(
      schedule: TimezoneSchedule(
        startTime: state.schedule.startTime,
        durationMinutes: state.schedule.durationMinutes,
        timezoneIana: state.schedule.timezoneIana,
        startDate: normalized,
        endDate: adjustedEnd,
      ),
    );
  }

  void updateEndDate(DateTime? date) {
    final normalized = _normalizeDateOnly(date);
    final currentStart = state.schedule.startDate;
    if (normalized != null &&
        currentStart != null &&
        normalized.isBefore(currentStart)) {
      return;
    }

    state = state.copyWith(
      schedule: TimezoneSchedule(
        startTime: state.schedule.startTime,
        durationMinutes: state.schedule.durationMinutes,
        timezoneIana: state.schedule.timezoneIana,
        startDate: currentStart,
        endDate: normalized,
      ),
    );
  }

  void addException(CalendarException exception) {
    state = state.copyWith(exceptions: [...state.exceptions, exception]);
  }

  void removeException(CalendarException exception) {
    state = state.copyWith(
      exceptions: state.exceptions.where((e) => e != exception).toList(),
    );
  }

  void updateIncrementalEnabled(bool enabled) {
    final current = state.incrementalConfig;
    state = state.copyWith(
      incrementalConfig: IncrementalConfig(
        isEnabled: enabled,
        startValue: current.startValue,
        stepValue: current.stepValue,
        currentValue: current.currentValue,
      ),
    );
  }

  void updateIncrementalStart(int? startValue) {
    if (startValue == null || startValue < 0) return;
    final current = state.incrementalConfig;
    state = state.copyWith(
      incrementalConfig: IncrementalConfig(
        isEnabled: current.isEnabled,
        startValue: startValue,
        stepValue: current.stepValue,
        currentValue: startValue,
      ),
    );
  }

  void updateIncrementalStep(int? stepValue) {
    if (stepValue == null || stepValue <= 0) return;
    final current = state.incrementalConfig;
    state = state.copyWith(
      incrementalConfig: IncrementalConfig(
        isEnabled: current.isEnabled,
        startValue: current.startValue,
        stepValue: stepValue,
        currentValue: current.currentValue,
      ),
    );
  }

  void toggleSendNotification() =>
      state = state.copyWith(sendNotification: !state.sendNotification);

  void updateStrategy(CreationStrategy strat) =>
      state = state.copyWith(strategy: strat);

  void updateMaxVisibleFutureEvents(int max) =>
      state = state.copyWith(maxVisibleFutureEvents: max.clamp(1, 10));

  void togglePlatform(CalendarEventPlatform platform) {
    final updatedPlatforms = List<CalendarEventPlatform>.from(state.platforms);
    if (updatedPlatforms.contains(platform)) {
      updatedPlatforms.remove(platform);
    } else {
      updatedPlatforms.add(platform);
    }
    state = state.copyWith(platforms: updatedPlatforms);
  }

  void addLanguage(String lang) {
    if (state.languages.contains(lang)) return;
    state = state.copyWith(languages: [...state.languages, lang]);
  }

  void removeLanguage(String lang) {
    state = state.copyWith(
      languages: state.languages.where((l) => l != lang).toList(),
    );
  }

  void toggleInstanceOverflow() =>
      state = state.copyWith(usesInstanceOverflow: !state.usesInstanceOverflow);

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

  /// Validates and persists the edited rule, triggering evaluation if active.
  Future<void> saveAndClose() async {
    if (!isValid) return;

    await ref.read(calendarAutomationListProvider.notifier).save(state);
    if (state.isActive) {
      ref.read(calendarSchedulerProvider.notifier).evaluateNow();
    }
  }

  DateTime? _normalizeDateOnly(DateTime? date) {
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }
}

/// Fetches VRChat groups the authenticated user belongs to (cached for 5 minutes).
@riverpod
Future<List<VrcGroup>> userGroups(Ref ref) async {
  final keepAliveLink = ref.keepAlive();
  Timer? timer;

  ref.onDispose(() => timer?.cancel());
  ref.onCancel(() {
    timer = Timer(const Duration(minutes: 5), keepAliveLink.close);
  });
  ref.onResume(() => timer?.cancel());

  final authUser = await ref.watch(authStateProvider.future);
  if (authUser == null) return [];

  final socialRepo = await ref.watch(socialRepositoryProvider.future);
  final groupsResult = await socialRepo.getUserGroups(authUser.id);

  return groupsResult.fold((_) => <VrcGroup>[], (groups) => groups);
}

/// Fetches upcoming VRChat calendar events for [groupId] (cached for 2 minutes).
@riverpod
Future<List<RemoteCalendarEvent>> groupUpcomingEvents(
    Ref ref,
    String groupId,
    ) async {
  if (groupId.trim().isEmpty) return const [];

  final keepAliveLink = ref.keepAlive();
  Timer? timer;

  ref.onDispose(() => timer?.cancel());
  ref.onCancel(() {
    timer = Timer(const Duration(minutes: 2), keepAliveLink.close);
  });
  ref.onResume(() => timer?.cancel());

  try {
    final remoteRepo = await ref.watch(remoteCalendarRepositoryProvider.future);
    return await remoteRepo.getUpcomingGroupEvents(groupId);
  } catch (_) {
    // Gracefully degrade to local-only preview if network or rate limit blocks fetch.
    return const [];
  }
}

/// Computes a dry-run preview of upcoming slots for [rule], including remote matches.
@riverpod
Future<List<PlannedOccurrence>> calendarRulePreview(
    Ref ref,
    CalendarAutomationRule rule,
    ) async {
  if (rule.groupId.trim().isEmpty) return const [];

  final localRepo = await ref.watch(localCalendarRepositoryProvider.future);
  final pastRuns = rule.id != null
      ? await localRepo.getPastRuns(rule.id!)
      : const <CalendarOccurrenceRun>[];

  final remoteEvents =
  await ref.watch(groupUpcomingEventsProvider(rule.groupId).future);

  const previewLimit = 5;
  final targetLimit = rule.strategy == CreationStrategy.lazy
      ? previewLimit
      : rule.maxVisibleFutureEvents.clamp(1, previewLimit);

  return OccurrenceCalculator().planUpcomingOccurrences(
    rule: rule,
    pastRuns: pastRuns,
    visibleSlotLimit: targetLimit,
    remoteEvents: remoteEvents,
    includeCancelled: true,
  );
}