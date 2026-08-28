import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/calendar/enums/instance_region.dart';

enum InstanceAccessType {public, inviteOnly, invitePlus, friends, friendsPlus, group, groupPlus, groupPublic, unknown }

class VrcInstance extends Equatable {
  final String locationString;
  final String? worldId;
  final String? instanceId;
  final InstanceAccessType accessType;
  final InstanceRegion region;
  
  const VrcInstance({
    required this.locationString,
    this.worldId,
    this.instanceId,
    required this.accessType,
    this.region = InstanceRegion.us,
  });

  bool get isOffline => locationString == 'offline' || locationString.isEmpty;
  bool get isPrivate => locationString == 'private';
  bool get isTraveling => locationString == 'traveling';
  bool get isResolvableWorld => worldId != null && worldId!.startsWith('wrld_');
  
  factory VrcInstance.parse(String location) {
    if (location.isEmpty || location == 'offline' || location == 'private' || location == 'traveling') {
      return VrcInstance(locationString: location, accessType: InstanceAccessType.unknown);
    }
    
    // vrchat instance format: wrld_xx:12345~hidden(usr_xx)~region(us)
    // vrchat instance group format: wrld_xx:12345~group(grp_xx)~groupAccessType(plus)~region(us)
    final parts = location.split(':');
    final worldId = parts[0];
    
    if (parts.length < 2) {
      return VrcInstance(
        locationString: location,
        worldId: worldId,
        accessType: InstanceAccessType.public,
      );
    }

    final instanceParts = parts[1].split('~');
    final instanceId = instanceParts[0];

    var type = InstanceAccessType.public;
    var region = InstanceRegion.us;

    for (var i = 1; i < instanceParts.length; i++) {
      final part = instanceParts[i];

      if (part.startsWith('private')) {
        type = InstanceAccessType.inviteOnly;
      } else if (part.startsWith('friends')) {
        type = InstanceAccessType.friends;
      } else if (part.startsWith('hidden')) {
        type = InstanceAccessType.friendsPlus;
      } else if (part.startsWith('region(')) {
        final rawRegion = part.substring(7, part.length - 1);
        region = InstanceRegion.fromString(rawRegion);
      } else if (part.startsWith('group(')) {
        if (type == InstanceAccessType.public) type = InstanceAccessType.group;
      } else if (part.startsWith('groupAccessType(')) {
        final access = part.substring(16, part.length - 1);
        if (access == 'public') {
          type = InstanceAccessType.groupPublic;
        } else if (access == 'plus') {
          type = InstanceAccessType.groupPlus;
        } else if (access == 'members') {
          type = InstanceAccessType.group;
        }
      }
    }

    if (type == InstanceAccessType.inviteOnly && location.contains('canRequestInvite')) {
      type = InstanceAccessType.invitePlus;
    }

    return VrcInstance(
      locationString: location,
      worldId: worldId,
      instanceId: instanceId,
      accessType: type,
      region: region,
    );
  }
  
  String get accessTypeString {
    return switch (accessType) {
      InstanceAccessType.public => 'Public',
      InstanceAccessType.inviteOnly => 'Invite Only',
      InstanceAccessType.invitePlus => 'Invite+',
      InstanceAccessType.friends => 'Friends',
      InstanceAccessType.friendsPlus => 'Friends+',
      InstanceAccessType.group => 'Group',
      InstanceAccessType.groupPlus => 'Group+',
      InstanceAccessType.groupPublic => 'Group Public',
      InstanceAccessType.unknown => 'Unknown',
    };
  }

  @override
  List<Object?> get props => [locationString, worldId, instanceId, accessType, region];
}