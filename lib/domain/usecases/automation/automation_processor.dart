import 'package:flutter/cupertino.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';
import 'package:vrcma/domain/repositories/i_log_repository.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';
import 'package:vrcma/domain/usecases/automation/message_slot_manager.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';

class AutomationProcessor {
  final IAutomationRepository automationRepository;
  final ILocalSocialRepository localSocialRepository;
  final IProfileRepository profileRepository;
  final ILogRepository logRepository;
  final ProcessInvitationUseCase useCase;
  final MessageSlotManager slotManager;
  
  AutomationProcessor({
    required this.automationRepository,
    required this.localSocialRepository,
    required this.profileRepository,
    required this.logRepository,
    required this.useCase,
    required this.slotManager,
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
      
      await _executeAction(invitation, decision.action, decision.rule);
      
      await _recordLog(
        invitation,
        decision.action == RuleAction.accept ? 'ACCEPTED' : 'REJECTED',
        'Match: ${decision.rule.role.name}',
        profile.name
      );
    } catch (e) {
      debugPrint("Error processing invitation: $e");
    }
  }
  
  Future<FilterProfile?> _getActiveProfile() async {
    final profiles = await profileRepository.getProfiles();
    return profiles.cast<FilterProfile?>().firstWhere(
        (p) => p!.isActive,
        orElse: () => null,
    );
  }
  
  Future<void> _executeAction(InvitationType invite, RuleAction action, ProfileRule rule) async {
    
    CustomMessage? messageToUse;
    if (invite is InviteReceived) {
      messageToUse = rule.inviteResponseMessage;
    } else if (invite is RequestInvite) {
      messageToUse = rule.requestResponseMessage;
    }

    final int? slotToUse = (messageToUse != null)
      ? await slotManager.prepareSlotForMessage(invite.senderId, messageToUse)
      : null;

    if (action == RuleAction.accept) {
     await _handleAccept(invite, slotToUse);
    } else {
      await _handleReject(invite, slotToUse);
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


  Future<void> _handleAccept(InvitationType invite, int? slot) async {
    if (invite is RequestInvite) {
      await automationRepository.acceptRequestInvitation(invite, slot);
    } else if (invite is InviteReceived) {
      await automationRepository.acceptInvitation(invite);
    }
  }

  Future<void> _handleReject(InvitationType invite, int? slot) async {
    if (slot == null) {
      await automationRepository.dismissNotification(invite);
      return;
    }
    await automationRepository.rejectNotificationWithMessage(invite, slot);
  }
}