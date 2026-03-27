import 'package:dartz/dartz.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/data/models/vrc_user_model.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/repositories/i_auth_repository.dart';

/// Implementation of [IAuthRepository] using the vrchat_dart package.
class AuthRepositoryImp implements IAuthRepository {
  final VrchatDart _vrcApi;

  AuthRepositoryImp(this._vrcApi);

  @override
  Future<Either<Failure, VrcUser>> login(String username, String password) async {
    try {
      final (success, failure) = await _vrcApi.auth.login(
        username: username,
        password: password,
      );

      if (failure != null) {
        return Left(ApiFailure('Error: ${failure.error}'));
      }

      final authResponse = success!.data;
      if (authResponse.requiresTwoFactorAuth) {
        final methods = authResponse.twoFactorAuthTypes
            .map((e) => e.name)
            .toList();
        return Left(TwoFactorRequiredFailure(methods));
      }

      final currentUser = _vrcApi.auth.currentUser;
      if(currentUser == null) {
        return Left(ApiFailure('Unexpected error: currentUser is null'));
      }
      return Right(VrcUserModel.fromLibrary(currentUser));
    } catch (e) {
      if (e.toString().contains("connection timeout")) {
        return Left(ApiFailure('Connection timeout. Check your internet connection'));
      }
      return Left(ApiFailure('Unexpected connection error: $e'));
    }
  }

  @override
  Future<Either<Failure, VrcUser>> verify2FA(String code) async {
    try {
      final (success, failure) = await _vrcApi.auth.verify2fa(code);

      if (failure != null) {
        return Left(ApiFailure('Invalid code: ${failure.error}'));
      }

      final currentUser = _vrcApi.auth.currentUser;
      if (currentUser == null) {
        return Left(ApiFailure('Error getting user after 2FA verification'));
      }
      return Right(VrcUserModel.fromLibrary(currentUser));
    } catch (e) {
      return Left(ApiFailure('Unexpected 2FA process error: $e'));
    }
  }

  @override
  Future<void> logout() async {
    await _vrcApi.auth.logout();
  }
}