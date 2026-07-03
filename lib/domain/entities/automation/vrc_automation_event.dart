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