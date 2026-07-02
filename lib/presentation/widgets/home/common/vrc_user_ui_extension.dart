import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';

extension VrcUserUiExtension on VrcUser {
  bool get isTrulyOffline => location == 'offline' || status.toLowerCase() == 'offline';
  
  String getLocalizedFormattedLocation(BuildContext context) {
    if (isTrulyOffline) return context.l10n.presenceOffline;
    if (location.isEmpty) return context.l10n.presenceActiveWebsite;

    final instance = VrcInstance.parse(location);

    if (instance.isTraveling) return context.l10n.presenceTraveling;
    if (instance.isPrivate) return context.l10n.presencePrivateInstance;

    if (instance.isResolvableWorld) {
      return context.l10n.presenceInstanceDesc(
        _getLocalizedAccessType(context, instance.accessType),
        instance.region,
      );
    }
    return location;
  }

  String _getLocalizedAccessType(BuildContext context, InstanceAccessType type) {
    switch (type) {
      case InstanceAccessType.public:
        return context.l10n.accessPublic;
      
      case InstanceAccessType.inviteOnly:
        return context.l10n.accessInviteOnly;
      
      case InstanceAccessType.invitePlus:
        return context.l10n.accessInvitePlus;
      
      case InstanceAccessType.friends:
        return context.l10n.accessFriends;
      
      case InstanceAccessType.friendsPlus:
        return context.l10n.accessFriendsPlus;
      
      case InstanceAccessType.group:
        return context.l10n.accessGroup;
      
      case InstanceAccessType.groupPlus:
        return context.l10n.accessGroupPlus;
      
      case InstanceAccessType.groupPublic:
        return context.l10n.accessGroupPublic;
      
      default:
        return context.l10n.accessUnknown;
    }
  }
}