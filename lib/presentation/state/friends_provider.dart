import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/data/repositories/social_repository_imp.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/usecases/automation/process_friend_automations_use_case.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

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