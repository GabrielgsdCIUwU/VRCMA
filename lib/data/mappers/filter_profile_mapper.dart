import 'package:collection/collection.dart';
import 'package:vrcma/data/mappers/custom_message_mapper.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';

class FilterProfileMapper {
  static FilterProfile fromDatabaseMaps(
    Map<String, dynamic> profileRow,
    Iterable<Map<String, dynamic>> ruleRows,
  ) {
    final profileId = profileRow['id'] as int;

    final rules = ruleRows.map((rMap) {
      return ProfileRule(
        id: rMap['id'] as int?,
        priority: rMap['priority'] as int,
        fallbackGroup: rMap['fallback_group'] as int?,
        action: rMap['action'] == 'ACCEPT' ? RuleAction.accept : RuleAction.reject,
        role: Role(
          id: rMap['role_id'] as int,
          name: rMap['role_name'] as String,
        ),
        inviteResponseMessage: rMap['invite_message_id'] != null 
            ? CustomMessageMapper().fromDatabaseMap(_extractPrefixedRow(rMap, 'inv')) 
            : null,
        requestResponseMessage: rMap['request_message_id'] != null 
            ? CustomMessageMapper().fromDatabaseMap(_extractPrefixedRow(rMap, 'req')) 
            : null,
      );
    }).toList();

    final targetLanguagesStr = profileRow['target_languages'] as String?;
    final fallbackTags = (targetLanguagesStr?.split(',') ?? [])
        .where((e) => e.trim().isNotEmpty)
        .map((id) => VrcTag.allTags.firstWhereOrNull((t) => t.id == id.trim()))
        .nonNulls
        .toList();

    return FilterProfile(
      id: profileId,
      name: profileRow['name'] as String,
      isActive: profileRow['is_active'] == 1,
      rules: rules,
      fallbackTags: fallbackTags,
      fallbackTagsAction: FallbackTagAction.values[profileRow['is_language_filter_enabled'] as int? ?? 0],
    );
  }

  static Map<String, dynamic> ruleToDatabaseMap(int profileId, ProfileRule rule) {
    return {
      'profile_id': profileId,
      'role_id': rule.role.id,
      'priority': rule.priority,
      'action': rule.action == RuleAction.accept ? 'ACCEPT' : 'REJECT',
      'fallback_group': rule.fallbackGroup,
      'invite_message_id': rule.inviteResponseMessage?.id,
      'request_message_id': rule.requestResponseMessage?.id,
    };
  }

  static Map<String, dynamic> _extractPrefixedRow(Map<String, dynamic> row, String prefix) {
    return {
      'id': row['${prefix}_id'],
      'content': row['${prefix}_content'],
      'type': row['${prefix}_type'],
      'slot_index': row['${prefix}_slot'],
      'last_updated': row['${prefix}_date'],
    };
  }
}