import 'dart:isolate';

import 'package:sqflite/sqflite.dart';
import 'package:vrcma/data/mappers/filter_profile_mapper.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';

class ProfileRepositoryImp implements IProfileRepository {
  final Database _db;

  ProfileRepositoryImp(this._db);

  @override
  Future<int> saveProfile(FilterProfile profile) async {
    return await _db.transaction((txn) async {
      final profileId = await txn.insert(
        'profiles',
        {
          if (profile.id != null) 'id': profile.id,
          'name': profile.name,
          'is_active': profile.isActive ? 1 : 0,
          'target_languages': profile.fallbackTags.map((t) => t.id).join(','),
          'is_language_filter_enabled': profile.fallbackTagsAction.index,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final targetProfileId = profile.id ?? profileId;

      await txn.delete('profile_rules',
          where: 'profile_id = ?',
          whereArgs: [targetProfileId]);

      for (var rule in profile.rules) {
        final ruleData = FilterProfileMapper.ruleToDatabaseMap(targetProfileId, rule);
        await txn.insert('profile_rules', ruleData);
      }

      return profileId;
    });
  }

  @override
  Future<List<FilterProfile>> getProfiles() async {
    final List<Map<String, dynamic>> profileMaps = await _db.rawQuery('''
      SELECT p.* 
      FROM profiles p
    ''');

    if (profileMaps.isEmpty) return [];

    final List<Map<String, dynamic>> allRulesMaps = await _db.rawQuery('''
      SELECT pr.*, r.name as role_name, 
        m1.id as inv_id, m1.content as inv_content, m1.slot_index as inv_slot, m1.last_updated as inv_date, m1.type as inv_type,
        m2.id as req_id, m2.content as req_content, m2.slot_index as req_slot, m2.last_updated as req_date, m2.type as req_type
      FROM profile_rules pr
      JOIN roles r ON pr.role_id = r.id
      LEFT JOIN custom_messages m1 ON pr.invite_message_id = m1.id
      LEFT JOIN custom_messages m2 ON pr.request_message_id = m2.id
      ORDER BY pr.priority ASC
    ''');

    return await Isolate.run(() => _mapProfilesInIsolate(profileMaps, allRulesMaps));
  }
  
  static List<FilterProfile> _mapProfilesInIsolate(
      List<Map<String, dynamic>> profileMaps,
      List<Map<String, dynamic>> allRulesMaps) {
        return profileMaps.map((pMap) {
          final profileId = pMap['id'] as int;
          final associatedRules = allRulesMaps.where((r) => r['profile_id'] == profileId);
          return FilterProfileMapper.fromDatabaseMaps(pMap, associatedRules);
        }).toList();
  }

  @override
  Future<void> deleteProfile(int id) async {
    await _db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> setProfileActiveStatus(int id, bool isActive) async {
    return await _db.transaction((txn) async {
      if (isActive) {
        await txn.update(
        'profiles',
        {'is_active': 0},
        where: 'is_active = ?',
        whereArgs: [1]
        );
      }

      await txn.update(
          'profiles',
          {'is_active': isActive ? 1 : 0},
          where: 'id = ?',
          whereArgs: [id]
      );
    });
  }
}

