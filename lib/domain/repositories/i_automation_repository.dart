import 'package:vrcma/domain/entities/automation/invitation_type.dart';

abstract class IAutomationRepository {
  /// Stream that emits new invitation requests in real-time.
  Stream<InvitationType> watchInvitations();
  
  /// Accepts a specific request invitation.
  Future<void> acceptRequestInvitation(RequestInvite requestInvite, int? slot);
  
  /// Accepts a specific invite
  Future<void> acceptInvitation(InviteReceived invite);
  
  /// Rejects a notification (invite or request invite)
  Future<void> rejectNotificationWithMessage(InvitationType notification, int slot);

  /// Dismisses a notification (invite or request invite) without response
  Future<void> dismissNotification(InvitationType notification);

  /// Updates a specific message slot.
  /// Returns the number of minutes remaining if in cooldown (429), or 0 if success.
  Future<int> updateVrcMessageSlot({
    required String userId,
    required String messageType,
    required int slot,
    required String content
  });
}

