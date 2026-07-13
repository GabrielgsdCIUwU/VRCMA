import 'package:sqflite/sqflite.dart';
import 'package:vrcma/data/mappers/role_automation_mapper.dart';
import 'package:vrcma/data/mappers/role_mapper.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';

class LocalSocialRepositoryImp implements ILocalSocialRepository {
  final Database _db;
  
  LocalSocialRepositoryImp(this._db);
  
  @override
  Future<List<Role>> getAllAvailableRoles() async {
    final List<Map<String, dynamic>> maps = await _db.query('roles');
    return maps.map((m) => RoleMapper().fromDatabaseMap(m)).toList();
  }
  
  @override
  Future<List<Role>> getRolesForUser(String userId) async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT r.* FROM roles r
      INNER JOIN friend_roles fr ON r.id = fr.role_id
      WHERE fr.vrc_user_id = ?
    ''', [userId]);
    
    return maps.map((m) => RoleMapper().fromDatabaseMap(m)).toList();
  }
  
  @override
  Future<void> assignRoleToUser(String userId, int roleId) async {
    await _db.insert(
      'friend_roles',
      {
        'vrc_user_id': userId,
        'role_id': roleId
      },
      conflictAlgorithm: ConflictAlgorithm.ignore
    );
  }
  
  @override
  Future<void> removeRoleFromUser(String userId, int roleId) async {
    await _db.delete(
      'friend_roles',
      where: 'vrc_user_id = ? AND role_id = ?',
      whereArgs: [userId, roleId]
    );
  }
  
  @override
  Future<int> createRole(String name) async {
    try {
      return await _db.insert('roles', {'name': name});
    } catch (e) {
      if (e is DatabaseException && e.isUniqueConstraintError()) {
        throw 'A role with the name "$name" already exists.';
      }
      rethrow;
    }
  }
  
  @override
  Future<void> deleteRole(int roleId) async{
    await _db.delete(
        'roles', 
        where: 'id = ?', 
        whereArgs: [roleId]);
  }
  
  @override
  Future<int> getMemberCountForRole(int roleId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM friend_roles WHERE role_id = ?',
      [roleId]
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  @override
  Future<List<String>> getUserIdsByRole(int roleId) async {
    final maps = await _db.query(
      'friend_roles',
      columns: ['vrc_user_id'],
      where: 'role_id = ?',
      whereArgs: [roleId]
    );
    return maps.map((e) => e['vrc_user_id'] as String).toList();
  }
  
  @override
  Future<void> updateRoleName(int roleId, String newName) async {
    try {
      await _db.update(
          'roles',
          {'name': newName},
          where: 'id = ?',
          whereArgs: [roleId]
      );
    } catch (e) {
      if (e is DatabaseException && e.isUniqueConstraintError()) {
        throw 'A role with the name "$newName" already exists.';
      }
      rethrow;
    }
  }
  
  @override
  Future<void> syncRoleMembers(int roleId, Set<String> newUserIds) async {
    await _db.transaction((txn) async {
      await txn.delete(
        'friend_roles',
        where: 'role_id = ?',
        whereArgs: [roleId]
      );
      
      for (final userId in newUserIds) {
        await txn.insert(
          'friend_roles', {
            'vrc_user_id': userId,
            'role_id': roleId
        });
      }
    });
  }

  @override
  Future<List<RoleAutomation>> getRoleAutomations() async {
    final maps = await _db.rawQuery('''
      SELECT a.id, a.trigger_type, a.target_value, r.id as role_id, r.name as role_name
      FROM role_automations a
      LEFT JOIN automation_assigned_roles ar ON a.id = ar.automation_id
      LEFT JOIN roles r ON ar.role_id = r.id
    ''');

    final Map<int, List<Role>> tempAssignedRoles = {};
    final Map<int, Map<String, dynamic>> tempAutomationData = {};

    for (final row in maps) {
      final id = row['id'] as int;
      tempAutomationData[id] = row;

      if (row['role_id'] != null) {
        tempAssignedRoles.putIfAbsent(id, () => []).add(
          RoleMapper().fromDatabaseMap({
            'id': row['role_id'],
            'name': row['role_name'],
          }),
        );
      }
    }

    return tempAutomationData.entries.map((entry) {
      final row = entry.value;
      final id = entry.key;
      return RoleAutomationMapper.fromJoinRows(
        id,
        row['trigger_type'] as String,
        row['target_value'] as String?,
        tempAssignedRoles[id] ?? [],
      );
    }).toList();
  }

  @override
  Future<void> saveRoleAutomation(RoleAutomation automation) async {
    await _db.transaction((txn) async {
      final automationData = RoleAutomationMapper.toDatabaseMap(automation);
      final id = await txn.insert(
        'role_automations',
        automationData,
        conflictAlgorithm: ConflictAlgorithm.replace
      );

      final automationId = automation.id ?? id;

      await txn.delete('automation_assigned_roles',
        where: 'automation_id = ?',
        whereArgs: [automationId]
      );

      for (final role in automation.roles) {
        await txn.insert('automation_assigned_roles', {
          'automation_id': automationId,
          'role_id': role.id,
        });
      }
    });
  }

  @override
  Future<void> deleteRoleAutomation(int automationId) async {
    await _db.delete('role_automations', where: 'id = ?', whereArgs: [automationId]);
  }

  @override
  Future<List<String>> getKnownUserIds() async {
    final maps = await _db.query('vrc_users', columns: ['user_id']);
    return maps.map((e) => e['user_id'] as String).toList();
  }

  @override
  Future<void> saveKnownUsers(List<VrcUser> userIds) async {
    final batch = _db.batch();
    final now = DateTime.now().toIso8601String();
    for (final user in userIds) {
      batch.rawInsert('''
        INSERT INTO vrc_users (user_id, display_name, avatar_url, last_updated)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(user_id) DO UPDATE SET
          display_name = excluded.display_name,
          avatar_url = excluded.avatar_url,
          last_updated = excluded.last_updated
      ''', [user.id, user.displayName, user.avatarUrl, now]);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> assignMultipleRoles(Map<String, Set<int>> userRoles) async {
    final batch = _db.batch();
    
    for (final entry in userRoles.entries) {
      final userId = entry.key;
      final roleIds = entry.value;
      
      for (final roleId in roleIds) {
        batch.insert('friend_roles', {
          'vrc_user_id': userId,
          'role_id': roleId
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
    
    await batch.commit(noResult: true);
  }
}