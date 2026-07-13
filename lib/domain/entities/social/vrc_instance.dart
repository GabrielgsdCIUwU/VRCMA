import 'package:equatable/equatable.dart';

enum InstanceAccessType {public, inviteOnly, invitePlus, friends, friendsPlus, group, groupPlus, groupPublic, unknown }

class VrcInstance extends Equatable {
  final String locationString;
  final String? worldId;
  final String? instanceId;
  final InstanceAccessType accessType;
  final String region;
  
  const VrcInstance({
    required this.locationString,
    this.worldId,
    this.instanceId,
    required this.accessType,
    this.region = 'US',
  });

  static final Map<String, VrcInstance> _locationCache = {};
  static const int _maxCacheSize = 250;
  
  bool get isOffline => locationString == 'offline' || locationString.isEmpty;
  bool get isPrivate => locationString == 'private';
  bool get isTraveling => locationString == 'traveling';
  bool get isResolvableWorld => worldId != null && worldId!.startsWith('wrld_');
  
  factory VrcInstance.parse(String location) {
    final cached = _locationCache[location];
    if (cached != null) return cached;

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
        accessType: InstanceAccessType.public
      );
    }
    
    final instanceParts = parts[1].split('~');
    final instanceId = instanceParts[0];
    
    InstanceAccessType type = InstanceAccessType.public;
    String region = 'US';
    
    for (int i = 1; i < instanceParts.length; i++) {
      final part = instanceParts[i];
      
      if (part.startsWith('private')) {
        type = InstanceAccessType.inviteOnly;
      } else if (part.startsWith('friends')) {
        type = InstanceAccessType.friends;
      } else if (part.startsWith('hidden')) {
        type = InstanceAccessType.friendsPlus;
      } 
      
      else if (part.startsWith('region(')) {
        region = part.substring(7, part.length -1).toUpperCase();
      }
      
      else if(part.startsWith('group(')) {
        if (type == InstanceAccessType.public) type = InstanceAccessType.group;
      } else if (part.startsWith('groupAccessType(')) {
        final access = part.substring(16, part.length -1);
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
    
    final parsedInstance = VrcInstance(
      locationString: location,
      worldId: worldId,
      instanceId: instanceId,
      accessType: type,
      region: region,
    );

    _parseToLocationCache(location, parsedInstance);
    return parsedInstance;
  }

  static void _parseToLocationCache(String key, VrcInstance value) {
    if (_locationCache.length >= _maxCacheSize) {
      //* Clear: Just to simplify, but can be improve with LRU (Least Recently Used)
      _locationCache.clear();
    }
    _locationCache[key] = value;
  }
  
  String get accessTypeString {
    switch (accessType) {
      case InstanceAccessType.public: return 'Public';
      case InstanceAccessType.inviteOnly: return 'Invite Only';
      case InstanceAccessType.invitePlus: return 'Invite+';
      case InstanceAccessType.friends: return 'Friends';
      case InstanceAccessType.friendsPlus: return 'Friends+';
      case InstanceAccessType.group: return 'Group';
      case InstanceAccessType.groupPlus: return 'Group+';
      case InstanceAccessType.groupPublic: return 'Group Public';
      default: return 'Unknown';
    }
  }
  
  @override
  List<Object?> get props => [locationString, worldId, instanceId, accessType, region];
}