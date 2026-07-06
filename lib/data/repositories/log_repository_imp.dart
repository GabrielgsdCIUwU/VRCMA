import 'package:sqflite/sqflite.dart';
import 'package:vrcma/domain/entities/automation/automation_log.dart';
import 'package:vrcma/domain/repositories/i_log_repository.dart';

class LogRepositoryImp implements ILogRepository {
  final Database _db;
  LogRepositoryImp(this._db);
  
  @override
  Future<void> saveLog({
    required String vrcUserId,
    required String displayName,
    required String avatarUrl,
    required String invitationType,
    required String action,
    required String appliedRule
  }) async {
      await _db.transaction((txn) async {
        await txn.rawInsert('''
          INSERT INTO vrc_users (user_id, display_name, avatar_url, last_updated)
          VALUES (?, ?, ?, ?)
          ON CONFLICT(user_id) DO UPDATE SET
            display_name = excluded.display_name,
            avatar_url = excluded.avatar_url,
            last_updated = excluded.last_updated
        ''', [vrcUserId, displayName, avatarUrl, DateTime.now().toIso8601String()]);
        
        final user = await txn.query(
          'vrc_users',
          columns: ['id'],
          where: 'user_id = ?',
          whereArgs: [vrcUserId]
        );
        
        final int userLocalId = user.first['id'] as int;
        
        await txn.insert('logs', {
          'timestamp': DateTime.now().toIso8601String(),
          'user_local_id': userLocalId,
          'invitation_type': invitationType,
          'action': action,
          'applied_rule': appliedRule
        });
      });
  }
  
  @override
  Future<List<AutomationLog>> getLogs({int limit = 50, int offset = 0, String? search}) async {
    final String whereClause = search != null ? "WHERE u.display_name LIKE ? OR l.applied_rule LIKE ?" : "";
    final List<dynamic> whereArgs = search != null ? ['%$search%', '%$search%'] : [];
    
    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT l.*, u.user_id, u.display_name, u.avatar_url
      FROM logs as l
      INNER JOIN vrc_users as u ON l.user_local_id = u.id
      $whereClause
      ORDER BY l.timestamp DESC
      LIMIT ? OFFSET ?
    ''', [...whereArgs, limit, offset]);
    
    return maps.map((m) {
      final rawAppliedRule = m['applied_rule'] as String? ?? '';
      
      final parts = rawAppliedRule.split(':');
      final profileName = parts.isNotEmpty ? parts[0] : 'Default Profile';
      final matchedRoleName = parts.length > 1 ? parts[1] : null;

      return AutomationLog(
        id: m['id'],
        senderId: m['user_id'],
        timestamp: DateTime.parse(m['timestamp']),
        senderName: m['display_name'],
        senderAvatarUrl: m['avatar_url'] ?? '',
        invitationType: LogEventType.fromString(m['invitation_type'] as String? ?? 'INVITE'),
        action: LogActionOutcome.fromString(m['action'] as String? ?? 'IGNORED'),
        profileName: profileName,
        matchedRoleName: matchedRoleName,
    );
    }).toList();
  }
}