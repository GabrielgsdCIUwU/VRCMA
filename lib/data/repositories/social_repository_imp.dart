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
  Future<Either<Failure, List<VrcUser>>> getFriends() async {
    try {
      final response = await _vrcApi.rawApi.getFriendsApi().getFriends(
        offset: 0,
        n: 100,
        offline: false
      );
      
      final users = response.data?.map((u) => VrcUserModel.fromLibrary(u)).toList() ?? [];
      return Right(users);
    } catch (e) {
      return Left(ApiFailure('Failed to fetch friends: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<FavoriteGroup>>> getFavoriteGroups() async {
    try {
      final response = await _vrcApi.rawApi.getFavoritesApi().getFavoriteGroups();
      final groups = response.data ?? [];

      final favoriteGroups = groups
          .where((g) => g.type == FavoriteType.friend)
          .map((g) => FavoriteGroup(id: g.name, name: g.displayName))
          .toList();

      return Right(favoriteGroups);
    } catch (e) {
      return Left(ApiFailure('Failed to fetch favorite groups: $e'));
    }
  }
}