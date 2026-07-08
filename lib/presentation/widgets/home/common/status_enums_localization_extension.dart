import 'package:flutter/widgets.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';

extension StatusTypeL10n on StatusType {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case StatusType.active: return context.l10n.statusTypeActive;
      case StatusType.joinMe: return context.l10n.statusTypeJoinMe;
      case StatusType.askMe: return context.l10n.statusTypeAskMe;
      case StatusType.busy: return context.l10n.statusTypeBusy;
    }
  }
}

extension ConditionTypeL10n on ConditionType {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case ConditionType.population: return context.l10n.conditionTypePopulation;
      case ConditionType.instanceType: return context.l10n.conditionTypeInstanceType;
      case ConditionType.batteryLevel: return context.l10n.conditionTypeBatteryLevel;
      case ConditionType.friendPresent: return context.l10n.conditionTypeFriendPresent;
      case ConditionType.timeRange: return context.l10n.conditionTypeTimeRange;
      case ConditionType.world: return context.l10n.conditionTypeWorld;
    }
  }
}

extension RuleOperatorL10n on RuleOperator {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case RuleOperator.greaterThan: return context.l10n.operatorGreaterThan;
      case RuleOperator.lessThan: return context.l10n.operatorLessThan;
      case RuleOperator.equalTo: return context.l10n.operatorEqualTo;
      case RuleOperator.contains: return context.l10n.operatorContains;
      case RuleOperator.between: return context.l10n.operatorBetween;
    }
  }
}