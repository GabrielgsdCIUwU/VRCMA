import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/core/network/sanitizer/rules/current_user_sanitizer_rule.dart';

void main() {
  group('CurrentUserSanitizerRule', () {
    final rule = CurrentUserSanitizerRule();

    test('should handle only GET /auth/user requests', () {
      expect(
        rule.canHandle(RequestOptions(path: '/auth/user', method: 'GET')),
        isTrue,
      );
      expect(
        rule.canHandle(RequestOptions(path: '/auth/user', method: 'PUT')),
        isFalse,
      );
      expect(
        rule.canHandle(RequestOptions(path: '/groups/grp_1', method: 'GET')),
        isFalse,
      );
    });

    test('should fill missing CurrentUser keys with safe defaults', () {
      final rawPayload = <String, dynamic>{
        'id': 'usr_123',
        'displayName': 'Gabrielgsd',
      };

      final sanitized = rule.sanitize(rawPayload) as Map<String, dynamic>;

      expect(sanitized['bio'], '');
      expect(sanitized['bioLinks'], isEmpty);
      expect(sanitized['profilePicOverride'], '');
      expect(sanitized['profilePicOverrideThumbnail'], '');
      expect(sanitized['userIcon'], '');
    });

    test('should not alter 2FA challenge payloads', () {
      final challengePayload = <String, dynamic>{
        'requiresTwoFactorAuth': ['totp', 'emailOtp'],
      };

      final sanitized = rule.sanitize(challengePayload) as Map<String, dynamic>;

      expect(sanitized.containsKey('bio'), isFalse);
      expect(sanitized['requiresTwoFactorAuth'], ['totp', 'emailOtp']);
    });
  });
}