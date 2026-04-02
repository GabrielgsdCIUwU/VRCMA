import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/data/repositories/automation_repository_imp.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/logs_provider.dart';
import 'package:vrcma/presentation/state/profile_management_provider.dart';

part 'automation_provider.g.dart';

@riverpod
class AutomationState extends _$AutomationState {
  @override
  void build() {
    _listenToInvitations();
  }
  
  void _listenToInvitations() async {
    final api = await ref.watch(vrcApiProvider.future);
    final automationRepo = AutomationRepositoryImp(api);
    final localRepo = await ref.watch(localSocialRepositoryProvider.future);
    
    final useCase = ProcessInvitationUseCase(
      roleExtractor: UserRoleExtractor(),
      ruleSorter: RuleSorter(),
      ruleEvaluator: RuleEvaluator(),
      defaultResolver: DefaultActionResolver()
    );
    
    automationRepo.watchInvitations().listen((invitation) async {
      final profiles = await ref.read(profileManagementProviderProvider.future);
      final activeProfile = profiles.firstWhere((p) => 
          p.isActive, 
          orElse: () => const FilterProfile(name: 'None'));
      
      if (activeProfile.id == null) return;
      
      final userRoles = await localRepo.getRolesForUser(invitation.senderId);
      
      final decision = useCase.execute(
        request: invitation,
        profile: activeProfile,
        userAssignedRoles: userRoles
      );
      
      final logRepo = await ref.read(logRepositoryProvider.future);
      await logRepo.saveLog(
        vrcUserId: invitation.senderId,
        displayName: invitation.senderName,
        avatarUrl: '',
        invitationType: invitation is RequestInvite ? 'REQUEST' : 'INVITE',
        action: decision == RuleAction.accept ? 'ACCEPTED' : 'REJECTED',
        appliedRule: activeProfile.name
      );
      ref.invalidate(automationLogsProvider);
    });
  }
}