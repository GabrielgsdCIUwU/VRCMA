import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';

abstract class IStatusConditionMatcher {
  bool canHandle(ConditionType type);
  Future<bool> matches(StatusRule rule, StatusContext context);
}

class NumericConditionMatcher implements IStatusConditionMatcher {
  @override
  bool canHandle(ConditionType type) =>
      type == ConditionType.population || type == ConditionType.batteryLevel;

  @override
  Future<bool> matches(StatusRule rule, StatusContext context) async {
    final actualValue = rule.conditionType == ConditionType.population
        ? context.population
        : context.batteryLevel;

    switch (rule.operator) {
      case RuleOperator.greaterThan:
        return actualValue > (int.tryParse(rule.conditionValue) ?? 0);

      case RuleOperator.lessThan:
        return actualValue < (int.tryParse(rule.conditionValue) ?? 0);
      
      case RuleOperator.equalTo:
        return actualValue == (int.tryParse(rule.conditionValue) ?? 0);

      case RuleOperator.between:
        final parts = rule.conditionValue.split('-');
        if (parts.length != 2) return false;
        
        final min = int.tryParse(parts[0].trim()) ?? 0;
        final max = int.tryParse(parts[1].trim()) ?? 100;

        return actualValue >= min && actualValue <= max;

      default:
        return false;
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

class TimeRangeConditionMatcher implements IStatusConditionMatcher {
  @override
  bool canHandle(ConditionType type) => type == ConditionType.timeRange;

  @override
  Future<bool> matches(StatusRule rule, StatusContext context) async {
    final currentHourMinute = _toMinutes(context.timestamp.hour, context.timestamp.minute);

    switch (rule.operator) {
      case RuleOperator.between:
        //* Expects standard 24h synxtax: "HH:MM-HH:MM"
        final parts = rule.conditionValue.split('-');
        if (parts.length != 2) return false;

        final startMinutes = _parseTime(parts[0].trim());
        final endMinutes = _parseTime(parts[1].trim());
        if (startMinutes == null || endMinutes == null) return false;

        if (startMinutes <= endMinutes) {
          return currentHourMinute >= startMinutes && currentHourMinute <= endMinutes;
        } else {
          return currentHourMinute >= startMinutes || currentHourMinute <= endMinutes;
        }
      
      case RuleOperator.equalTo:
        final targetMinutes = _parseTime(rule.conditionValue.trim());
        return currentHourMinute == targetMinutes;
      
      default: return false;
    }
  }
  int _toMinutes(int hour, int minute) => hour * 60 + minute;

  int? _parseTime(String timeStr) {
    final parts = timeStr.split(":");
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return _toMinutes(hour, minute);
  }
}
