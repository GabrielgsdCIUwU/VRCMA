import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/favorite_group.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/repositories/i_social_repository.dart';
import 'package:vrcma/domain/usecases/automation/process_friend_automations_use_case.dart';
import 'package:vrcma/domain/usecases/social/categorize_friends_use_case.dart';
import 'package:vrcma/presentation/state/world_cache_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_user_ui_extension.dart';

part 'friends_provider.g.dart';

@riverpod
class FriendsList extends _$FriendsList {
  Timer? _evictionTimer;

  static const Duration _cacheEvictionDuration = Duration(minutes: 3);

  @override
  FutureOr<List<VrcUser>> build() async {
    final link = ref.keepAlive();

    ref.onCancel(() {
      _evictionTimer?.cancel();
      _evictionTimer = Timer(_cacheEvictionDuration, () {
        link.close();
      });
    });

    ref.onResume(() {
      _evictionTimer?.cancel();
      _evictionTimer = null;
    });

    ref.onDispose(() {
      _evictionTimer?.cancel();
    });
    
    return _fetchFriendsProgressively();
  }
  
  Future<List<VrcUser>> _fetchFriendsProgressively() async {
    final repo = await ref.watch(socialRepositoryProvider.future);
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
      ISocialRepository repo,
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
  final repo = await ref.watch(socialRepositoryProvider.future);
  final result = await repo.getFavoriteGroups();

  return result.fold(
        (failure) => [],
        (groups) => groups,
  );
}

sealed class FlatFriendItem {}

class FlatCategoryHeader extends FlatFriendItem {
  final FriendGroupCategory category;
  final int depth;
  FlatCategoryHeader(this.category, this.depth);
}

class FlatFriendTile extends FlatFriendItem {
  final VrcUser user;
  final int depth;
  FlatFriendTile(this.user, this.depth);

}

@riverpod
Future<List<FriendGroupCategory>> structuredFriendsList(Ref ref) async {
  final friends = await ref.watch(friendsListProvider.future);
  final favGroups = await ref.watch(favoriteFriendGroupsProvider.future);
  final query = ref.watch(friendsSearchQueryProvider).toLowerCase();
  
  final uniqueWorldIds = friends
    .where((f) => !f.isTrulyOffline && f.status.toLowerCase() != "active")
    .map((f) => VrcInstance.parse(f.location).worldId)
    .whereType<String>()
    .toSet();
  
  final Map<String, String> resolvedWorldNames = {};
  for (final worldId in uniqueWorldIds) {
    resolvedWorldNames[worldId] = await ref.watch(worldNameProvider(worldId).future);
  }
  
  return await Isolate.run(() {
    final useCase = CategorizeFriendsUseCase(
      friends: friends,
      favoriteGroups: favGroups,
      worldNames: resolvedWorldNames,
      searchQuery: query,
    );
    return useCase.execute();
  });
}

@Riverpod(keepAlive: true)
class CollapsedCategories extends _$CollapsedCategories {
  @override
  Set<String> build() => {};
  
  void toggle(String categoryId) {
    if (state.contains(categoryId)) {
      state = {...state}..remove(categoryId);
    } else {
      state = {...state}..add(categoryId);
    }
  }
}

@riverpod
List<FlatFriendItem> flatFriendsList(Ref ref) {
  final categoriesAsync = ref.watch(structuredFriendsListProvider);
  final collapsedSet = ref.watch(collapsedCategoriesProvider);
  
  return categoriesAsync.maybeWhen(
    data: (categories) {
      final List<FlatFriendItem> flatList = [];
      
      void flatten(FriendGroupCategory cat, int depth) {
        flatList.add(FlatCategoryHeader(cat, depth));
        
        if (!collapsedSet.contains(cat.id)) {
          for (var sub in cat.subCategories) {
            flatten(sub, depth + 1);
          }
          
          for (var friend in cat.friends) {
            flatList.add(FlatFriendTile(friend, depth + 1));
          }
        }
      }
      
      for (var c in categories) {
        flatten(c, 0);
      }
      return flatList;
    },
    orElse: () => [],
  );
}