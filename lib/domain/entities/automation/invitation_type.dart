import 'package:equatable/equatable.dart';

/// Represents an incoming invitation request from VRChat.
class InvitationType extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final List<String> senderTags;
  
  const InvitationType({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderTags,
  });
  
  @override
  List<Object?> get props => [id, senderId, senderName, senderTags];
}

/// When someone wants to join your world.
class RequestInvite extends InvitationType {
  const RequestInvite({required super.id, required super.senderId, required super.senderName, required super.senderTags});
}

/// When someone invites you to join their world.
class InviteReceived extends InvitationType {
  const InviteReceived({required super.id, required super.senderId, required super.senderName, required super.senderTags});
}
