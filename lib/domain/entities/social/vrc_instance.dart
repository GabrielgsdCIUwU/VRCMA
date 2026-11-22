import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/calendar/enums/instance_region.dart';

enum InstanceAccessType {
  public,
  inviteOnly,
  invitePlus,
  friends,
  friendsPlus,
  group,
  groupPlus,
  groupPublic,
  unknown,
}

/// Parses and caches VRChat instance location strings into structured domain objects.
class VrcInstance extends Equatable {
  static const int _maxCacheEntries = 200;
  static final LinkedHashMap<String, VrcInstance> _cache =
  LinkedHashMap<String, VrcInstance>();

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
  
  /// Parses [location] using an internal LRU cache to avoid redundant allocations.
  factory VrcInstance.parse(String location) {
    final cached = _getFromCache(location);
    if (cached != null) return cached;

    final parsed = _parseUncached(location);
    _putInCache(location, parsed);
    return parsed;
  }
    
  static VrcInstance? _getFromCache(String location) {
    final existing = _cache.remove(location);
    if (existing != null) {
      // Re-insert to mark as most recently used.
      _cache[location] = existing;
    }
    return existing;
  }

  static void _putInCache(String location, VrcInstance instance) {
    if (_cache.length >= _maxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[location] = instance;
  }

  static VrcInstance _parseUncached(String location) {
    if (_isNonWorldState(location)) {
      return VrcInstance(
        locationString: location,
        accessType: InstanceAccessType.unknown,
      );
    }

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
    return _buildInstanceFromTokens(location, worldId, instanceParts);
  }

  static bool _isNonWorldState(String location) {
    return location.isEmpty ||
        location == 'offline' ||
        location == 'private' ||
        location == 'traveling';
  }

  static VrcInstance _buildInstanceFromTokens(
      String location,
      String worldId,
      List<String> instanceParts,
      ) {
    final instanceId = instanceParts[0];
    var type = InstanceAccessType.public;
    var region = InstanceRegion.us;

    for (var i = 1; i < instanceParts.length; i++) {
      final token = instanceParts[i];
      type = _resolveAccessType(token, type);
      region = _resolveRegion(token, region);
    }

    if (type == InstanceAccessType.inviteOnly &&
        location.contains('canRequestInvite')) {
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

  static InstanceAccessType _resolveAccessType(
      String token,
      InstanceAccessType current,
      ) {
    if (token.startsWith('private')) return InstanceAccessType.inviteOnly;
    if (token.startsWith('friends')) return InstanceAccessType.friends;
    if (token.startsWith('hidden')) return InstanceAccessType.friendsPlus;
    if (token.startsWith('group(')) {
      return current == InstanceAccessType.public
          ? InstanceAccessType.group
          : current;
    }
    if (token.startsWith('groupAccessType(')) {
      return _parseGroupAccessToken(token, current);
    }
    return current;
  }

  static InstanceAccessType _parseGroupAccessToken(
      String token,
      InstanceAccessType fallback,
      ) {
    final access = token.substring(16, token.length - 1);
    if (access == 'public') return InstanceAccessType.groupPublic;
    if (access == 'plus') return InstanceAccessType.groupPlus;
    if (access == 'members') return InstanceAccessType.group;
    return fallback;
  }

  static InstanceRegion _resolveRegion(String token, InstanceRegion current) {
    if (!token.startsWith('region(')) return current;
    final rawRegion = token.substring(7, token.length - 1);
    return InstanceRegion.fromString(rawRegion);
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