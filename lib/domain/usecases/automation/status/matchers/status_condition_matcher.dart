import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';

abstract class IStatusConditionMatcher {
  bool canHandle(ConditionType type);
  Future<bool> matches(StatusRule rule, StatusContext context);
}

class NumericConditionMatcher implements IStatusConditionMatcher {
  @override
  bool canHandle(ConditionType type) => type == ConditionType.population || type == ConditionType.batteryLevel;

  @override
  Future<bool> matches(StatusRule rule, StatusContext context) async {
    final actualValue = rule.conditionType == ConditionType.population
      ? context.population
      : context.batteryLevel;
    
    final targetValue = int.tryParse(rule.conditionValue) ?? 0;

    switch (rule.operator) {
      case RuleOperator.greaterThan: return actualValue > targetValue;
      case RuleOperator.lessThan: return actualValue < targetValue;
      case RuleOperator.equalTo: return actualValue == targetValue;
      default: return false;
    }
  }
}

class InstanceTypeMatcher implements IStatusConditionMatcher {
  @override
  bool canHandle(ConditionType type) => type == ConditionType.instanceType;

  @override
  Future<bool> matches(StatusRule rule, StatusContext context) async {
    return context.instanceType.name == rule.conditionValue;    
  }
}

class FriendRoleMatcher implements IStatusConditionMatcher {
  final ILocalSocialRepository _localSocialRepo;
  FriendRoleMatcher(this._localSocialRepo);

  @override
  bool canHandle(ConditionType type) => type == ConditionType.friendPresent;

  @override
  Future<bool> matches(StatusRule rule, StatusContext context) async {
    final roleId = int.tryParse(rule.conditionValue);
    if (roleId == null) return false;

    final userIdsInRole = await _localSocialRepo.getUserIdsByRole(roleId);
    return context.presentFriendIds.any((id) => userIdsInRole.contains(id));
  }
}

class WorldConditionMatcher implements IStatusConditionMatcher {
  @override
  bool canHandle(ConditionType type) => type == ConditionType.world;

  @override
  Future<bool> matches(StatusRule rule, StatusContext context) async {
    final currentWorldId = context.worldId.toLowerCase().trim();
    final targetValue = rule.conditionValue.toLowerCase().trim();

    switch (rule.operator) {
      case RuleOperator.equalTo:
        return currentWorldId == targetValue;
      
      case RuleOperator.contains:
        final List<String> targetWorldIds = targetValue
          .split(',')
          .map((id) => id.trim())
          .toList();
        return targetWorldIds.contains(currentWorldId);

      default:
        return false;
    }    
  }
}