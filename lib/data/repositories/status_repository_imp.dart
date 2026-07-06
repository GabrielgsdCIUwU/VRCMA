import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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

      final rules = rulesMaps.map((rMap) => StatusRule(
        id: rMap['id'] as int?,
        priority: rMap['priority'] as int,
        targetStatus: StatusType.fromString(rMap['target_status'] as String),
        messageTemplate: rMap['message_template'] as String?,
        conditionType: ConditionType.values.firstWhere(
          (e) => e.name == (rMap['condition_type'] as String)
        ),
        operator: RuleOperator.values.firstWhere(
          (e) => e.name == (rMap['operator'] as String)
        ),
        conditionValue: rMap['condition_value'] as String? ?? '',
      )).toList();

      result.add(StatusProfile(
        id: profileId,
        name: pMap['name'] as String,
        isActive: (pMap['is_active'] as int) == 1,
        fallbackStatus: StatusType.fromString(pMap['fallback_status'] as String),
        fallbackTemplate: pMap['fallback_template'] as String?,
        lastAppliedStatus: pMap['last_applied_status'] != null 
            ? StatusType.fromString(pMap['last_applied_status'] as String) 
            : null,
        lastAppliedMessage: pMap['last_applied_message'] as String?,
        rules: rules,
      ));
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
        await txn.insert('status_rules', {
          'profile_id': targetId,
          'priority': rule.priority,
          'target_status': rule.targetStatus.apiValue,
          'message_template': rule.messageTemplate,
          'condition_type': rule.conditionType.name,
          'operator': rule.operator.name,
          'condition_value': rule.conditionValue,
        });
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