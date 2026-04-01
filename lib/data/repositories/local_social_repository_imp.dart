import 'package:sqflite/sqflite.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';

class LocalSocialRepositoryImp implements ILocalSocialRepository {
  final Database _db;
  
  LocalSocialRepositoryImp(this._db);
  
  @override
  Future<List<Role>> getAllAvailableRoles() async {
    final List<Map<String, dynamic>> maps = await _db.query('roles');
    return maps.map((m) => Role(
      id: m['id'] as int,
      name: m['name'] as String,
    )).toList();
  }
  
  @override
  Future<List<Role>> getRolesForUser(String userId) async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT r.* FROM roles r
      INNER JOIN friend_roles fr ON r.id = fr.role_id
      WHERE fr.vrc_user_id = ?
    ''', [userId]);
    
    return maps.map((m) => Role(
      id: m['id'] as int,
      name: m['name'] as String
    )).toList();
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
    return await _db.insert('roles', {'name': name});
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
}