import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/automation_log.dart';
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