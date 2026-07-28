import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';
import 'package:vrcma/domain/entities/calendar/enums/creation_strategy.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/theme/app_theme_color.dart';

extension RecurrenceTypeL10n on RecurrenceType {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      RecurrenceType.once => l10n.calRecurrenceOnce,
      RecurrenceType.daily => l10n.calRecurrenceDaily,
      RecurrenceType.weekly => l10n.calRecurrenceWeekly,
      RecurrenceType.monthly => l10n.calRecurrenceMonthly,
    };
  }
}

extension GroupEventCategoryL10n on GroupEventCategory {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      GroupEventCategory.arts => l10n.calCategoryArts,
      GroupEventCategory.avatars => l10n.calCategoryAvatars,
      GroupEventCategory.dance => l10n.calCategoryDance,
      GroupEventCategory.education => l10n.calCategoryEducation,
      GroupEventCategory.exploration => l10n.calCategoryExploration,
      GroupEventCategory.film_media => l10n.calCategoryFilmMedia,
      GroupEventCategory.gaming => l10n.calCategoryGaming,
      GroupEventCategory.hangout => l10n.calCategoryHangout,
      GroupEventCategory.music => l10n.calCategoryMusic,
      GroupEventCategory.performance => l10n.calCategoryPerformance,
      GroupEventCategory.roleplaying => l10n.calCategoryRoleplaying,
      GroupEventCategory.wellness => l10n.calCategoryWellness,
      GroupEventCategory.other => l10n.calCategoryOther,
    };
  }
}

extension GroupEventAccessTypeL10n on GroupEventAccessType {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      GroupEventAccessType.public => l10n.accessPublic,
      GroupEventAccessType.group => l10n.accessGroup,
    };
  }
}

extension FallbackTagActionL10n on FallbackTagAction {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      FallbackTagAction.disabled => l10n.fallbackTagActionDisabled,
      FallbackTagAction.accept => l10n.fallbackTagActionAccept,
      FallbackTagAction.reject => l10n.fallbackTagActionReject,
    };
  }
}

extension RuleActionL10n on RuleAction {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      RuleAction.accept => l10n.ruleActionAccept,
      RuleAction.reject => l10n.ruleActionReject,
    };
  }
}

extension StatusTypeL10n on StatusType {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      StatusType.active => l10n.statusTypeActive,
      StatusType.joinMe => l10n.statusTypeJoinMe,
      StatusType.askMe => l10n.statusTypeAskMe,
      StatusType.busy => l10n.statusTypeBusy,
    };
  }
}

extension ConditionTypeL10n on ConditionType {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ConditionType.population => l10n.conditionTypePopulation,
      ConditionType.instanceType => l10n.conditionTypeInstanceType,
      ConditionType.batteryLevel => l10n.conditionTypeBatteryLevel,
      ConditionType.friendPresent => l10n.conditionTypeFriendPresent,
      ConditionType.timeRange => l10n.conditionTypeTimeRange,
      ConditionType.world => l10n.conditionTypeWorld,
    };
  }
}

extension RuleOperatorL10n on RuleOperator {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      RuleOperator.greaterThan => l10n.operatorGreaterThan,
      RuleOperator.lessThan => l10n.operatorLessThan,
      RuleOperator.equalTo => l10n.operatorEqualTo,
      RuleOperator.contains => l10n.operatorContains,
      RuleOperator.between => l10n.operatorBetween,
    };
  }
}

extension VrcMessageTypeL10n on VrcMessageType {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      VrcMessageType.invite => l10n.messageTypeInvite,
      VrcMessageType.response => l10n.messageTypeResponse,
      VrcMessageType.request => l10n.messageTypeRequest,
      VrcMessageType.requestResponse => l10n.messageTypeRequestResponse,
    };
  }
}

extension AppThemeColorMaterial on AppThemeColor {
  Color get getMaterialColor {
    switch (this) {
      case AppThemeColor.deepPurple:
        return Colors.deepPurple;
        
      case AppThemeColor.blue:
        return Colors.blue;
      
      case AppThemeColor.teal:
        return Colors.teal;
      
      case AppThemeColor.green:
        return Colors.green;
      
      case AppThemeColor.orange:
        return Colors.deepOrange;
      
      case AppThemeColor.rose:
        return Colors.pink;

    }
  }

  String getLozalizedName(BuildContext context) {
    switch (this) {
      case AppThemeColor.deepPurple:
        return context.l10n.colorDeepPurple;
      
      case AppThemeColor.blue:
        return context.l10n.colorBlue;
      
      case AppThemeColor.teal:
        return context.l10n.colorTeal;
      
      case AppThemeColor.green:
        return context.l10n.colorGreen;
      
      case AppThemeColor.orange:
        return context.l10n.colorOrange;
      
      case AppThemeColor.rose:
        return context.l10n.colorRose;
    }
  }
}

extension VrcTagCategoryUI on VrcTagCategory {
  Widget getIcon(BuildContext context, {double size = 24}) {
    IconData icon;
    Color color;

    switch (this) {
      case VrcTagCategory.admin:
        icon = Icons.admin_panel_settings;
        color = context.colorScheme.error;
        break;
      case VrcTagCategory.system:
        icon = Icons.settings_system_daydream;
        color = context.colorScheme.primary;
        break;
      case VrcTagCategory.trust:
        icon = Icons.shield;
        color = context.vrcColors.request;
        break;
      case VrcTagCategory.language:
        icon = Icons.language;
        color = context.vrcColors.success;
        break;
    }
    return Icon(icon, color: color, size: 24);
  }
}

extension CreationStrategyL10n on CreationStrategy {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      CreationStrategy.lazy => l10n.calStrategyLazy,
      CreationStrategy.batch => l10n.calStrategyBatch,
    };
  }
}