import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/data/repositories/social_repository_imp.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/favorite_group.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/domain/usecases/automation/process_friend_automations_use_case.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_user_ui_extension.dart';

part 'friends_provider.g.dart';

@riverpod
class FriendsList extends _$FriendsList {
  @override
  FutureOr<List<VrcUser>> build() async {
    return _fetchFriendsProgressively();
  }
  
  Future<List<VrcUser>> _fetchFriendsProgressively() async {
    final api = await ref.watch(vrcApiProvider.future);
    final repo = SocialRepositoryImp(api);
    final localSocialRepo = await ref.watch(localSocialRepositoryProvider.future);
    final useCase = ProcessFriendAutomationsUseCase(localSocialRepo);
    
    final onlineResult = await repo.getFriends(offline: false);
    
    List<VrcUser> onlineFriends = onlineResult.fold(
        (failure) => throw failure.message,
        (friends) => friends,
    );
    
    state = AsyncData(onlineFriends);
    
    await useCase.execute(onlineFriends);
    
    _fetchOfflineFriendsInBackground(repo, useCase, onlineFriends);
    
    return onlineFriends;
  }
  
  Future<void> _fetchOfflineFriendsInBackground(
      SocialRepositoryImp repo,
      ProcessFriendAutomationsUseCase useCase,
      List<VrcUser> currentOnlineFriends,
      ) async {
    final offlineResult = await repo.getFriends(offline: true);
    
    offlineResult.fold(
        (failure) => debugPrint("Silent error: failed to load offline friends: ${failure.message}"),
        (offlineFriends) async {
          final allFriends = [...currentOnlineFriends, ...offlineFriends];
          state = AsyncData(allFriends);
          
          await useCase.execute(offlineFriends);
        }
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFriendsProgressively());
  }
}

@riverpod
class FriendsSearchQuery extends _$FriendsSearchQuery {
  @override
  String build() => '';
  
  void updateQuery(String query) => state = query;
}

@riverpod
Future<List<FavoriteGroup>> favoriteFriendGroups(Ref ref) async {
  final api = await ref.watch(vrcApiProvider.future);
  final repo = SocialRepositoryImp(api);
  final result = await repo.getFavoriteGroups();

  return result.fold(
        (failure) => [],
        (groups) => groups,
  );
}

@riverpod
Future<List<FriendGroupCategory>> structuredFriendsList(Ref ref) async {
  final friends = await ref.watch(friendsListProvider.future);
  final favGroups = await ref.watch(favoriteFriendGroupsProvider.future);
  final query = ref.watch(friendsSearchQueryProvider).toLowerCase();
  final currentUser = await ref.watch(authStateProvider.future);
  
  final filteredFriends = friends.where((f) => f.displayName.toLowerCase().contains(query)).toList();
  
  final builder = _FriendCategoryBuilder(
    friends: filteredFriends,
    favoriteGroups: favGroups,
    currentUser: currentUser,
  );
  
  return builder.build();
}

class _FriendCategoryBuilder {
  final List<VrcUser> friends;
  final List<FavoriteGroup> favoriteGroups;
  final VrcUser? currentUser;
  
  final List<FriendGroupCategory> _structuredGroups = [];
  final Set<String> _assignedIds = {};
  
  _FriendCategoryBuilder({
    required this.friends,
    required this.favoriteGroups,
    required this.currentUser,
  });
  
  List<FriendGroupCategory> build() {
    _extractFavoritesHierarchy();
    _extractInstancesHierarchy();
    _extractActive();
    _extractOnline();
    _extractOffline();
    
    return _structuredGroups;
  }
  
  void _extractFavoritesHierarchy() {
    final List<FriendGroupCategory> favoriteSubCategories = [];
    
    for (final favoriteGroup in favoriteGroups) {
      final eligibleFriends = friends.where((user) => _isEligibleForFavoriteGroup(user, favoriteGroup)).toList();
      
      if (eligibleFriends.isNotEmpty) {
        _registerAndSortFriends(eligibleFriends);
        
        favoriteSubCategories.add(FriendGroupCategory(
          id: 'fav_${favoriteGroup.id}',
          title: favoriteGroup.name,
          icon: Icons.star_border,
          friends: eligibleFriends,
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
  
  bool _isEligibleForFavoriteGroup(VrcUser user, FavoriteGroup favoriteGroup) {
    if (_assignedIds.contains(user.id)) return false;
    if (user.isTrulyOffline) return false;
    
    return favoriteGroup.friendIds.contains(user.id);
  }
  
  void _extractInstancesHierarchy() {
    final eligibleFriendsInWorlds = friends.where(_isEligibleForWorldInstance).toList();
    
    if (eligibleFriendsInWorlds.isEmpty) return;
    
    final Map<String, List<VrcUser>> friendGroupedByLocation = _groupFriendsByLocation(eligibleFriendsInWorlds);
    final List<FriendGroupCategory> instanceSubCategories = [];
    
    friendGroupedByLocation.forEach((locationId, usersInLocation) {
      _registerAndSortFriends(usersInLocation);
      
      instanceSubCategories.add(
        _createInstanceSubCategory(locationId, usersInLocation)
      );
    });
    
    instanceSubCategories.sort((a, b) =>
        b.friends.length.compareTo(a.friends.length));
    
    _structuredGroups.add(FriendGroupCategory(
      id: 'instances_parent',
      title: 'In Worlds',
      icon: Icons.public,
      subCategories: instanceSubCategories,
    ));
  }
  
  bool _isEligibleForWorldInstance(VrcUser user) {
    if (_assignedIds.contains(user.id)) return false;
    if (user.isTrulyOffline) return false;
    if (user.location.isEmpty || user.location == 'private' || user.location == 'offline') return false;
    if (user.status.toLowerCase() == 'active') return false;
    return true;
  }
  
  Map<String, List<VrcUser>> _groupFriendsByLocation(List<VrcUser> users) {
    final Map<String, List<VrcUser>> groupedFriends = {};
    for (final user in users) {
      groupedFriends.putIfAbsent(user.location, () => []).add(user);
    }
    return groupedFriends;
  }
  
  FriendGroupCategory _createInstanceSubCategory(String locationId, List<VrcUser> users) {
    final formattedLocationName = users.first.formattedLocation;
    final shortInstanceHash = _getInstanceShortHash(locationId);
    
    return FriendGroupCategory(
      id: 'inst_$locationId',
      title: '$formattedLocationName $shortInstanceHash'.trim(),
      icon: Icons.map_outlined,
      friends: users,
    );
  }
  
  
  
  void _extractGroup({
    required String id,
    required String title,
    required IconData icon,
    required bool Function(VrcUser) condition,
  }) {
    final matchedFriends = friends.where((f) {
      if (_assignedIds.contains(f.id)) return false;
      return condition(f);
    }).toList();
    
    if (matchedFriends.isNotEmpty) {
      _assignedIds.addAll(matchedFriends.map((e) => e.id));
      
      _structuredGroups.add(FriendGroupCategory(id: id, title: title, icon: icon, friends: matchedFriends));
    }
  }
  
  void _extractActive() {
    _extractGroup(id: 'active', title: 'Active (Website)', icon: Icons.language, condition: (f) => 
    !f.isTrulyOffline && f.status.toLowerCase() == 'active'
    );
  }
  
  void _extractOnline() {
    _extractGroup(id: 'online', title: 'Online', icon: Icons.videogame_asset, condition: (f) => !f.isTrulyOffline && f.status.toLowerCase() != 'active');
  }
  
  void _extractOffline() {
    _extractGroup(id: 'offline', title: 'Offline', icon: Icons.bedtime, condition: (f) => f.isTrulyOffline);
  }
  
  void _registerAndSortFriends(List<VrcUser> users) {
    _assignedIds.addAll(users.map((user) => user.id));
    users.sort(_compareFriends);
  }
  
  int _compareFriends(VrcUser a, VrcUser b) {
    if (!a.isTrulyOffline && b.isTrulyOffline) return -1;
    if (a.isTrulyOffline && !b.isTrulyOffline) return 1;
    
    final isAActive = a.status.toLowerCase() == 'active';
    final isBActive = b.status.toLowerCase() == 'active';
    
    if (isAActive && !isBActive) return -1;
    if (!isAActive && isBActive) return 1;
    
    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  }
  
  String _getInstanceShortHash(String location) {
    if (!location.contains(':')) return '';
    
    final parts = location.split(':');
    if (parts.length > 1) {
      final instanceId = parts[1].split('~').first;
      return instanceId.length > 5 ? '(#${instanceId.substring(0, 5)})' : '(#$instanceId)';
    }
    return '';
  }
}

@riverpod
class CategoryExpanded extends _$CategoryExpanded {
  @override
  bool build(String categoryId) {
    return true;
  }
  
  void toggle() {
    state = !state;
  }
}