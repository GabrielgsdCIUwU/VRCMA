import 'package:sqflite/sqflite.dart';
import 'package:vrcma/domain/repositories/i_group_permission_cache_repository.dart';

class GroupPermissionCacheRepositoryImp implements IGroupPermissionCacheRepository {
  final Database _db;
  static const Duration _cacheExpiration = Duration(hours: 48);

  GroupPermissionCacheRepositoryImp(this._db);

  @override
  Future<bool> hasValidCachedPermission(String userId, String groupId) async {
    final results = await _db.query(
      'group_permissions_cache',
      where: 'group_id = ? AND user_id = ?',
      whereArgs: [groupId, userId],
    );

    if (results.isEmpty) return false;

    final data = results.first;
    final hasPermission = (data['has_permission'] as int) == 1;
    if (!hasPermission) return false;

    final validatedAtStr = data['validated_at'] as String;
    final validatedAt = DateTime.parse(validatedAtStr);

    final now = DateTime.now().toUtc();
    final isValid = now.difference(validatedAt) <= _cacheExpiration;

    if (!isValid) {
      await _db.delete(
        'group_permissions_cache',
        where: 'group_id = ? AND user_id = ?',
        whereArgs: [groupId, userId],
      );
      return false;
    }

    return true;
  }

  @override
  Future<void> savePermissionCache(String userId, String groupId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await _db.execute('''
      INSERT INTO group_permissions_cache (group_id, user_id, has_permission, validated_at)
      VALUES (?, ?, 1, ?)
      ON CONFLICT(group_id, user_id) DO UPDATE SET
        has_permission = 1,
        validated_at = excluded.validated_at
    ''', [groupId, userId, now]);
  }
}
