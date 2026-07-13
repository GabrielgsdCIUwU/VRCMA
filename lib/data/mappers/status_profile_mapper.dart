import 'package:vrcma/domain/entities/automation/status_automation.dart';

class StatusProfileMapper {
  static StatusProfile fromDatabaseMaps(
    Map<String, dynamic> profileRow,
    Iterable<Map<String, dynamic>> ruleRows,
  ) {
    final rules = ruleRows.map((rMap) => StatusRule(
      id: rMap['id'] as int?,
      priority: rMap['priority'] as int,
      targetStatus: StatusType.fromString(rMap['target_status'] as String),
      messageTemplate: rMap['message_template'] as String?,
      conditionType: ConditionType.values.firstWhere(
        (e) => e.name == (rMap['condition_type'] as String),
      ),
      operator: RuleOperator.values.firstWhere(
        (e) => e.name == (rMap['operator'] as String),
      ),
      conditionValue: rMap['condition_value'] as String? ?? '',
    )).toList();

    return StatusProfile(
      id: profileRow['id'] as int,
      name: profileRow['name'] as String,
      isActive: (profileRow['is_active'] as int) == 1,
      fallbackStatus: StatusType.fromString(profileRow['fallback_status'] as String),
      fallbackTemplate: profileRow['fallback_template'] as String?,
      lastAppliedStatus: profileRow['last_applied_status'] != null 
          ? StatusType.fromString(profileRow['last_applied_status'] as String) 
          : null,
      lastAppliedMessage: profileRow['last_applied_message'] as String?,
      rules: rules,
    );
  }

  static Map<String, dynamic> ruleToDatabaseMap(int profileId, StatusRule rule) {
    return {
      'profile_id': profileId,
      'priority': rule.priority,
      'target_status': rule.targetStatus.apiValue,
      'message_template': rule.messageTemplate,
      'condition_type': rule.conditionType.name,
      'operator': rule.operator.name,
      'condition_value': rule.conditionValue,
    };
  }
}