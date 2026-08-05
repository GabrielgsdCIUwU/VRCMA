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

/// Representation of a system wide diagnostic or business activity log.
class AppLog extends Equatable {
  final int? id;
  final DateTime timestamp;
  final LogCategory category;
  final LogSeverity severity;
  final String message;
  final String? details;
  final Map<String, dynamic> metadata;

  const AppLog({
    this.id,
    required this.timestamp,
    required this.category,
    required this.severity,
    required this.message,
    this.details,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [id, timestamp, category, severity, message, details, metadata];
}