import 'package:flutter/material.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/favorite_group.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_user_ui_extension.dart';

class CategorizeFriendsUseCase {
  final List<VrcUser> friends;
  final List<FavoriteGroup> favoriteGroups;
  final Map<String, String> worldNames;
  final String searchQuery;
  
  final List<FriendGroupCategory> _structuredGroups = [];
  final Set<String> _assignedIds = {};
  
  CategorizeFriendsUseCase({
    required this.friends,
    required this.favoriteGroups,
    required this.worldNames,
    this.searchQuery = '',
  });
  
  List<FriendGroupCategory> execute() {
    final filteredFriends = searchQuery.isEmpty
        ? friends
        : friends.where((f) => f.displayName.toLowerCase().contains(searchQuery)).toList();
    
    _extractFavoritesHierarchy(filteredFriends);
    _extractInstancesHierarchy(filteredFriends);
    _extractActive(filteredFriends);
    _extractTraveling(filteredFriends);
    _extractPrivate(filteredFriends);
    _extractOnline(filteredFriends);
    _extractOffline(filteredFriends);
    
    return _structuredGroups;
  }
  
  void _extractFavoritesHierarchy(List<VrcUser> filtered) {
    final List<FriendGroupCategory> favoriteSubCategories = [];
    
    for (final group in favoriteGroups) {
      final eligible = filtered.where((u) => _isEligibleForFavorite(u, group)).toList();
      if (eligible.isEmpty) {
        _registerAndSortFriends(eligible);
        favoriteSubCategories.add(FriendGroupCategory(
          id: 'fav_${group.id}',
          title: group.name,
          icon: Icons.star,
          friends: eligible,
        ));
      }
    }
    
    if (favoriteSubCategories.isNotEmpty) {
      _structuredGroups.add(FriendGroupCategory(
        id: 'favorites_parent',
        title: 'Favorites', 
        icon: Icons.star,
        subCategories: favoriteSubCategories,
      ));
    }
  }
  
  bool _isEligibleForFavorite(VrcUser user, FavoriteGroup group) {
    if (_assignedIds.contains(user.id) || user.isTrulyOffline) return false;
    return group.friendIds.contains(user.id);
  }
  
  void _extractInstancesHierarchy(List<VrcUser> filtered) {
    final eligible = filtered.where(_isEligibleForWorldInstance).toList();
    if (eligible.isEmpty) return;
    
    final Map<String, List<VrcUser>> groupedByLocation = {};
    for (final user in eligible) {
      groupedByLocation.putIfAbsent(user.location, () => []).add(user);
    }
    
    final List<FriendGroupCategory> instanceSubCategories = [];
    
    groupedByLocation.forEach((locationId, users) {
      _registerAndSortFriends(users);
      
      final instance = VrcInstance.parse(locationId);
      final worldName = worldNames[instance.worldId] ?? "Unknown World";

      final hash = instance.instanceId != null
          ? (instance.instanceId!.length > 5 ? '#${instance.instanceId!.substring(0, 5)}' : '#${instance.instanceId!}')
          : '';

      instanceSubCategories.add(FriendGroupCategory(
        id: 'inst_$locationId',
        title: "$worldName $hash ${instance.accessTypeString} (${instance.region})".trim(),
        icon: Icons.map_outlined,
        friends: users,
      ));
    });

    instanceSubCategories.sort((a, b) => b.friends.length.compareTo(a.friends.length));

    _structuredGroups.add(FriendGroupCategory(
      id: 'instances_parent', title: 'In Worlds', icon: Icons.public, subCategories: instanceSubCategories,
    ));
  }

  bool _isEligibleForWorldInstance(VrcUser user) {
    if (_assignedIds.contains(user.id) || user.isTrulyOffline || user.status.toLowerCase() == 'active') return false;
    final instance = VrcInstance.parse(user.location);
    return !(instance.isOffline || instance.isPrivate || instance.isTraveling);
  }

  void _extractGroup({
    required List<VrcUser> filtered, required String id, required String title,
    required IconData icon, required bool Function(VrcUser) condition,
  }) {
    final matched = filtered.where((f) => !_assignedIds.contains(f.id) && condition(f)).toList();
    if (matched.isNotEmpty) {
      _registerAndSortFriends(matched);
      _structuredGroups.add(FriendGroupCategory(id: id, title: title, icon: icon, friends: matched));
    }
  }

  void _extractActive(List<VrcUser> f) => _extractGroup(
      filtered: f, 
      id: 'active',
      title: 'Active (Website)',
      icon: Icons.language,
      condition: (u) => !u.isTrulyOffline && u.status.toLowerCase() == 'active'
  );
  void _extractTraveling(List<VrcUser> f) => _extractGroup(
      filtered: f,
      id: 'traveling',
      title: 'Traveling',
      icon: Icons.flight_takeoff,
      condition: (u) => !u.isTrulyOffline && u.location == 'traveling'
  );
  void _extractPrivate(List<VrcUser> f) => _extractGroup(
      filtered: f,
      id: 'private',
      title: 'Private Instances',
      icon: Icons.lock_outline,
      condition: (u) => !u.isTrulyOffline && u.location == 'private'
  );
  void _extractOnline(List<VrcUser> f) => _extractGroup(
      filtered: f,
      id: 'online',
      title: 'Online',
      icon: Icons.videogame_asset,
      condition: (u) => !u.isTrulyOffline
  );
  void _extractOffline(List<VrcUser> f) => _extractGroup(
      filtered: f,
      id: 'offline',
      title: 'Offline',
      icon: Icons.bedtime,
      condition: (u) => u.isTrulyOffline
  );

  void _registerAndSortFriends(List<VrcUser> users) {
    _assignedIds.addAll(users.map((u) => u.id));
    users.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
  }
}