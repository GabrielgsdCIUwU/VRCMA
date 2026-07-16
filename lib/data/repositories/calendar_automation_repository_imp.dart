import 'package:sqflite/sqflite.dart';
import 'package:vrcma/data/mappers/calendar_automation_mapper.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_ocurrence_run.dart';
import 'package:vrcma/domain/repositories/i_local_calendar_repository.dart';

class CalendarAutomationRepositoryImp implements ILocalCalendarRepository {
  final Database _db;

  CalendarAutomationRepositoryImp(this._db);

  @override
  Future<List<CalendarAutomationRule>> getActiveRules() async {
    final List<Map<String, dynamic>> ruleRows = await _db.query(
      'calendar_automations',
      where: 'is_active = ?',
      whereArgs: [1],
    );

    if (ruleRows.isEmpty) return const [];

    final rules = <CalendarAutomationRule>[];
    for (final row in ruleRows) {
      final automationId = row['id'] as int;

      final List<Map<String, dynamic>> exceptionRows = await _db.query(
        'calendar_automation_exceptions',
        where: 'automation_id = ?',
        whereArgs: [automationId],
      );

      final exceptions = exceptionRows.map((eRow) {
        return CalendarException(
          id: eRow['id'] as int?,
          automationId: eRow['automation_id'] as int?,
          exceptionDate: DateTime.parse(eRow['exception_date'] as String),
          isCancelled: eRow['is_cancelled'] == 1,
          rescheduledTime: eRow['rescheduled_time'] as String?,
          titleOverride: eRow['title_override'] as String?,
        );
      }).toList();

      rules.add(CalendarAutomationMapper.fromDatabaseMaps(row, exceptions));
    }

    return rules;
  }

  @override
  Future<int> saveRule(CalendarAutomationRule rule) async {
    return await _db.transaction((txn) async {
      final data = CalendarAutomationMapper.toDatabaseMap(rule);
      final ruleId = await txn.insert(
        'calendar_automations',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final targetRuleId = rule.id ?? ruleId;

      await txn.delete(
        'calendar_automation_exceptions',
        where: 'automation_id = ?',
        whereArgs: [targetRuleId],
      );

      for (final exception in rule.exceptions) {
        await txn.insert('calendar_automation_exceptions', {
          'automation_id': targetRuleId,
          'exception_date': exception.exceptionDate.toIso8601String(),
          'is_cancelled': exception.isCancelled ? 1 : 0,
          'rescheduled_time': exception.rescheduledTime,
          'title_override': exception.titleOverride,
        });
      }

      return targetRuleId;
    });
  }

  @override
  Future<void> deleteRule(int id) async {
    await _db.delete(
      'calendar_automations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<CalendarOcurrenceRun>> getPastRuns(int automationId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'calendar_automation_runs',
      where: 'automation_id = ?',
      whereArgs: [automationId],
    );

    return maps.map((row) {
      return CalendarOcurrenceRun(
        id: row['id'] as int?,
        automationId: row['automation_id'] as int?,
        calculatedOccurrenceUtc: DateTime.parse(row['calculated_occurrence_utc'] as String),
        createdVrcEventId: row['created_vrc_event_id'] as String,
        publishedAt: DateTime.parse(row['published_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> saveOccurrenceRun(CalendarOcurrenceRun run) async {
    await _db.insert(
      'calendar_automation_runs',
      {
        'automation_id': run.automationId,
        'calculated_occurrence_utc': run.calculatedOccurrenceUtc.toIso8601String(),
        'created_vrc_event_id': run.createdVrcEventId,
        'published_at': run.publishedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}