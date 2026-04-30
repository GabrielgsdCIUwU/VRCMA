import 'package:dartz/dartz.dart';
import 'package:vrchat_dart/vrchat_dart.dart' hide FavoriteGroup;
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/data/models/vrc_user_model.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/favorite_group.dart';
import 'package:vrcma/domain/repositories/i_social_repository.dart';

class SocialRepositoryImp implements ISocialRepository {
  final VrchatDart _vrcApi;
  SocialRepositoryImp(this._vrcApi);
  
  @override
  Future<Either<Failure, List<VrcUser>>> getFriends({bool offline = false}) async {
    try {
      final users = await _fetchFriendsPaginated(offline: offline);
      return Right(users);
    } catch (e) {
      return Left(ApiFailure('Failed to fetch friends: $e'));
    }
  }
  
  Future<List<VrcUserModel>> _fetchFriendsPaginated({required bool offline}) async {
    List<VrcUserModel> allFriends = [];
    int offset = 0;
    const int limit = 100;
    bool hasMore = true;
    
    while (hasMore) {
      final response = await _vrcApi.rawApi.getFriendsApi().getFriends(
        offset: offset,
        n: limit,
        offline: offline,
      );
      
      final currentBatch = response.data?.map((u) => VrcUserModel.fromLibrary(u)).toList() ?? [];
      allFriends.addAll(currentBatch);
      
      if (currentBatch.length < limit) {
        hasMore = false;
      } else {
        offset += limit;
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }
    return allFriends;
  }
  
  @override
  Future<Either<Failure, List<FavoriteGroup>>> getFavoriteGroups() async {
    try {
      final response = await _vrcApi.rawApi.getFavoritesApi().getFavoriteGroups();
      final groups = response.data ?? [];

      List<Favorite> allFavorites = [];
      int offset = 0;
      int limit = 100;
      bool hasMore = true;
      
      while (hasMore) {
        final favoriteResponse = await _vrcApi.rawApi.getFavoritesApi().getFavorites(
          n: limit,
          offset: offset,
        );
        final favorites = favoriteResponse.data ?? [];
        allFavorites.addAll(favorites);
        
        if (favorites.length < 100) {
          hasMore = false;
        } else {
          offset += limit;
        }
      }
      
      final favoriteGroups = groups
        .where((g) => g.type == FavoriteType.friend)
        .map((g) {
          final friendIds = allFavorites
              .where((f) => f.type == FavoriteType.friend && f.tags.contains(g.name))
              .map((f) => f.favoriteId)
              .toList();
          
          return FavoriteGroup(
            id: g.name,
            name: g.name,
            friendIds: friendIds,
          );
      }).toList();
      
      return Right(favoriteGroups);
    } catch (e) {
      return Left(ApiFailure('Failed to fetch favorite groups: $e'));
    }
  }
}