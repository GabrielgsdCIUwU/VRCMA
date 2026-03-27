import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/data/repositories/auth_repository_imp.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/repositories/i_auth_repository.dart';

//! Run: dart run build_runner build
part 'auth_provider.g.dart';

/// Provider for the VRChat API client.
/// It generates [vrcApiProvider].
@riverpod
VrchatDart vrcApi(Ref ref) {
  return VrchatDart(
      userAgent: VrchatUserAgent(
          applicationName: 'VRCMA',
          version: '1.0.0',
          contactInfo: 'contacto.gabrielsuarezdominguez@gmail.com'
      ),
  );
}

/// Provider for the Auth Repository.
/// It generates [authRepositoryProvider].
@riverpod
IAuthRepository authRepository(Ref ref) {
  final vrcApiClient = ref.watch(vrcApiProvider);
  return AuthRepositoryImp(vrcApiClient);
}

/// State notifier for the Authentication logic.
@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<VrcUser?> build() => const AsyncValue.data(null);

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);

    final result = await repository.login(username, password);

    result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> verifyOtp(String code) async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);

    final result = await repository.verify2FA(code);

    result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }
}


