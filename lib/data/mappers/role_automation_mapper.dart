import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';

class RoleAutomationMapper {
  static RoleAutomation fromJoinRows(
    int id,
    String triggerType,
    String? targetValue,
    List<Role> roles,
  ) {
    return RoleAutomation(
      id: id,
      trigger: triggerType == 'newFriend'
        ? AutomationTrigger.newFriend
        : AutomationTrigger.hasTag,
      targetValue: targetValue,
      roles: roles,
    );
  }

  static Map<String, dynamic> toDatabaseMap(RoleAutomation automation) {
    return {
      if (automation.id != null) 'id': automation.id,
      'trigger_type': automation.trigger.name,
      'target_value': automation.targetValue,
    };
  }
}