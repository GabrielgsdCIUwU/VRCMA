import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/data/models/vrc_user_model.dart';
import 'package:vrcma/data/repositories/auth_repository_imp.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/repositories/i_auth_repository.dart';
import 'package:vrcma/core/di/network_provider.dart';

//! Run: dart run build_runner build
part 'auth_provider.g.dart';

/// Provider for the VRChat API client.
/// It generates [vrcApiProvider].
@riverpod
Future<VrchatDart> vrcApi(Ref ref) async {
  final jar = await ref.watch(cookieJarProvider.future);
  final client = VrchatDart(
      userAgent: VrchatUserAgent(
          applicationName: 'VRCMA',
          version: '1.0.0',
          contactInfo: 'contacto.gabrielsuarezdominguez@gmail.com'
      ),
  );
  
  client.rawApi.dio.interceptors.add(CookieManager(jar));
  return client;
}

/// Provider for the Auth Repository.
/// It generates [authRepositoryProvider].
@riverpod
Future<IAuthRepository> authRepository(Ref ref) async {
  final vrcApiClient = await ref.watch(vrcApiProvider.future);
  return AuthRepositoryImp(vrcApiClient);
}

/// State notifier for the Authentication logic.
@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<VrcUser?> build() async {
    final api = await ref.watch(vrcApiProvider.future);
    
    try {
      final response = await api.rawApi.getAuthenticationApi().getCurrentUser();
      if (response.data != null) {
        return VrcUserModel.fromCurrentUser(response.data!);
      }
    }catch (e) {
      return null;
    }
    return null;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    final repository = await ref.read(authRepositoryProvider.future);

    final result = await repository.login(username, password);

    result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> verifyOtp(String code) async {
    state = const AsyncValue.loading();
    final repository = await ref.read(authRepositoryProvider.future);

    final result = await repository.verify2FA(code);

    result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> logout() async {
    final jar = await ref.read(cookieJarProvider.future);
    await jar.deleteAll();
    
    final repository = await ref.read(authRepositoryProvider.future);
    repository.logout();
    
    state = const AsyncValue.loading();
    state = const AsyncValue.data(null);
  }
}

@riverpod
Future<Map<String, String>> vrcImageHeaders(Ref ref, String imageUrl) async {
  if (imageUrl.isEmpty) return {};
  
  final jar = await ref.watch(cookieJarProvider.future);

  final apiUri = Uri.parse('https://api.vrchat.cloud');
  final cookies = await jar.loadForRequest(apiUri);

  if (cookies.isEmpty) {
    final generalUri = Uri.parse('https://vrchat.com');
    cookies.addAll(await jar.loadForRequest(generalUri));
  }


  final cookieString = cookies
      .map((c) => '${c.name}=${c.value}')
      .join('; ');
  
  return {
    'User-Agent': 'VRCMA/1.0.0 contacto.gabrielsuarezdominguez@gmail.com',
    'Cookie': cookieString,
    'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
  };
}

@riverpod
Future<String> vrcResolvedImage(Ref ref, String imageUrl) async {
  if (imageUrl.isEmpty) return '';

  final api = await ref.watch(vrcApiProvider.future);

  try {
    final response = await api.rawApi.dio.get(
      imageUrl,
      options: Options(
        followRedirects: true,
        validateStatus: (status) => status! < 400,
        responseType: ResponseType.bytes,
      ),
    );

    return response.realUri.toString();
  } catch (e) {
    debugPrint("Error resolving image: $e");
    return imageUrl;
  }
}


