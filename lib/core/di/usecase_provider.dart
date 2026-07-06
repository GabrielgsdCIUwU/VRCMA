import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';
import 'package:vrcma/data/transformers/vrc_event_transformer.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/usecases/automation/automation_processor.dart';
import 'package:vrcma/domain/usecases/automation/handlers/automation_handler.dart';
import 'package:vrcma/domain/usecases/automation/message_slot_manager.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

part 'usecase_provider.g.dart';

@riverpod
Future<List<Role>> allAvailableRoles(Ref ref) async {
  final repo = await ref.watch(localSocialRepositoryProvider.future);
  return await repo.getAllAvailableRoles();
}

@riverpod
List<VrcEventTransformer> vrcTransformers(Ref ref) {
  return [
    FriendRequestTransformer(),
    InviteReceivedTransformer(),
    RequestReceivedTransformer(),
  ];
}

@riverpod
Future<List<AutomationEventHandler>> automationHandlers(Ref ref) async {
  final automationRepo = await ref.watch(automationRepositoryProvider.future);
  final authUser = await ref.watch(authStateProvider.future);
  final localSocialRepo = await ref.watch(localSocialRepositoryProvider.future);
  final profileRepo = await ref.watch(profileRepositoryProvider.future);
  final logRepo = await ref.watch(logRepositoryProvider.future);

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