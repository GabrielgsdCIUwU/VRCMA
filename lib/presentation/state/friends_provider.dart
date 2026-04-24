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
    return _fetchFriends();
  }
  
  Future<List<VrcUser>> _fetchFriends() async {
    final api = await ref.watch(vrcApiProvider.future);
    final repo = SocialRepositoryImp(api);
    final localSocialRepo = await ref.watch(localSocialRepositoryProvider.future);

    final result = await repo.getFriends();
    return result.fold(
          (failure) => throw failure.message,
          (friends) async {
            final useCase = ProcessFriendAutomationsUseCase(localSocialRepo);
            await useCase.execute(friends);
            
            return friends;
          },
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFriends());
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
    favGroups: favGroups,
    currentUser: currentUser,
  );
  
  return builder.build();
}

class _FriendCategoryBuilder {
  final List<VrcUser> friends;
  final List<FavoriteGroup> favGroups;
  final VrcUser? currentUser;
  
  final List<FriendGroupCategory> _structuredGroups = [];
  final Set<String> _assignedIds = {};
  
  _FriendCategoryBuilder({
    required this.friends,
    required this.favGroups,
    required this.currentUser,
  });
  
  List<FriendGroupCategory> build() {
    _extractSameInstance();
    _extractFavoriteGroups();
    _extractActive();
    _extractOnline();
    _extractOffline();
    
    return _structuredGroups;
  
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
  
  void _extractSameInstance() {
    if (currentUser == null) return;
    
    _extractGroup(id: 'same_instance', title: 'Same Instance', icon: Icons.map, condition: (f) =>
        !f.isTrulyOffline && f.location.isNotEmpty && f.location != 'private' && f.location == currentUser!.location
    );
  }
  
  void _extractFavoriteGroups() {
    for (final group in favGroups) {
      _extractGroup(id: group.id, title: group.name, icon: Icons.star, condition: (f) => f.tags.contains(group.id));
    }
  }
  
  void _extractActive() {
    _extractGroup(id: 'active', title: 'Active', icon: Icons.language, condition: (f) => 
    !f.isTrulyOffline && f.status.toLowerCase() == 'active'
    );
  }
  
  void _extractOnline() {
    _extractGroup(id: 'online', title: 'Online', icon: Icons.videogame_asset, condition: (f) => !f.isTrulyOffline);
  }
  
  void _extractOffline() {
    _extractGroup(id: 'offline', title: 'Offline', icon: Icons.bedtime, condition: (f) => f.isTrulyOffline);
  }
}