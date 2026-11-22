import 'package:sqflite/sqflite.dart';
import 'package:vrcma/data/mappers/calendar_automation_mapper.dart';
import 'package:vrcma/data/mappers/calendar_exception_mapper.dart';
import 'package:vrcma/data/mappers/calendar_occurrence_run_mapper.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:vrcma/domain/error/calendar_domain_exception.dart';
import 'package:vrcma/domain/repositories/i_local_calendar_repository.dart';

/// SQLite implementation of [ILocalCalendarRepository] for calendar rules and runs.
class CalendarAutomationRepositoryImp implements ILocalCalendarRepository {
  final Database _db;
  final CalendarExceptionMapper _exceptionMapper;
  final CalendarOccurrenceRunMapper _runMapper;

  CalendarAutomationRepositoryImp(
      this._db, {
        CalendarExceptionMapper? exceptionMapper,
        CalendarOccurrenceRunMapper? runMapper,
      })  : _exceptionMapper = exceptionMapper ?? CalendarExceptionMapper(),
        _runMapper = runMapper ?? CalendarOccurrenceRunMapper();

  @override
  Future<List<CalendarAutomationRule>> getActiveRules() async {
    final rows = await _db.query(
      'calendar_automations',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return _hydrateRules(rows);
  }

  @override
  Future<List<CalendarAutomationRule>> getAllRules() async {
    final rows = await _db.query('calendar_automations');
    return _hydrateRules(rows);
  }

  @override
  Future<int> saveRule(CalendarAutomationRule rule) async {
    try {
      return await _db.transaction((txn) => _persistRule(txn, rule));
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw CalendarDomainException(DuplicateCalendarRuleNameError(rule.name));
      }
      rethrow;
    }
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
  Future<List<CalendarOccurrenceRun>> getPastRuns(int automationId) async {
    final rows = await _db.query(
      'calendar_automation_runs',
      where: 'automation_id = ?',
      whereArgs: [automationId],
    );
    return rows.map(_runMapper.fromDatabaseMap).toList();
  }

  @override
  Future<void> saveOccurrenceRun(CalendarOccurrenceRun run) async {
    final data = _runMapper.toDatabaseMap(run);
    await _db.rawInsert(
      '''
      INSERT INTO calendar_automation_runs (
        automation_id, calculated_occurrence_utc, created_vrc_event_id, published_at
      )
      VALUES (?, ?, ?, ?)
      ON CONFLICT(automation_id, calculated_occurrence_utc) DO UPDATE SET
        created_vrc_event_id = excluded.created_vrc_event_id,
        published_at = excluded.published_at
      ''',
      [
        data['automation_id'],
        data['calculated_occurrence_utc'],
        data['created_vrc_event_id'],
        data['published_at'],
      ],
    );
  }

  Future<List<CalendarAutomationRule>> _hydrateRules(
      List<Map<String, dynamic>> ruleRows,
      ) async {
    if (ruleRows.isEmpty) return const [];

    final rules = <CalendarAutomationRule>[];
    for (final row in ruleRows) {
      final automationId = row['id'] as int;
      final exceptions = await _loadExceptions(automationId);
      rules.add(CalendarAutomationMapper.fromDatabaseMaps(row, exceptions));
    }
    return rules;
  }

  Future<List<CalendarException>> _loadExceptions(int automationId) async {
    final rows = await _db.query(
      'calendar_automation_exceptions',
      where: 'automation_id = ?',
      whereArgs: [automationId],
    );
    return rows.map(_exceptionMapper.fromDatabaseMap).toList();
  }

  Future<int> _persistRule(Transaction txn, CalendarAutomationRule rule) async {
    final data = CalendarAutomationMapper.toDatabaseMap(rule);

    // Use UPDATE instead of ConflictAlgorithm.replace so ON DELETE CASCADE
    // does not purge historical calendar_automation_runs.
    final int targetRuleId;
    if (rule.id != null) {
      data.remove('id');
      await txn.update(
        'calendar_automations',
        data,
        where: 'id = ?',
        whereArgs: [rule.id],
      );
      targetRuleId = rule.id!;
    } else {
      targetRuleId = await txn.insert('calendar_automations', data);
    }

    await _replaceExceptions(txn, targetRuleId, rule.exceptions);
    return targetRuleId;
  }

  Future<void> _replaceExceptions(
      Transaction txn,
      int ruleId,
      List<CalendarException> exceptions,
      ) async {
    await txn.delete(
      'calendar_automation_exceptions',
      where: 'automation_id = ?',
      whereArgs: [ruleId],
    );

    for (final exception in exceptions) {
      final boundException = exception.copyWith(automationId: ruleId);
      final row = _exceptionMapper.toDatabaseMap(boundException);
      await txn.insert('calendar_automation_exceptions', row);
    }
  }
}