import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:vrcma/domain/mappers/i_database_mapper.dart';

/// Maps [CalendarOccurrenceRun] historical records to and from SQLite row maps.
class CalendarOccurrenceRunMapper implements IDatabaseMapper<CalendarOccurrenceRun> {
  @override
  CalendarOccurrenceRun fromDatabaseMap(Map<String, dynamic> row) {
    return CalendarOccurrenceRun(
      id: row['id'] as int?,
      automationId: row['automation_id'] as int?,
      calculatedOccurrenceUtc:
      DateTime.parse(row['calculated_occurrence_utc'] as String),
      createdVrcEventId: row['created_vrc_event_id'] as String,
      publishedAt: DateTime.parse(row['published_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(CalendarOccurrenceRun entity) {
    return {
      if (entity.id != null) 'id': entity.id,
      if (entity.automationId != null) 'automation_id': entity.automationId,
      'calculated_occurrence_utc':
      entity.calculatedOccurrenceUtc.toUtc().toIso8601String(),
      'created_vrc_event_id': entity.createdVrcEventId,
      'published_at': entity.publishedAt.toUtc().toIso8601String(),
    };
  }
}