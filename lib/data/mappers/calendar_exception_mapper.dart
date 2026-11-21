import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/mappers/i_database_mapper.dart';

/// Maps [CalendarException] domain entities to and from SQLite row maps.
class CalendarExceptionMapper implements IDatabaseMapper<CalendarException> {
  @override
  CalendarException fromDatabaseMap(Map<String, dynamic> row) {
    final endDateRaw = row['exception_end_date'] as String?;
    return CalendarException(
      id: row['id'] as int?,
      automationId: row['automation_id'] as int?,
      exceptionDate: DateTime.parse(row['exception_date'] as String),
      exceptionEndDate: endDateRaw != null ? DateTime.parse(endDateRaw) : null,
      isCancelled: row['is_cancelled'] == 1,
      rescheduledTime: TimeOfDayValue.tryParse(row['rescheduled_time'] as String?),
      titleOverride: row['title_override'] as String?,
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(CalendarException entity) {
    return {
      if (entity.id != null) 'id': entity.id,
      if (entity.automationId != null) 'automation_id': entity.automationId,
      'exception_date': entity.exceptionDate.toIso8601String(),
      'exception_end_date': entity.exceptionEndDate?.toIso8601String(),
      'is_cancelled': entity.isCancelled ? 1 : 0,
      'rescheduled_time': entity.rescheduledTime?.formatted,
      'title_override': entity.titleOverride,
    };
  }
}