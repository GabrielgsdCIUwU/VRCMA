import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';

/// Categorizes the origin of the loggin record.
enum LogCategory {
  invitation,
  status,
  calendar,
  social,
  auth,
  system;

  static LogCategory fromString(String value) {
    return LogCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => LogCategory.system
    );
  }
}

/// Defines the importance of the logged activity.
enum LogSeverity {
  info,
  warning,
  error;

  static LogSeverity fromString(String value) {
    return LogSeverity.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => LogSeverity.info,
    );
  }
}

/// Supported action outcomes for invitation automations.
enum InvitationActionOutcome {
  accepted,
  rejected,
  ignored;

  static InvitationActionOutcome fromString(String value) {
    return InvitationActionOutcome.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => InvitationActionOutcome.ignored
    );
  }
}

/// Types of user incoming invitation events.
enum IncomingEventType {
  invite,
  request,
  friendRequest;

  static IncomingEventType fromString(String value) {
    return IncomingEventType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => IncomingEventType.invite,
    );
  }
}

/// Reasons triggering automatic role assignment.
enum SocialAssignmentTrigger {
  newFriend,
  tagMatch;

  static SocialAssignmentTrigger fromString(String value) {
    return SocialAssignmentTrigger.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SocialAssignmentTrigger.newFriend,
    );
  }
}

/// Authentication events registered in the system.
enum AuthLogEvent {
  loginSuccess,
  loginFailed,
  twoFactorRequested,
  loggedOut,
  sessionExpired;

  static AuthLogEvent fromString(String value) {
    return AuthLogEvent.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AuthLogEvent.loginSuccess,
    );
  }
}

sealed class LogMetadata extends Equatable {
  const LogMetadata();

  Map<String, dynamic> toJson();

  factory LogMetadata.fromJson(LogCategory category, Map<String, dynamic> json) {
    return switch (category) {
      LogCategory.invitation => InvitationLogMetadata.fromJson(json),
      LogCategory.status => StatusLogMetadata.fromJson(json),
      LogCategory.calendar => CalendarLogMetadata.fromJson(json),
      LogCategory.social => SocialLogMetadata.fromJson(json),
      LogCategory.auth => AuthLogMetadata.fromJson(json),
      LogCategory.system => SystemLogMetadata.fromJson(json),
    };
  }
}

class InvitationLogMetadata extends LogMetadata {
  final String senderId;
  final String senderName;
  final String senderAvatarUrl;
  final InvitationActionOutcome action;
  final IncomingEventType eventType;
  final String profileName;
  final String? matchedRoleName;

  const InvitationLogMetadata({
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.action,
    required this.eventType,
    required this.profileName,
    this.matchedRoleName,
  });

  @override
  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatarUrl': senderAvatarUrl,
    'action': action.name,
    'eventType': eventType.name,
    'profileName': profileName,
    if (matchedRoleName != null) 'matchedRoleName': matchedRoleName,
  };

  factory InvitationLogMetadata.fromJson(Map<String, dynamic> json) {
    return InvitationLogMetadata(
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      senderAvatarUrl: json['senderAvatarUrl'] as String? ?? '',
      action: InvitationActionOutcome.fromString(json['action'] as String? ?? ''),
      eventType: IncomingEventType.fromString(json['eventType'] as String? ?? ''),
      profileName: json['profileName'] as String? ?? json['appliedRule'] as String? ?? '',
      matchedRoleName: json['matchedRoleName'] as String?,
    );
  }

  @override
  List<Object?> get props => [senderId, senderName, senderAvatarUrl, action, eventType, profileName, matchedRoleName];
}

class StatusLogMetadata extends LogMetadata {
  final int? profileId;
  final String? profileName;
  final StatusType status;
  final String description;

  const StatusLogMetadata({
    this.profileId,
    this.profileName,
    required this.status,
    required this.description,
  });

  @override
  Map<String, dynamic> toJson() => {
    if (profileId != null) 'profileId': profileId,
    if (profileName != null) 'profileName': profileName,
    'status': status.apiValue,
    'description': description,
  };

  factory StatusLogMetadata.fromJson(Map<String, dynamic> json) {
    return StatusLogMetadata(
      profileId: json['profileId'] as int?,
      profileName: json['profileName'] as String?,
      status: StatusType.fromString(json['status'] as String? ?? ''),
      description: json['description'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [profileId, profileName, status, description];
}

class CalendarLogMetadata extends LogMetadata {
  final int? ruleId;
  final String ruleName;
  final String? eventTitle;
  final String? eventId;
  final DateTime? occurrenceUtc;
  final String? groupId;

  const CalendarLogMetadata({
    this.ruleId,
    required this.ruleName,
    this.eventTitle,
    this.eventId,
    this.occurrenceUtc,
    this.groupId,
  });

  @override
  Map<String, dynamic> toJson() => {
    if (ruleId != null) 'ruleId': ruleId,
    'ruleName': ruleName,
    if (eventTitle != null) 'eventTitle': eventTitle,
    if (eventId != null) 'eventId': eventId,
    if (occurrenceUtc != null) 'occurrenceUtc': occurrenceUtc!.toIso8601String(),
    if (groupId != null) 'groupId': groupId,
  };

  factory CalendarLogMetadata.fromJson(Map<String, dynamic> json) {
    return CalendarLogMetadata(
      ruleId: json['ruleId'] as int?,
      ruleName: json['ruleName'] as String? ?? '',
      eventTitle: json['eventTitle'] as String?,
      eventId: json['eventId'] as String?,
      occurrenceUtc: json['occurrenceUtc'] != null ? DateTime.tryParse(json['occurrenceUtc'] as String) : null,
      groupId: json['groupId'] as String?,
    );
  }

  @override
  List<Object?> get props => [ruleId, ruleName, eventTitle, eventId, occurrenceUtc, groupId];
}

class SocialLogMetadata extends LogMetadata {
  final String targetUserId;
  final String targetUserName;
  final List<String> assignedRoleNames;
  final SocialAssignmentTrigger trigger;

  const SocialLogMetadata({
    required this.targetUserId,
    required this.targetUserName,
    required this.assignedRoleNames,
    required this.trigger,
  });

  @override
  Map<String, dynamic> toJson() => {
    'targetUserId': targetUserId,
    'targetUserName': targetUserName,
    'assignedRoleNames': assignedRoleNames,
    'trigger': trigger.name,  
  };

  factory SocialLogMetadata.fromJson(Map<String, dynamic> json) {
    return SocialLogMetadata(
      targetUserId: json['targetUserId'] as String? ?? '',
      targetUserName: json['targetUserName'] as String? ?? '',
      assignedRoleNames: List<String>.from(json['assignedRoleNames'] as List? ?? const []),
      trigger: SocialAssignmentTrigger.fromString(json['trigger'] as String? ?? ''),
    );
  }

  @override
  List<Object?> get props => [targetUserId, targetUserName, assignedRoleNames, trigger];
}

class AuthLogMetadata extends LogMetadata {
  final String userId;
  final String displayName;
  final AuthLogEvent event;

  const AuthLogMetadata({
    required this.userId,
    required this.displayName,
    required this.event
  });

  @override
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'displayName': displayName,
    'event': event.name,
  };

  factory AuthLogMetadata.fromJson(Map<String, dynamic> json) {
    return AuthLogMetadata(
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      event: AuthLogEvent.fromString(json['event'] as String? ?? ''),
    );
  }

  @override
  List<Object?> get props => [userId, displayName, event];
}

class SystemLogMetadata extends LogMetadata {
  final Map<String, dynamic> data;

  const SystemLogMetadata([this.data = const {}]);

  @override
  Map<String, dynamic> toJson() => data;

  factory SystemLogMetadata.fromJson(Map<String, dynamic> json) => SystemLogMetadata(json);

  @override
  List<Object?> get props => [data];
}

/// Representation of a system wide diagnostic or business activity log.
class AppLog extends Equatable {
  final int? id;
  final DateTime timestamp;
  final LogCategory category;
  final LogSeverity severity;
  final String message;
  final String? details;
  final LogMetadata metadata;

  const AppLog({
    this.id,
    required this.timestamp,
    required this.category,
    required this.severity,
    required this.message,
    this.details,
    required this.metadata,
  });

  @override
  List<Object?> get props => [id, timestamp, category, severity, message, details, metadata];
}