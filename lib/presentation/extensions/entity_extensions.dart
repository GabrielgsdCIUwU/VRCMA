import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/automation_log.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';

/// Presentation extensions for rendering localized domain entity values in the UI.
extension VrcUserUiExtension on VrcUser {
  bool get isTrulyOffline => location == 'offline' || status.toLowerCase() == 'offline';

  String getLocalizedFormattedLocation(BuildContext context) {
    final l10n = context.l10n;
    if (isTrulyOffline) return l10n.presenceOffline;
    if (location.isEmpty) return l10n.presenceActiveWebsite;

    final instance = VrcInstance.parse(location);

    if (instance.isTraveling) return l10n.presenceTraveling;
    if (instance.isPrivate) return l10n.presencePrivateInstance;

    if (instance.isResolvableWorld) {
      return l10n.presenceInstanceDesc(
        _getLocalizedAccessType(context, instance.accessType),
        instance.region,
      );
    }
    return location;
  }

  String _getLocalizedAccessType(BuildContext context, InstanceAccessType type) {
    final l10n = context.l10n;
    return switch (type) {
      InstanceAccessType.public => l10n.accessPublic,
      InstanceAccessType.inviteOnly => l10n.accessInviteOnly,
      InstanceAccessType.invitePlus => l10n.accessInvitePlus,
      InstanceAccessType.friends => l10n.accessFriends,
      InstanceAccessType.friendsPlus => l10n.accessFriendsPlus,
      InstanceAccessType.group => l10n.accessGroup,
      InstanceAccessType.groupPlus => l10n.accessGroupPlus,
      InstanceAccessType.groupPublic => l10n.accessGroupPublic,
      _ => l10n.accessUnknown,
    };
  }
}

extension AutomationLogUiExtension on AutomationLog {
  String getLocalizedAppliedRule(BuildContext context) {
    final l10n = context.l10n;
    if (matchedRoleName == null) {
      return "$profileName (${l10n.logNoRuleMatched})";
    }
    return "$profileName (${l10n.logRuleMatched(matchedRoleName!)})";
  }
}

extension LocalizedPresenceStatus on BuildContext {
  /// Translates raw VRChat presence status string to their localized equivalents.
  String getLocalizedStatus(String status) {
    final l10n = this.l10n;
    return switch (status.toLowerCase()) {
      'active' => l10n.statusTypeActive,
      'join me' => l10n.statusTypeJoinMe,
      'ask me' => l10n.statusTypeAskMe,
      'busy' => l10n.statusTypeBusy,
      _ => status,
    };
  }
}

extension AppLogUiExtension on AppLog {
  String getLocalizedMessage(BuildContext context) {
    final l10n = context.l10n;
    final meta = metadata;

    return switch (meta) {
      InvitationLogMetadata() => () {
        final sender = meta.senderName.isNotEmpty ? meta.senderName : l10n.logFallbackUser;
        final actionStr = meta.action == 'ACCEPT'
            ? l10n.actionAccepted
            : meta.action == 'REJECT'
                ? l10n.actionRejected
                : l10n.logActionIgnored;
        
        if (meta.invitationType == 'FRIEND_REQUEST') return "${l10n.navFriends} $actionStr - $sender";

        final typeStr = meta.invitationType == 'INVITE' ? l10n.tabInvite : l10n.tabRequest;
        return "$typeStr $actionStr - $sender"; 
      }(),

      StatusLogMetadata() => () {
        final localizedStatus = context.getLocalizedStatus(meta.status);
        if (severity == LogSeverity.error) return l10n.logStatusFailure(localizedStatus);
        return l10n.logStatusSuccess(localizedStatus);
      }(),
      
      CalendarLogMetadata() => () {
        final titleStr = meta.ruleName.isNotEmpty ? meta.ruleName : l10n.logFallbackRule;
        if (severity == LogSeverity.error) return l10n.logCalendarFailure(titleStr);
        if (severity == LogSeverity.warning) return l10n.logCalendarWarning(titleStr);
        return l10n.logCalendarSuccess(titleStr);
      }(),
      
      SystemLogMetadata() => l10n.logSystemMessage(message),
    };
  }

  String getLocalizedCategory(BuildContext context) {
    final l10n = context.l10n;
    return switch (category) {
      LogCategory.invitation => l10n.logCategoryInvitation,
      LogCategory.status => l10n.logCategoryStatus,
      LogCategory.calendar => l10n.logCategoryCalendar,
      LogCategory.system => l10n.logCategorySystem,
    };
  }

  String? getLocalizedDetails(BuildContext context) {
    final l10n = context.l10n;
    final meta = metadata;

    return switch (meta) {
      InvitationLogMetadata() => () {
        final rule = meta.appliedRule;
        if (rule == null || rule.isEmpty) return l10n.logNoRuleMatched;
        final parts = rule.split(':');
        final ruleName = parts.length > 1 ? parts[1] : rule;
        return l10n.logRuleMatched(ruleName);
      }(),
      
      StatusLogMetadata() => meta.description.isNotEmpty ? meta.description : null,
      CalendarLogMetadata() => null,
      SystemLogMetadata() => details,
    };
  }
}