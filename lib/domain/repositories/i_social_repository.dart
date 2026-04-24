import 'package:dartz/dartz.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/favorite_group.dart';

abstract class ISocialRepository {
  Future<Either<Failure, List<VrcUser>>> getFriends();
  Future<Either<Failure, List<FavoriteGroup>>> getFavoriteGroups();
}