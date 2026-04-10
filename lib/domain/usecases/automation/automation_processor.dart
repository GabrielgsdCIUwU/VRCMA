import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';
import 'package:vrcma/domain/repositories/i_log_repository.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';

class AutomationProcessor {
  final IAutomationRepository automationRepository;
  final ILocalSocialRepository localSocialRepository;
  final IProfileRepository profileRepository;
  final ILogRepository logRepository;
  final ProcessInvitationUseCase useCase;
  
  AutomationProcessor({
    required this.automationRepository,
    required this.localSocialRepository,
    required this.profileRepository,
    required this.logRepository,
    required this.useCase
  });
  
  Future<void> process(InvitationType invitation) async {
    try {
      final profile = await _getActiveProfile();
      if (profile == null) return;
      
      final userRoles = await localSocialRepository.getRolesForUser(invitation.senderId);
      
      final decision = useCase.execute(
        request: invitation,
        profile: profile,
        userAssignedRoles: userRoles,
      );
      
      if (decision == null) {
        await _recordLog(invitation, 'IGNORED', 'No matching rule', profile.name);
        return;
      }
      
      await _executeAction(invitation, decision.action, decision.rule.message);
      
      await _recordLog(
        invitation,
        decision.action == RuleAction.accept ? 'ACCEPTED' : 'REJECTED',
        'Profile Match',
        profile.name
      );
    } catch (e) {
      print("Error processing invitation: $e");
    }
  }
  
  Future<FilterProfile?> _getActiveProfile() async {
    final profiles = await profileRepository.getProfiles();
    return profiles.cast<FilterProfile?>().firstWhere(
        (p) => p!.isActive,
        orElse: () => null,
    );
  }
  
  Future<void> _executeAction(InvitationType invite, RuleAction action, CustomMessage? message) async {

    final int? slotToUse = (message != null && message.isActive) ? message.slotIndex : null;

    if (action == RuleAction.accept) {
      if (invite is RequestInvite) {
        await automationRepository.acceptRequestInvitation(invite, slotToUse);
      } else if (invite is InviteReceived) {
        await automationRepository.acceptInvitation(invite);
      }
    } else {
      await automationRepository.rejectNotificationWithMessage(invite, slotToUse ?? 0);
    }
  }
  
  Future<void> _recordLog(InvitationType invite, String  action, String rule, String profileName) async {
    await logRepository.saveLog(
      vrcUserId: invite.senderId,
      displayName: invite.senderName,
      avatarUrl: invite.avatarUrl,
      invitationType: invite is RequestInvite ? 'REQUEST' : 'INVITE',
      action: action,
      appliedRule: "$profileName ($rule)",
    );
  }
}