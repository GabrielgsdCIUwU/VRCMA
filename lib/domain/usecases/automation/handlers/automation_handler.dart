import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';
import 'package:vrcma/domain/services/app_logger.dart';
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
  final AppLogger logger;
  final ProcessInvitationUseCase useCase;

  BaseIncomingUserEventHandler({
    required this.automationRepository,
    required this.localSocialRepository,
    required this.profileRepository,
    required this.logger,
    required this.useCase,
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
    required InvitationActionOutcome action,
    required IncomingEventType eventType,
    required String profileName,
    String? matchedRoleName,
  }) async {
    return logger.logInvitation(
      senderId: event.senderId,
      senderName: event.senderName,
      senderAvatarUrl: event.avatarUrl,
      action: action,
      eventType: eventType,
      profileName: profileName,
      matchedRoleName: matchedRoleName
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
    required super.logger,
    required super.useCase,
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

      final eventType = event is RequestInviteEvent ? IncomingEventType.request : IncomingEventType.invite;

      if (decision == null) {
        await recordLog(
          event: event,
          action: InvitationActionOutcome.ignored,
          eventType: eventType,
          profileName: profile.name,
        );
        return;
      }

      final CustomMessage? messageToUse = switch (decision) {
        MatchedRuleDecision(:final rule) => event is InviteReceivedEvent
            ? rule.inviteResponseMessage
            : rule.requestResponseMessage,
        MatchedFallbackTagDecision() => null,
      };

      final matchedLabel = switch (decision) {
        MatchedRuleDecision(:final rule) => rule.role.name,
        MatchedFallbackTagDecision(:final tag) => tag.name,
      };

      final int? slotToUse = (messageToUse != null)
          ? await slotManager.prepareSlotForMessage(currentUserId, messageToUse)
          : null;

      if (decision.action == RuleAction.accept) {
        await _handleAccept(event, slotToUse);
      } else {
        await _handleReject(event, slotToUse);
      }

      await recordLog(
        event: event,
        action: decision.action == RuleAction.accept
            ? InvitationActionOutcome.accepted
            : InvitationActionOutcome.rejected,
        eventType: eventType,
        profileName: profile.name,
        matchedRoleName: matchedLabel,
      );
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
    required super.logger,
    required super.useCase,
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

    const eventType = IncomingEventType.friendRequest;

    if (decision == null) {
      await recordLog(
        event: event,
        action: InvitationActionOutcome.ignored,
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

    final matchedLabel = switch (decision) {
      MatchedRuleDecision(:final rule) => rule.role.name,
      MatchedFallbackTagDecision(:final tag) => tag.name,
    };

    await recordLog(
      event: event,
      action: decision.action == RuleAction.accept
        ? InvitationActionOutcome.accepted
        : InvitationActionOutcome.rejected,
        eventType: eventType,
        profileName: profile.name,
        matchedRoleName: matchedLabel
    );
  }
}