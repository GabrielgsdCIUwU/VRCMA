import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/usecases/automation/automation_processor.dart';
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
Future<AutomationProcessor> automationProcessor(Ref ref) async {
  final automationRepo = await ref.watch(automationRepositoryProvider.future);
  final authUser = await ref.watch(authStateProvider.future);
  
  return AutomationProcessor(
      currentUserId: authUser?.id ?? '',
      automationRepository: automationRepo,
      localSocialRepository: await ref.watch(localSocialRepositoryProvider.future),
      profileRepository: await ref.watch(profileRepositoryProvider.future),
      logRepository: await ref.watch(logRepositoryProvider.future),
      slotManager: MessageSlotManager(
        messageRepository: await ref.watch(messageRepositoryProvider.future),
        automationRepository: automationRepo,
      ),
      useCase: ProcessInvitationUseCase(
        roleExtractor: UserRoleExtractor(),
        ruleSorter: RuleSorter(),
        ruleEvaluator: RuleEvaluator(),
      )
  );
}