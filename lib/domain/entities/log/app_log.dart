import 'package:equatable/equatable.dart';

/// Categorizes the origin of the loggin record.
enum LogCategory {
  invitation,
  status,
  calendar,
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

sealed class LogMetadata extends Equatable {
  const LogMetadata();

  Map<String, dynamic> toJson();

  factory LogMetadata.fromJson(LogCategory category, Map<String, dynamic> json) {
    return switch (category) {
      LogCategory.invitation => InvitationLogMetadata.fromJson(json),
      LogCategory.status => StatusLogMetadata.fromJson(json),
      LogCategory.calendar => CalendarLogMetadata.fromJson(json),
      LogCategory.system => SystemLogMetadata.fromJson(json),
    };
  }
}

class InvitationLogMetadata extends LogMetadata {
  final String senderId;
  final String senderName;
  final String senderAvatarUrl;
  final String action; // 'ACCEPT' | 'REJECT' | 'IGNORED'
  final String invitationType; // 'INVITE' | 'REQUEST' | 'FRIEND_REQUEST'
  final String? appliedRule;

  const InvitationLogMetadata({
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.action,
    required this.invitationType,
    this.appliedRule,
  });

  @override
  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatarUrl': senderAvatarUrl,
    'action': action,
    'invitationType': invitationType,
    if (appliedRule != null) 'appliedRule': appliedRule,
  };

  factory InvitationLogMetadata.fromJson(Map<String, dynamic> json) {
    return InvitationLogMetadata(
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      senderAvatarUrl: json['senderAvatarUrl'] as String? ?? '',
      action: json['action'] as String? ?? 'IGNORED',
      invitationType: json['invitationType'] as String? ?? 'INVITE',
      appliedRule: json['appliedRule'] as String?,
    );
  }

  @override
  List<Object?> get props => [senderId, senderName, senderAvatarUrl, action, invitationType, appliedRule];
}

class StatusLogMetadata extends LogMetadata {
  final int? profileId;
  final String status;
  final String description;

  const StatusLogMetadata({
    this.profileId,
    required this.status,
    required this.description,
  });

  @override
  Map<String, dynamic> toJson() => {
    if (profileId != null) 'profileId': profileId,
    'status': status,
    'description': description,
  };

  factory StatusLogMetadata.fromJson(Map<String, dynamic> json) {
    return StatusLogMetadata(
      profileId: json['profileId'] as int?,
      status: json['status'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [profileId, status, description];
}

class CalendarLogMetadata extends LogMetadata {
  final int? ruleId;
  final String ruleName;
  final String? eventId;
  final DateTime? occurrenceUtc;
  final String? groupId;

  const CalendarLogMetadata({
    this.ruleId,
    required this.ruleName,
    this.eventId,
    this.occurrenceUtc,
    this.groupId,
  });

  @override
  Map<String, dynamic> toJson() => {
    if (ruleId != null) 'ruleId': ruleId,
    'ruleName': ruleName,
    if (eventId != null) 'eventId': eventId,
    if (occurrenceUtc != null) 'occurrenceUtc': occurrenceUtc!.toIso8601String(),
    if (groupId != null) 'groupId': groupId,
  };

  factory CalendarLogMetadata.fromJson(Map<String, dynamic> json) {
    return CalendarLogMetadata(
      ruleId: json['ruleId'] as int?,
      ruleName: json['ruleName'] as String? ?? '',
      eventId: json['eventId'] as String?,
      occurrenceUtc: json['occurrenceUtc'] != null ? DateTime.tryParse(json['occurrenceUtc'] as String) : null,
      groupId: json['groupId'] as String?,
    );
  }

  @override
  List<Object?> get props => [ruleId, ruleName, eventId, occurrenceUtc, groupId];
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