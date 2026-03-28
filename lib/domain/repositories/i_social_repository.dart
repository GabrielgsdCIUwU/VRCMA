import 'package:dartz/dartz.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';

abstract class ISocialRepository {
  Future<Either<Failure, List<VrcUser>>> getFriends();
}