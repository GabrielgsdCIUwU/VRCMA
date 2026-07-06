import 'package:dartz/dartz.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

abstract class IAutomationRepository {
  /// Stream emitting mapped real-time events processed by the pipeline.
  Stream<VrcAutomationEvent> watchAutomationEvents();
  
  /// Accepts a specific request invitation.
  Future<void> acceptRequestInvitation(RequestInviteEvent requestInvite, int? slot);
  
  /// Accepts a specific invite
  Future<void> acceptInvitation(InviteReceivedEvent invite);

  /// Accepts an incoming friend request.
  Future<void> acceptFriendRequest(FriendRequestReceivedEvent request);
  
  /// Rejects a notification (invite or request invite)
  Future<void> rejectNotificationWithMessage(IncomingUserEvent notification, int slot);

  /// Dismisses a notification (invite or request invite) without response
  Future<void> dismissNotification(IncomingUserEvent notification);

  /// Updates a specific message slot.
  /// Returns the number of minutes remaining if in cooldown (429), or 0 if success.
  Future<Either<Failure, void>> updateVrcMessageSlot({
    required String userId,
    required String messageType,
    required int slot,
    required String content,
    required VrcMessageType type,
  });
  
  /// Get all message slots by type
  Future<List<VrcRemoteMessage>> getRemoteVrcMessages(String userId, VrcMessageType type);
}

