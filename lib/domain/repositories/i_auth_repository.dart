import 'package:dartz/dartz.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';

/// Interface defining authentication contracts.
abstract class IAuthRepository {
  /// Attempts to login to VRChat with credentials and 2FA if required.
  Future<Either<Failure, VrcUser>> login(String username, String password);

  Future<Either<Failure, VrcUser>> verify2FA(String code);

  Future<void> logout();
}