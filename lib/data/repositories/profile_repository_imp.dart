import 'package:sqflite/sqflite.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

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
          'default_role_id': profile.defaultRole?.id,
          'target_languages': '',
          'is_language_filter_enabled': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete('profile_rules',
          where: 'profile_id = ?',
          whereArgs: [profile.id ?? profileId]);

      for (var rule in profile.rules) {
        await txn.insert('profile_rules', {
          'profile_id': profile.id ?? profileId,
          'role_id': rule.role.id,
          'priority': rule.priority,
          'action': rule.action == RuleAction.accept ? 'ACCEPT' : 'REJECT',
          'fallback_group': rule.fallbackGroup,
          'message_id': rule.message?.id,
        });
      }

      return profileId;
    });
  }

  @override
  Future<List<FilterProfile>> getProfiles() async {
    final List<Map<String, dynamic>> profileMaps = await _db.rawQuery('''
      SELECT p.*, r.name as role_name 
      FROM profiles p
      LEFT JOIN roles r ON p.default_role_id = r.id
    ''');

    List<FilterProfile> result = [];

    for (var pMap in profileMaps) {
      final profileId = pMap['id'] as int;

      final List<Map<String, dynamic>> ruleMaps = await _db.rawQuery('''
        SELECT pr.*, r.name as role_name, m.content as msg_content,
          m.slot_index as msg_slot, m.last_updated as msg_date,
          m.type as msg_type
        FROM profile_rules pr
        JOIN roles r ON pr.role_id = r.id
        LEFT JOIN custom_messages m ON pr.message_id = m.id
        WHERE pr.profile_id = ?
        ORDER BY pr.priority ASC
      ''', [profileId]);

      final rules = ruleMaps.map((rMap) {

        CustomMessage? message;
        if (rMap['message_id'] != null) {
          message = CustomMessage(
            id: rMap['message_id'],
            content: rMap['msg_content'],
            type: VrcMessageType.fromString(rMap['msg_type']),
            slotIndex: rMap['msg_slot'],
            lastUpdated: DateTime.parse(rMap['msg_date']),
          );
        }

        return ProfileRule(
          id: rMap['id'],
          priority: rMap['priority'],
          fallbackGroup: rMap['fallback_group'],
          action: rMap['action'] == 'ACCEPT' ? RuleAction.accept : RuleAction.reject,
          role: Role(
            id: rMap['role_id'],
            name: rMap['role_name'],
          ),
          message: rMap['message_id'] != null
            ? CustomMessage(
            id: rMap['message_id'],
            content: rMap['msg_content'],
            type: VrcMessageType.values.firstWhere((e) => e.value == rMap['msg_type']),
            slotIndex: rMap['msg_slot'],
            lastUpdated: DateTime.parse(rMap['msg_date']),
          ) : null
        );
      }).toList();

      result.add(FilterProfile(
        id: profileId,
        name: pMap['name'],
        isActive: pMap['is_active'] == 1,
        rules: rules,
        defaultRole: pMap['default_role_id'] != null
            ? Role(id: pMap['default_role_id'], name: pMap['role_name'])
            : null,
      ));
    }

    return result;
  }

  @override
  Future<void> deleteProfile(int id) async {
    await _db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> setActiveProfile(int id) async {
    return await _db.transaction((txn) async {
      await txn.update(
        'profiles',
        {'is_active': 0},
        where: 'is_active = ?',
        whereArgs: [1]
      );

      await txn.update(
          'profiles',
          {'is_active': 1},
          where: 'id = ?',
          whereArgs: [id]
      );
    });
  }
}

