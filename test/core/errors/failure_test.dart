import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/domain/error/domain_exception.dart';

void main() {
  group('Failures Core Tests', () {
    test('ApiFailure should contain a correct message', () {
      const message = 'Error 401: Unauthorized';
      const failure = ApiFailure(message);
      
      expect(failure.message, message);
    });
    
    test('TwoFactorRequiredFailure should contain a correct methods', () {
      final methods = ['emailOtp', 'totp'];
      final failure = TwoFactorRequiredFailure(methods);
      
      expect(failure.methods, methods);
      expect(failure.message, '2FA required');
    });
    
    test('DatabaseFailure should store the correct message', () {
      const message = 'Database connection lost';
      const failure = DatabaseFailure(message);
      expect(failure.message, message);
    });

    test('RateLimitFailure should contain calculated minutes message', () {
      const failure = RateLimitFailure(60);
      expect(failure.retryAfterMinutes, 60);
      expect(failure.message, contains('60 minutes'));
    });

    test('NetworkTimeoutFailure should contain default timeout message', () {
      const failure = NetworkTimeoutFailure();
      expect(failure.message, 'Connection timed out. Check your internet connection.');
    });

    test('DomainFailure should contain domain exception message', () {
      final exception = DuplicateRoleException('Admin');
      final failure = DomainFailure(exception);
      expect(failure.message, exception.defaultMessage);
      expect(failure.exception, exception);
    });
  });
}