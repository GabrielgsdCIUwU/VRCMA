import 'package:equatable/equatable.dart';

enum LogActionOutcome {
  accepted,
  rejected,
  ignored;

  static LogActionOutcome fromString(String val) {
    return LogActionOutcome.values.firstWhere(
      (e) => e.name.toUpperCase() == val.toUpperCase(),
      orElse: () => LogActionOutcome.ignored,
    );
  }

  String get dbValue => name.toUpperCase();
}

enum LogEventType {
  invite,
  request,
  friendRequest;

  static LogEventType fromString(String val) {
    switch (val.toUpperCase()) {
      case 'INVITE':
        return LogEventType.invite;
      case 'REQUEST':
        return LogEventType.request;
      case 'FRIEND_REQUEST':
      default:
        return LogEventType.friendRequest;
    }
  }

  String get dbValue {
    switch (this) {
      case LogEventType.invite:
        return 'INVITE';
      case LogEventType.request:
        return 'REQUEST';
      case LogEventType.friendRequest:
        return 'FRIEND_REQUEST';
    }
  }
}

class AutomationLog extends Equatable {
  final int? id;
  final DateTime timestamp;
  final String senderId;
  final String senderName;
  final String senderAvatarUrl;
  final LogEventType invitationType;
  final LogActionOutcome action;
  final String profileName;
  final String? matchedRoleName;
  
  const AutomationLog({
    this.id,
    required this.timestamp,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.invitationType,
    required this.action,
    required this.profileName,
    this.matchedRoleName
  });
  
  @override
  List<Object?> get props => [id, timestamp, senderId, action, invitationType];
}