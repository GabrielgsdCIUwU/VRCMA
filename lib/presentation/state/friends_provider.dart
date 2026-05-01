import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/data/repositories/social_repository_imp.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/favorite_group.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/usecases/automation/process_friend_automations_use_case.dart';
import 'package:vrcma/domain/usecases/social/categorize_friends_use_case.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/world_cache_provider.dart';
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
  
  final uniqueWorldIds = friends
    .where((f) => !f.isTrulyOffline && f.status.toLowerCase() != 'active')
    .map((f) => VrcInstance.parse(f.location).worldId)
    .whereType<String>()
    .toSet();
  
  final Map<String, String> resolvedWorldNames = {};
  for (final worldId in uniqueWorldIds) {
    resolvedWorldNames[worldId] = await ref.watch(worldNameProvider(worldId).future);
  }
  
  final useCase = CategorizeFriendsUseCase(
    friends: friends,
    favoriteGroups: favGroups,
    worldNames: resolvedWorldNames,
    searchQuery: query,
  );
  return useCase.execute();
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