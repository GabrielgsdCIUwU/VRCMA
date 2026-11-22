import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';
import 'package:vrcma/domain/repositories/i_app_log_repository.dart';

/// Central domain service responsible for standardizing and dispatching system logs.
class AppLogger {
  final IAppLogRepository _repository;

  const AppLogger(this._repository);

  /// Records an incoming invitation automation event.
  Future<void> logInvitation({
    required String senderId,
    required String senderName,
    required String senderAvatarUrl,
    required InvitationActionOutcome action,
    required IncomingEventType eventType,
    required String profileName,
    String? matchedRoleName,
  }) {
    return _repository.saveLog(
      AppLog(
        timestamp: DateTime.now(),
        category: LogCategory.invitation,
        severity: action == InvitationActionOutcome.rejected ? LogSeverity.warning : LogSeverity.info,
        message: '',
        metadata: InvitationLogMetadata(
          senderId: senderId,
          senderName: senderName,
          senderAvatarUrl: senderAvatarUrl,
          action: action,
          eventType: eventType,
          profileName: profileName,
          matchedRoleName: matchedRoleName
        ),
      ),
    );
  }

  /// Records an automated status synchronization change or error.
  Future<void> logStatus({
    int? profileId,
    String? profileName,
    required StatusType status,
    required String description,
    LogSeverity severity = LogSeverity.info,
    String? details,
  }) {
    return _repository.saveLog(
      AppLog(
        timestamp: DateTime.now(),
        category: LogCategory.status,
        severity: severity,
        message: '',
        details: details,
        metadata: StatusLogMetadata(
          profileId: profileId,
          profileName: profileName,
          status: status,
          description: description,
        ),
      ),
    );
  }

  /// Records a calendar automation occurrence or error.
  Future<void> logCalendar({
    int? ruleId,
    required String ruleName,
    String? eventTitle,
    String? eventId,
    DateTime? occurrenceUtc,
    String? groupId,
    LogSeverity severity = LogSeverity.info,
    String? details,
  }) {
    return _repository.saveLog(
      AppLog(
        timestamp: DateTime.now(),
        category: LogCategory.calendar,
        severity: severity,
        message: '',
        details: details,
        metadata: CalendarLogMetadata(
          ruleId: ruleId,
          ruleName: ruleName,
          eventTitle: eventTitle,
          eventId: eventId,
          occurrenceUtc: occurrenceUtc,
          groupId: groupId,
        ),
      ),
    );
  }

  /// Records an automated role assignment to friends.
  Future<void> logSocialRoleAssignment({
    required String targetUserId,
    required String targetUserName,
    required List<String> assignedRoleNames,
    required SocialAssignmentTrigger trigger,
  }) {
    return _repository.saveLog(
      AppLog(
        timestamp: DateTime.now(),
        category: LogCategory.social,
        severity: LogSeverity.info,
        message: '',
        metadata: SocialLogMetadata(
          targetUserId: targetUserId,
          targetUserName: targetUserName,
          assignedRoleNames: assignedRoleNames,
          trigger: trigger,
        ),
      ),
    );
  }

  /// Records an authentication event (login, logout, session expiration).
  Future<void> logAuth({
    required String userId,
    required String displayName,
    required AuthLogEvent event,
    LogSeverity severity = LogSeverity.info,
    String? details,
  }) {
    return _repository.saveLog(
      AppLog(
        timestamp: DateTime.now(),
        category: LogCategory.auth,
        severity: severity,
        message: '',
        details: details,
        metadata: AuthLogMetadata(
          userId: userId,
          displayName: displayName,
          event: event
        ),
      ),
    );
  }

  /// Records an unclassified diagnostic or system message.
  Future<void> logSystem({
    required String message,
    LogSeverity severity = LogSeverity.info,
    String? details,
    Map<String, dynamic> metadata = const {},
  }) {
    return _repository.saveLog(
      AppLog(
        timestamp: DateTime.now(),
        category: LogCategory.system,
        severity: severity,
        message: message,
        details: details,
        metadata: SystemLogMetadata(metadata),
      ),
    );
  }
}