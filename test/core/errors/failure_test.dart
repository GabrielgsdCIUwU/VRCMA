import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/core/errors/failure.dart';

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
  });
}