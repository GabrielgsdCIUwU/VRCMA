import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/services/app_logger.dart';
import 'package:vrcma/domain/services/calendar/event_title_resolver.dart';
import 'package:vrcma/domain/services/calendar/occurrence_calculator.dart';
import 'package:vrcma/domain/usecases/automation/automation_processor.dart';
import 'package:vrcma/domain/usecases/automation/handlers/automation_handler.dart';
import 'package:vrcma/domain/usecases/automation/message_slot_manager.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';
import 'package:vrcma/domain/usecases/calendar/evaluate_and_generate_events_use_case.dart';
import 'package:vrcma/domain/usecases/calendar/validate_group_permissions_use_case.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/domain/usecases/automation/status/evaluate_status_use_case.dart';
import 'package:vrcma/domain/usecases/automation/status/coordinate_status_automation_use_case.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_condition_matcher.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_template_resolver.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';

part 'usecase_provider.g.dart';

@riverpod
Future<List<Role>> allAvailableRoles(Ref ref) async {
  final repo = await ref.watch(localSocialRepositoryProvider.future);
  return await repo.getAllAvailableRoles();
}

@riverpod
Future<List<AutomationEventHandler>> automationHandlers(Ref ref) async {
  final automationRepo = await ref.watch(automationRepositoryProvider.future);
  final authUser = await ref.watch(authStateProvider.future);
  final localSocialRepo = await ref.watch(localSocialRepositoryProvider.future);
  final profileRepo = await ref.watch(profileRepositoryProvider.future);
  final logRepo = await ref.watch(appLogRepositoryProvider.future);

  final invitationUseCase = ProcessInvitationUseCase(
    roleExtractor: UserRoleExtractor(),
    ruleSorter: RuleSorter(),
    ruleEvaluator: RuleEvaluator(),
  );

  return [
    InvitationAutomationHandler(
      currentUserId: authUser?.id ?? '',
      automationRepository: automationRepo,
      localSocialRepository: localSocialRepo,
      profileRepository: profileRepo,
      logRepository: logRepo,
      useCase: invitationUseCase,
      slotManager: MessageSlotManager(
        messageRepository: await ref.watch(messageRepositoryProvider.future),
        automationRepository: automationRepo
      ),
    ),
    
    FriendRequestAutomationHandler(
      automationRepository: automationRepo,
      localSocialRepository: localSocialRepo,
      profileRepository: profileRepo,
      logRepository: logRepo,
      useCase: invitationUseCase,
    ),
  ];
}

@riverpod
Future<AutomationProcessor> automationProcessor(Ref ref) async {
  final handlers = await ref.watch(automationHandlersProvider.future);
  return AutomationProcessor(handlers);
}

@riverpod
Future<EvaluateStatusUseCase> evaluateStatusUseCase(Ref ref) async {
  final localSocialRepo = await ref.watch(localSocialRepositoryProvider.future);
  return EvaluateStatusUseCase(
    matchers: [
      NumericConditionMatcher(),
      InstanceTypeMatcher(),
      FriendRoleMatcher(localSocialRepo),
      WorldConditionMatcher(),
      TimeRangeConditionMatcher(),
    ],
    resolver: StatusTemplateResolver(),
  );
}

@riverpod
Future<CoordinateStatusAutomationUseCase> coordinateStatusAutomationUseCase(Ref ref) async {
  final statusRepo = await ref.watch(statusRepositoryProvider.future);
  final automationRepo = await ref.watch(automationRepositoryProvider.future);
  final evaluateUseCase = await ref.watch(evaluateStatusUseCaseProvider.future);
  final logRepo = await ref.watch(appLogRepositoryProvider.future);

  return CoordinateStatusAutomationUseCase(
    statusRepository: statusRepo,
    automationRepository: automationRepo,
    logRepository: logRepo,
    evaluateStatusUseCase: evaluateUseCase,
  );
}

@riverpod
Future<ValidateGroupPermissionsUseCase> validateGroupPermissionsUseCase(Ref ref) async {
  final remoteRepo = await ref.watch(remoteCalendarRepositoryProvider.future);
  final cacheRepo = await ref.watch(groupPermissionCacheRepositoryProvider.future);
  return ValidateGroupPermissionsUseCase(remoteRepo, cacheRepo);
}

@riverpod
Future<EvaluateAndGenerateEventsUseCase> evaluateAndGenerateEventsUseCase(Ref ref) async {
  final localRepo = await ref.watch(localCalendarRepositoryProvider.future);
  final remoteRepo = await ref.watch(remoteCalendarRepositoryProvider.future);
  final logRepo = await ref.watch(appLogRepositoryProvider.future);

  return EvaluateAndGenerateEventsUseCase(
    localRepo: localRepo,
    remoteRepo: remoteRepo,
    logRepo: logRepo,
    calculator: OccurrenceCalculator(),
    titleResolver: EventTitleResolver(),
  );
}

@riverpod
Future<AppLogger> appLogger(Ref ref) async {
  final logRepo = await ref.watch(appLogRepositoryProvider.future);
  return AppLogger(logRepo);
}