import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_template_resolver.dart';

void main() {
  group('StatusTemplateResolver Tests', () {
    final resolver = StatusTemplateResolver();

    test('should resolve all placeholders correctly with valid inputs', () {
      final context = StatusContext(
        worldName: 'Home',
        worldId: 'wrld_default',
        population: 23,
        instanceType: InstanceAccessType.friendsPlus,
        batteryLevel: 84,
        isCharging: false,
        timestamp: DateTime(2026, 7, 9, 8, 5),
        presentFriendNames: ['Alice', 'Bob'],
      );

      const template = '{{world}} ({{count}}). {{battery}}. {{time}}. {{friends}}';
      final result = resolver.resolve(template, context);

      expect(result, contains('Home'));
      expect(result, contains('(23)'));
      expect(result, contains('84%'));
      expect(result, contains('08:05'));
      expect(result, contains('Alice, Bob'));
    });

    test('should enforce VRChat maximum character length restriction and append ellipses', () {
      final context = StatusContext(
        worldName: 'This is an exceptionally long world name that will definitely overflow the limit',
        worldId: 'wrld_long_1',
        population: 5,
        instanceType: InstanceAccessType.public,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      final template = 'Playing in {{world}} with others';
      final result = resolver.resolve(template, context);

      expect(result.length, lessThanOrEqualTo(42));
      expect(result.endsWith('...'), isTrue);
    });

    test('should handle empty template inputs by returning an empty string', () {
      final context = StatusContext(
        worldName: 'Gabrielgsd avatars',
        worldId: 'wrld_skip_ad',
        population: 1,
        instanceType: InstanceAccessType.inviteOnly,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      final result = resolver.resolve('', context);
      expect(result, isEmpty);
    });
  });
}