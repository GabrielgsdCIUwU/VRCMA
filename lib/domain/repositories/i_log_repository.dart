import 'package:vrcma/domain/entities/automation/automation_log.dart';

abstract class ILogRepository {
  Future<void> saveLog({
    required String vrcUserId,
    required String displayName,
    required String avatarUrl,
    required String invitationType,
    required String action,
    required String appliedRule
  });
  
  Future<List<AutomationLog>> getLogs({int limit = 50, int offset = 0, String? search});
}