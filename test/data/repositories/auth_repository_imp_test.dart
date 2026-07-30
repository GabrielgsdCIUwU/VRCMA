import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/data/repositories/auth_repository_imp.dart';

import '../../helpers/test_mocks.mocks.dart';

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

    test('should map internal connection timeout to specialized ApiFailure message', () async {
      when(mockAuthApi.login(username: username, password: password))
          .thenThrow(Exception('connection timeout occurred'));
      
      final result = await repository.login(username, password);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('Check your internet connection')),
        (_) => fail('Should return failure'),
      );
    });

    test('should map general exceptions to generic ApiFailure', () async {
      when(mockAuthApi.login(username: username, password: password))
          .thenThrow(Exception('Invalid credentials'));
      
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