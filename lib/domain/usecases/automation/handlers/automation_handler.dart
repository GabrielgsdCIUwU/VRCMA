import 'dart:io';

import 'package:vrcma/core/l10n/arb/app_localizations.dart';
import 'package:vrcma/domain/entities/automation/automation_log.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';
import 'package:vrcma/domain/repositories/i_log_repository.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';
import 'package:vrcma/domain/usecases/automation/message_slot_manager.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';

abstract class AutomationEventHandler<T extends VrcAutomationEvent> {
  /// Evaluates whether this handler processes the dispatched domain event.
  bool canHandle(VrcAutomationEvent event);

  /// Executes the core logic for the specified event.
  Future<void> handle(T event);
}

abstract class BaseIncomingUserEventHandler<T extends IncomingUserEvent> extends AutomationEventHandler<T> {
  final IAutomationRepository automationRepository;
  final ILocalSocialRepository localSocialRepository;
  final IProfileRepository profileRepository;
  final ILogRepository logRepository;
  final ProcessInvitationUseCase useCase;
  final AppLocalizations l10n;

  BaseIncomingUserEventHandler({
    required this.automationRepository,
    required this.localSocialRepository,
    required this.profileRepository,
    required this.logRepository,
    required this.useCase,
    required this.l10n,
  });

  Future<FilterProfile?> getActiveProfile() async {
    final profiles = await profileRepository.getProfiles();
    return profiles.cast<FilterProfile?>().firstWhere(
      (profile) => profile!.isActive,
      orElse: () => null,
    );
  }

  Future<void> recordLog({
    required IncomingUserEvent event,
    required LogActionOutcome action,
    required LogEventType eventType,
    required String profileName,
    String? matchedRoleName,
  }) async {
    final appliedRuleMetadata = matchedRoleName != null
      ? "$profileName:$matchedRoleName"
      : profileName;

    await logRepository.saveLog(
      vrcUserId: event.senderId,
      displayName: event.senderName,
      avatarUrl: event.avatarUrl,
      invitationType: eventType.dbValue,
      action: action.dbValue,
      appliedRule: appliedRuleMetadata,
    );
  }
}

class InvitationAutomationHandler extends BaseIncomingUserEventHandler<IncomingUserEvent> {
  final String currentUserId;
  final MessageSlotManager slotManager;

  InvitationAutomationHandler({
    required super.automationRepository,
    required super.localSocialRepository,
    required super.profileRepository,
    required super.logRepository,
    required super.useCase,
    required super.l10n,
    required this.currentUserId,
    required this.slotManager,
  });

  @override
  bool canHandle(VrcAutomationEvent event) {
    return event is InviteReceivedEvent || event is RequestInviteEvent;    
  }

  @override
  Future<void> handle(IncomingUserEvent event) async {
    final profile = await getActiveProfile();
    if (profile == null) return;

    final userRoles = await localSocialRepository.getRolesForUser(event.senderId);
    final decision = useCase.execute(
      request: event,
      profile: profile,
      userAssignedRoles: userRoles,
    );

    final LogEventType eventType = event is RequestInviteEvent
      ? LogEventType.request
      : LogEventType.invite;

      if (decision == null) {
        await recordLog(
          event: event,
          action: LogActionOutcome.ignored,
          eventType: eventType,
          profileName: profile.name,
        );
        return;
      }

      await _executeAction(event, decision.action, decision.rule);

      await recordLog(
        event: event,
        action: decision.action == RuleAction.accept
          ? LogActionOutcome.accepted
          : LogActionOutcome.rejected,
        eventType: eventType,
        profileName: profile.name,
        matchedRoleName: decision.rule.role.name,
      );
  }

  Future<void> _executeAction(IncomingUserEvent event, RuleAction action, ProfileRule rule) async {
    CustomMessage? messageToUse;
    if (event is InviteReceivedEvent) {
      messageToUse = rule.inviteResponseMessage;
    } else if (event is RequestInviteEvent) {
      messageToUse = rule.requestResponseMessage;
    }

    final int? slotToUse = (messageToUse != null)
        ? await slotManager.prepareSlotForMessage(currentUserId, messageToUse)
        : null;

    if (action == RuleAction.accept) {
      await _handleAccept(event, slotToUse);
    } else {
      await _handleReject(event, slotToUse);
    }
  }

  Future<void> _handleAccept(IncomingUserEvent event, int? slot) async {
    if (event is RequestInviteEvent) {
      await automationRepository.acceptRequestInvitation(event, slot);
    } else if (event is InviteReceivedEvent) {
      await automationRepository.acceptInvitation(event);
    }
  }

  Future<void> _handleReject(IncomingUserEvent event, int? slot) async {
    if (slot == null) {
      await automationRepository.dismissNotification(event);
      return;
    }
    await automationRepository.rejectNotificationWithMessage(event, slot);
  }
}

class FriendRequestAutomationHandler extends BaseIncomingUserEventHandler<FriendRequestReceivedEvent> {
  FriendRequestAutomationHandler({
    required super.automationRepository,
    required super.localSocialRepository,
    required super.profileRepository,
    required super.logRepository,
    required super.useCase,
    required super.l10n,
  });

  @override
  bool canHandle(VrcAutomationEvent event) {
    return event is FriendRequestReceivedEvent;    
  }

  @override
  Future<void> handle(FriendRequestReceivedEvent event) async {
    final profile = await getActiveProfile();
    if (profile == null) return;

    final userRoles = await localSocialRepository.getRolesForUser(event.senderId);
    final decision = useCase.execute(
      request: event,
      profile: profile,
      userAssignedRoles: userRoles,
    );

    const LogEventType eventType = LogEventType.friendRequest;

    if (decision == null) {
      await recordLog(
        event: event,
        action: LogActionOutcome.ignored,
        eventType: eventType,
        profileName: profile.name
      );
      return;
    }

    if (decision.action == RuleAction.accept) {
      await automationRepository.acceptFriendRequest(event);
    } else {
      await automationRepository.dismissNotification(event);
    }

    await recordLog(
      event: event,
      action: decision.action == RuleAction.accept
        ? LogActionOutcome.accepted
        : LogActionOutcome.rejected,
        eventType: eventType,
        profileName: profile.name,
        matchedRoleName: decision.rule.role.name
    );
  }
}