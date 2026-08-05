import 'dart:convert';

import 'package:vrcma/domain/entities/log/app_log.dart';
import 'package:vrcma/domain/mappers/i_database_mapper.dart';
import 'package:timezone/timezone.dart' as tz;


class AppLogMapper implements IDatabaseMapper<AppLog> {
  @override
  AppLog fromDatabaseMap(Map<String, dynamic> row) {
    final utcTimestamp = DateTime.parse(row['timestamp'] as String).toUtc();
    final localTimestamp = tz.TZDateTime.from(utcTimestamp, tz.local);

    Map<String, dynamic> metadataMap = const {};
    final rawMetadata = row['metadata'] as String?;
    if (rawMetadata != null && rawMetadata.isNotEmpty) {
      try {
        metadataMap = jsonEncode(rawMetadata) as Map<String, dynamic>;
      } catch (_) {}
    }

    return AppLog(
      id: row['id'] as int?,
      timestamp: localTimestamp,
      category: LogCategory.fromString(row['category'] as String),
      severity: LogSeverity.fromString(row['level'] as String),
      message: row['message'] as String,
      details: row['details'] as String?,
      metadata: metadataMap,
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(AppLog entity) {
    return {
      if (entity.id != null) 'id': entity.id,
      'timestamp': entity.timestamp.toUtc().toIso8601String(),
      'category': entity.category.name,
      'level': entity.severity.name,
      'message': entity.message,
      'details': entity.details,
      'metadata': jsonEncode(entity.metadata),
    };
  }
}