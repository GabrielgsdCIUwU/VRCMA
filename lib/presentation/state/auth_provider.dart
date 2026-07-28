import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:pool/pool.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';
import 'package:vrcma/data/models/vrc_user_model.dart';
import 'package:vrcma/data/repositories/auth_repository_imp.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/repositories/i_auth_repository.dart';
import 'package:vrcma/core/di/network_provider.dart';
import 'package:vrcma/core/network/sanitizer/rules/group_permission_sanitizer_rule.dart';
import 'package:vrcma/core/network/vrc_enum_sanitizer_interceptor.dart';

//! Run: dart run build_runner build
part 'auth_provider.g.dart';

/// Keeps track of whether the application has performed its initial
/// check for an existing active user session.
@riverpod
class InitialSessionChecked extends _$InitialSessionChecked {
  @override
  bool build() => false;

  void setChecked() {
    state = true;
  }
}

/// Holds the state of whether the OTP form is currently being displayed.
/// This prevents losing the view state when transitioning or switching apps.
@riverpod
class ShowOtpView extends _$ShowOtpView {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }
}

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
  
  client.rawApi.dio.interceptors.removeWhere(
      (interceptor) => interceptor.runtimeType.toString() == 'CookieManager'
  );
  
  client.rawApi.dio.options.connectTimeout = const Duration(seconds: 15);
  client.rawApi.dio.options.receiveTimeout = const Duration(seconds: 15);
  
  // Añadimos el interceptor sanitizador para prevenir errores de enums desconocidos
  client.rawApi.dio.interceptors.add(VrcEnumSanitizerInterceptor([
    GroupPermissionSanitizerRule(),
  ]));
  
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
  StreamSubscription? _streamSubscription;

  @override
  FutureOr<VrcUser?> build() async {
    final api = await ref.watch(vrcApiProvider.future);

    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    VrcUser? currentUser;
    try {
      final response = await api.rawApi.getAuthenticationApi().getCurrentUser();
      if (response.data != null) {
        currentUser = VrcUserModel.fromCurrentUser(response.data!);
      }
    }catch (e) {
      currentUser = null;
    } finally {
      ref.read(initialSessionCheckedProvider.notifier).setChecked();
    }
    
    if (currentUser != null) {
      final automationRepo = await ref.watch(automationRepositoryProvider.future);

      _streamSubscription = automationRepo.watchAutomationEvents().listen((event) {
        final currentData = state.value;
        if (currentData == null) return;

        if (event is UserProfileUpdatedEvent && event.userId == currentData.id) {
          final updatedUser = VrcUser(
            id: currentData.id,
            displayName: event.displayName.isNotEmpty
              ? event.displayName
              : currentData.displayName,
            bio: event.statusDescription,
            tags: currentData.tags,
            location: currentData.location,
            status: event.status,
            avatarUrl: currentData.avatarUrl,
          );
          state = AsyncData(updatedUser);
        } else if (event is UserLocationUpdatedEvent && event.userId == currentData.id) {
          final updatedUser = VrcUser(
            id: currentData.id,
            displayName: currentData.displayName,
            bio: currentData.bio,
            tags: currentData.tags,
            location: event.location,
            status: currentData.status,
            avatarUrl: currentData.avatarUrl,
          );
          state = AsyncData(updatedUser);
        }
      });
    }
    return currentUser;
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

  void reset() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
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

final _imageResolutionLock = Pool(3, timeout: const Duration(seconds: 15));
@riverpod
Future<String> vrcResolvedImage(Ref ref, String imageUrl) async {
  if (imageUrl.isEmpty) return '';

  ref.keepAlive();
  
  return await _imageResolutionLock.withResource(() async {
    final api = await ref.watch(vrcApiProvider.future);

    try {
      final response = await api.rawApi.dio.head(
        imageUrl,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => true,
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 404 || response.statusCode == 403 || response.statusCode == 429) {
        return '';
      }

      await Future.delayed(const Duration(milliseconds: 100));

      return response.realUri.toString();
    } catch (e) {
      debugPrint("Error resolving image: $e");
      return imageUrl;
    }
  });
}


