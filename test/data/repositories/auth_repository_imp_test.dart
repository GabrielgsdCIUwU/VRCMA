import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrchat_dart/vrchat_dart.dart' hide Response;
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/data/repositories/auth_repository_imp.dart';

import '../../helpers/test_mocks.mocks.dart';

class DummyAuthResponse {
  final bool requiresTwoFactorAuth;
  final List<DummyAuthType> twoFactorAuthTypes;

  DummyAuthResponse({
    required this.requiresTwoFactorAuth,
    required this.twoFactorAuthTypes,
  });
}

class DummyAuthType {
  final String name;
  DummyAuthType(this.name);
}

class FakeCurrentUser extends Fake implements CurrentUser {
  @override
  final String id;
  @override
  final String displayName;
  @override
  final List<String> tags;
  @override
  final UserStatus status;
  @override
  final String userIcon;
  @override
  final String profilePicOverrideThumbnail;
  @override
  final String currentAvatarThumbnailImageUrl;
  @override
  final String currentAvatarImageUrl;
  @override
  final String bio;

  FakeCurrentUser({
    required this.id,
    this.displayName = 'Test User',
    this.tags = const [],
    this.status = UserStatus.active,
    this.userIcon = '',
    this.profilePicOverrideThumbnail = '',
    this.currentAvatarThumbnailImageUrl = '',
    this.currentAvatarImageUrl = '',
    this.bio = '',
  });
}

class FakeError {
  final String error;
  FakeError(this.error);
}

void main() {
  late MockVrchatDart mockVrcApi;
  late MockAuthApi mockAuthApi;
  late AuthRepositoryImp repository;

  setUp(() {
    mockVrcApi = MockVrchatDart();
    mockAuthApi = MockAuthApi();

    when(mockVrcApi.auth).thenReturn(mockAuthApi);
    repository = AuthRepositoryImp(mockVrcApi);
  });

  group('AuthRepositoryImp - Authentication Flow', () {
    const username = 'test_user';
    const password = 'amazing_password_bro';

    test('should return VrcUser when login is successful and no 2FA is required', () async {
      final currentUser = FakeCurrentUser(id: 'usr_123');
      final authResponse = DummyAuthResponse(
        requiresTwoFactorAuth: false,
        twoFactorAuthTypes: [],
      );

      final response = Response<dynamic>(
        data: authResponse,
        requestOptions: RequestOptions(path: '')
      );

      when(mockAuthApi.login(username: username, password: password))
        .thenAnswer((_) async => (response, null) as dynamic);
      
      when(mockAuthApi.currentUser).thenReturn(currentUser);

      final result = await repository.login(username, password);

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure'),
        (user) => expect(user.id, currentUser.id),
      );
    });

    test('should return TwoFactorRequiredFailure when API requests 2FA verification', () async {
      final authResponse = DummyAuthResponse(
        requiresTwoFactorAuth: true,
        twoFactorAuthTypes: [DummyAuthType('emailOtp'), DummyAuthType('totp')],
      );

      final response = Response<dynamic>(
        data: authResponse,
        requestOptions: RequestOptions(path: '')
      );

      when(mockAuthApi.login(username: username, password: password))
        .thenAnswer((_) async => (response, null) as dynamic);
      
      final result = await repository.login(username, password);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<TwoFactorRequiredFailure>());
          expect((failure as TwoFactorRequiredFailure).methods, containsAll(['emailOtp', 'totp']));
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should map VRChat API Error to ApiFailure', () async {
      final error = FakeError('Invalid credentials');

      when(mockAuthApi.login(username: username, password: password))
        .thenAnswer((_) async => (null, error) as dynamic);
      
      final result = await repository.login(username, password);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, contains('Invalid credentials'));
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should map internal connection timeout to specialized ApiFailure message', () async {
      when(mockAuthApi.login(username: username, password: password))
        .thenThrow(Exception('connection timeout occurred'));

      final result = await repository.login(username, password);

      result.fold(
        (failure) => expect(failure.message, contains('Check your internet connection')),
        (_) => fail('Should return failure'),
      );
    });
  });
}