import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/core/di/network_provider.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

import '../helpers/test_mocks.mocks.dart';

void main() {
  late MockIAuthRepository mockAuthRepository;
  late MockCookieJar mockCookieJar;
  late MockVrchatDart mockVrcApi;
  
  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    mockCookieJar = MockCookieJar();
    mockVrcApi = MockVrchatDart();
  });
  
  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) => mockAuthRepository),
        cookieJarProvider.overrideWith((ref) => mockCookieJar),
        vrcApiProvider.overrideWith((ref) => mockVrcApi),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }
  
  group('AuthState Provider', () {
    const tUser = VrcUser(
      id: 'usr_1',
      displayName: 'TestUser',
      tags: [],
      avatarUrl: 'http://avatar.url'
    );
    
    test('Login success should update state to AsyncData(VrcUser)', () async {
      when(mockAuthRepository.login('test', 'password'))
          .thenAnswer((_) async => const Right(tUser));
      
      final container = makeProviderContainer();
      
      final notifier = container.read(authStateProvider.notifier);
      
      await notifier.login('test', 'password');
      
      final state = container.read(authStateProvider);
      expect(state, isA<AsyncData<VrcUser?>>());
      expect(state.value, tUser);
    });
    
    test('Login failure with 2FA required should update state with TwoFactorRequiredFailure', () async {
      final tFailure = TwoFactorRequiredFailure(['emailOtp']);
      when(mockAuthRepository.login('test', 'password'))
          .thenAnswer((_) async => Left(tFailure));
      
      final container = makeProviderContainer();
      final notifier = container.read(authStateProvider.notifier);
      
      await notifier.login('test', 'password');
      
      final state = container.read(authStateProvider);
      expect(state.hasError, true);
      expect(state.error, isA<TwoFactorRequiredFailure>());
    });
    
    test('Verify OTP success should update state to AsyncData(VrcUser)', () async {
      when(mockAuthRepository.verify2FA('123456'))
          .thenAnswer((_) async => const Right(tUser));
      
      final container = makeProviderContainer();
      final notifier = container.read(authStateProvider.notifier);
      
      await notifier.verifyOtp('123456');
      
      final state = container.read(authStateProvider);
      expect(state.value, tUser);
    });
    
    test('Logout should call repository and set state to AsyncData(null)', () async {
      when(mockAuthRepository.logout()).thenAnswer((_) async {});
      
      final container = makeProviderContainer();
      final notifier = container.read(authStateProvider.notifier);
      
      await notifier.logout();
      
      verify(mockAuthRepository.logout()).called(1);
      final state = container.read(authStateProvider);
      expect(state.value, isNull);
    });
  });
}