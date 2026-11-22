import 'package:vrcma/domain/entities/log/app_log.dart';

/// Repository contract for retrieving and persisting unified log records.
abstract interface class IAppLogRepository {
  Future<void> saveLog(AppLog log);
  
  Future<List<AppLog>> getLogs({
    int limit = 50, 
    int offset = 0,
    LogCategory? category,
    LogSeverity? severity, 
    String? search
  });

  Future<void> clearAllLogs();
  
  /// Stream that emits whenever new logs are inserted or cleared
  Stream<void> watchLogs();
}