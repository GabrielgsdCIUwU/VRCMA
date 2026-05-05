import 'package:collection/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';
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
          'target_languages': profile.fallbackTags.map((t) => t.id).join(','),
          'is_language_filter_enabled': profile.fallbackTagsAction.index,
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
          'invite_message_id': rule.inviteResponseMessage?.id,
          'request_message_id': rule.requestResponseMessage?.id,
        });
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

    List<FilterProfile> result = [];

    for (var pMap in profileMaps) {
      final profileId = pMap['id'] as int;

      final List<Map<String, dynamic>> ruleMaps = await _db.rawQuery('''
        SELECT pr.*, r.name as role_name, 
          m1.id as inv_id, m1.content as inv_content, m1.slot_index as inv_slot, m1.last_updated as inv_date, m1.type as inv_type,
          m2.id as req_id, m2.content as req_content, m2.slot_index as req_slot, m2.last_updated as req_date, m2.type as req_type
        FROM profile_rules pr
        JOIN roles r ON pr.role_id = r.id
        LEFT JOIN custom_messages m1 ON pr.invite_message_id = m1.id
        LEFT JOIN custom_messages m2 ON pr.request_message_id = m2.id
        WHERE pr.profile_id = ?
        ORDER BY pr.priority ASC
      ''', [profileId]);

      final rules = ruleMaps.map((rMap) {
        return ProfileRule(
          id: rMap['id'],
          priority: rMap['priority'],
          fallbackGroup: rMap['fallback_group'],
          action: rMap['action'] == 'ACCEPT' ? RuleAction.accept : RuleAction.reject,
          role: Role(
            id: rMap['role_id'],
            name: rMap['role_name'],
          ),
          inviteResponseMessage: _extractMessage(rMap, 'inv'),
          requestResponseMessage: _extractMessage(rMap, 'req'),
        );
      }).toList();

      result.add(FilterProfile(
        id: profileId,
        name: pMap['name'],
        isActive: pMap['is_active'] == 1,
        rules: rules,
        fallbackTags: (pMap['target_languages'] as String?)
          ?.split(',')
          .where((e) => e.trim().isNotEmpty)
          .map((id)  => VrcTag.allTags.firstWhereOrNull((t) => t.id == id.trim()))
          .nonNulls
          .toList() ?? [],
        fallbackTagsAction: FallbackTagAction.values[pMap['is_language_filter_enabled'] as int? ?? 0],
      ));
    }

    return result;
  }
  
  CustomMessage? _extractMessage(Map<String, dynamic> row, String prefix) {
    if (row['${prefix}_id'] == null) return null;
    return CustomMessage(
      id: row['${prefix}_id'],
      content: row['${prefix}_content'],
      type: VrcMessageType.fromString(row['${prefix}_type']),
      slotIndex: row['${prefix}_slot'],
      lastUpdated: DateTime.parse(row['${prefix}_date']),
    );
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

