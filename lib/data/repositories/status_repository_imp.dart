import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vrcma/data/mappers/status_profile_mapper.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/repositories/i_status_repository.dart';

class StatusRepositoryImp implements IStatusRepository {
  final Database _db;
  StatusRepositoryImp(this._db);

  @override
  Future<List<StatusProfile>> getStatusProfiles() async {
    final List<Map<String, dynamic>> profileMaps = await _db.query('status_profiles');
    
    final List<StatusProfile> result = [];

    for (var pMap in profileMaps) {
      final int profileId = pMap['id'] as int;

      final rulesMaps = await _db.query(
        'status_rules',
        where: 'profile_id = ?',
        whereArgs: [profileId],
        orderBy: 'priority ASC',
      );

     result.add(StatusProfileMapper.fromDatabaseMaps(pMap, rulesMaps));
    }
    return result;
  }

  @override
  Future<int> saveStatusProfile(StatusProfile profile) async {
    return await _db.transaction((txn) async {
      final profileId = await txn.insert(
        'status_profiles',
        {
          if (profile.id != null) 'id': profile.id,
          'name': profile.name,
          'is_active': profile.isActive ? 1 : 0,
          'fallback_status': profile.fallbackStatus.apiValue,
          'fallback_template': profile.fallbackTemplate,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final targetId = profile.id ?? profileId;

      await txn.delete('status_rules', where: 'profile_id = ?', whereArgs: [targetId]);

      for (var rule in profile.rules) {
        final ruleData = StatusProfileMapper.ruleToDatabaseMap(targetId, rule);
        await txn.insert('status_rules', ruleData);
      }
      return targetId;
    });
  }

  @override
  Future<void> deleteStatusProfile(int id) async {
    await _db.delete('status_profiles', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> setProfileActive(int id, bool isActive) async {
    await _db.transaction((txn) async {
      if (isActive) {
        await txn.update('status_profiles', {'is_active': 0}, where: 'is_active = 1');
      }
      await txn.update(
        'status_profiles', 
        {'is_active': isActive ? 1 : 0}, 
        where: 'id = ?', 
        whereArgs: [id]
      );
    });
  }

  @override
  Future<void> updateLastAppliedStatus(int profileId, StatusType status, String message) async {
    await _db.update(
      'status_profiles',
      {
        'last_applied_status': status.apiValue,
        'last_applied_message': message,
      },
      where: 'id = ?',
      whereArgs: [profileId],
    );
  }
}