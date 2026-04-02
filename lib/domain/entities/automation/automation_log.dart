import 'package:equatable/equatable.dart';

class AutomationLog extends Equatable {
  final int? id;
  final DateTime timestamp;
  final String senderId;
  final String senderName;
  final String senderAvatarUrl;
  final String invitationType;
  final String action;
  final String appliedRule;
  
  const AutomationLog({
    this.id,
    required this.timestamp,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.invitationType,
    required this.action,
    required this.appliedRule,
  });
  
  @override
  List<Object?> get props => [id, timestamp, senderId, action];
}