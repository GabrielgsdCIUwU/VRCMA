import 'package:equatable/equatable.dart';

abstract class VrcAutomationEvent extends Equatable {
  const VrcAutomationEvent();

  @override
  List<Object?> get props => [];
}

abstract class IncomingUserEvent extends VrcAutomationEvent {
  final String id;
  final String senderId;
  final String senderName;
  final List<String> senderTags;
  final String avatarUrl;

  const IncomingUserEvent({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderTags,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, senderId, senderName, senderTags, avatarUrl];
}

/// When someone wants to join your world.
class RequestInviteEvent extends IncomingUserEvent {
  const RequestInviteEvent({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.senderTags,
    required super.avatarUrl,
  });
}

/// When someone invites you to join their world.
class InviteReceivedEvent extends IncomingUserEvent {
  const InviteReceivedEvent({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.senderTags,
    required super.avatarUrl,
  });
}

/// When someone sends you a friend request.
class FriendRequestReceivedEvent extends IncomingUserEvent {
  const FriendRequestReceivedEvent({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.senderTags,
    required super.avatarUrl,
  });
}

/// Emitted when a user profile (status, location, display name) is updated.
class UserProfileUpdatedEvent extends VrcAutomationEvent {
  final String userId;
  final String displayName;
  final String status;
  final String statusDescription;

  const UserProfileUpdatedEvent({
    required this.userId,
    required this.displayName,
    required this.status,
    required this.statusDescription,
  });

  @override
  List<Object?> get props => [userId, displayName, status, statusDescription];
}

/// Emitted when a user transitions to a different world.
class UserLocationUpdatedEvent extends VrcAutomationEvent {
  final String userId;
  final String location;

  const UserLocationUpdatedEvent({
    required this.userId,
    required this.location,
  });

  @override
  List<Object?> get props => [userId, location];
}
