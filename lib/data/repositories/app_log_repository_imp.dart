import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:vrcma/data/mappers/app_log_mapper.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';
import 'package:vrcma/domain/repositories/i_app_log_repository.dart';

class AppLogRepositoryImp implements IAppLogRepository {
  final Database _db;
  final StreamController<void> _logUpdatesController = StreamController<void>.broadcast();
  AppLogRepositoryImp(this._db);
  
  @override
  Stream<void> watchLogs() => _logUpdatesController.stream;
  
  @override
  Future<void> saveLog(AppLog log) async {
      final dbMap = AppLogMapper().toDatabaseMap(log);
      await _db.insert('app_logs', dbMap);
      _logUpdatesController.add(null);
  }
  
  @override
  Future<List<AppLog>> getLogs({
    int limit = 50,
    int offset = 0,
    LogCategory? category,
    LogSeverity? severity,
    String? search,
  }) async {
    final List<String> conditions = [];
    final List<dynamic> args = [];

    if (category != null) {
      conditions.add('category = ?');
      args.add(category.name);
    }

    if (severity != null) {
      conditions.add('level = ?');
      args.add(severity.name);
    }

    if (search != null && search.trim().isNotEmpty) {
      conditions.add('(message LIKE ? OR details LIKE ? OR metadata LIKE ?)');
      final searchPattern = '%${search.trim()}%';
      args.addAll([searchPattern, searchPattern, searchPattern]);
    }

    final whereClause = conditions.isEmpty ? '' : 'WHERE ${conditions.join(" AND ")}';

    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT * FROM app_logs
      $whereClause
      ORDER BY timestamp DESC
      LIMIT ? OFFSET?
    ''', [...args, limit, offset]);

    final mapper = AppLogMapper();
    return maps.map((m) => mapper.fromDatabaseMap(m)).toList();
  }

  @override
  Future<void> clearAllLogs() async {
    await _db.delete('app_logs');
    _logUpdatesController.add(null);
  }
}