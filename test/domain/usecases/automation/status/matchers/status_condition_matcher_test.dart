import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_condition_matcher.dart';

import '../../../../../helpers/test_mocks.mocks.dart';

class MockLocalSocialRepository extends Mock implements ILocalSocialRepository {}

void main() {
  group('NumericConditionMatcher Tests', () {
    final matcher = NumericConditionMatcher();

    test('should match population using greatherThan operator', () async {
      final rule = StatusRule(
        priority: 1,
        targetStatus: StatusType.busy,
        conditionType: ConditionType.population,
        operator: RuleOperator.greaterThan,
        conditionValue: '10',
      );

      final contextMatches = StatusContext(
        worldName: 'Target World',
        worldId: 'wrld_1',
        population: 15,
        instanceType: InstanceAccessType.friends,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      final contextDoesNotMatch = StatusContext(
        worldName: 'Target World',
        worldId: 'wrld_1',
        population: 5,
        instanceType: InstanceAccessType.friends,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      expect(await matcher.matches(rule, contextMatches), isTrue);
      expect(await matcher.matches(rule, contextDoesNotMatch), isFalse);
    });

    test('should match batteryLevel using between operator', () async {
      final rule = StatusRule(
        priority: 1,
        targetStatus: StatusType.askMe,
        conditionType: ConditionType.batteryLevel,
        operator: RuleOperator.between,
        conditionValue: '20-50',
      );

      final contextInBetween = StatusContext(
        worldName: 'Target World',
        worldId: 'wrld_1',
        population: 1,
        instanceType: InstanceAccessType.inviteOnly,
        batteryLevel: 35,
        isCharging: false,
        timestamp: DateTime.now(),
      );

      final contextOutside = StatusContext(
        worldName: 'Target World',
        worldId: 'wrld_1',
        population: 1,
        instanceType: InstanceAccessType.inviteOnly,
        batteryLevel: 60,
        isCharging: false,
        timestamp: DateTime.now(),
      );

      expect(await matcher.matches(rule, contextInBetween), isTrue);
      expect(await matcher.matches(rule, contextOutside), isFalse);
    });

    test('should handle malformed range values gracefully by returning false', () async {
      final rule = StatusRule(
        priority: 1,
        targetStatus: StatusType.active,
        conditionType: ConditionType.batteryLevel,
        operator: RuleOperator.between,
        conditionValue: 'invalid_range',
      );

      final context = StatusContext(
        worldName: 'Target World',
        worldId: 'wrld_1',
        population: 1,
        instanceType: InstanceAccessType.public,
        batteryLevel: 50,
        isCharging: false,
        timestamp: DateTime.now(),
      );

      expect(await matcher.matches(rule, context), isFalse);
    });
  });

  group('InstanceTypeMatcher Tests', () {
    final matcher = InstanceTypeMatcher();

    test('should match instance access types precisely', () async {
      final rule = StatusRule(
        priority: 2,
        targetStatus: StatusType.joinMe,
        conditionType: ConditionType.instanceType,
        operator: RuleOperator.equalTo,
        conditionValue: 'friendsPlus',
      );

      final contextMatches = StatusContext(
        worldName: 'Target World',
        worldId: 'wrld_1',
        population: 2,
        instanceType: InstanceAccessType.friendsPlus,
        batteryLevel: 90,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      final contextDoesNotMatch = StatusContext(
        worldName: 'Target World',
        worldId: 'wrld_1',
        population: 2,
        instanceType: InstanceAccessType.public,
        batteryLevel: 90,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      expect(await matcher.matches(rule, contextMatches), isTrue);
      expect(await matcher.matches(rule, contextDoesNotMatch), isFalse);
    });
  });

  group('WorldConditionMatcher Tests', () {
    final matcher = WorldConditionMatcher();
    test('should match world ID exact comparison', () async {
      final rule = StatusRule(
        priority: 3,
        targetStatus: StatusType.busy,
        conditionType: ConditionType.world,
        operator: RuleOperator.equalTo,
        conditionValue: 'wrld_target_123',
      );

      final contextMatches = StatusContext(
        worldName: 'World 1',
        worldId: 'wrld_target_123',
        population: 1,
        instanceType: InstanceAccessType.friends,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      final contextDoesNotMatch = StatusContext(
        worldName: 'World 1',
        worldId: 'wrld_target_000',
        population: 1,
        instanceType: InstanceAccessType.friends,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      expect(await matcher.matches(rule, contextMatches), isTrue);
      expect(await matcher.matches(rule, contextDoesNotMatch), isFalse);
    });

    test('should match world ID list contains condition', () async {
      final rule = StatusRule(
        priority: 3,
        targetStatus: StatusType.busy,
        conditionType: ConditionType.world,
        operator: RuleOperator.contains,
        conditionValue: 'wrld_a, wrld_b, wrld_c',
      );

      final contextMatches = StatusContext(
        worldName: 'World B',
        worldId: 'wrld_b',
        population: 1,
        instanceType: InstanceAccessType.friends,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      final contextDoesNotMatch = StatusContext(
        worldName: 'World Z',
        worldId: 'wrld_z',
        population: 1,
        instanceType: InstanceAccessType.friends,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      expect(await matcher.matches(rule, contextMatches), isTrue);
      expect(await matcher.matches(rule, contextDoesNotMatch), isFalse);
    });
  });

  group('TimeRangeConditionMatcher Tests', () {
    final matcher = TimeRangeConditionMatcher();

    test('should match simple time range within the same day', () async {
      final rule = StatusRule(
        priority: 4,
        targetStatus: StatusType.active,
        conditionType: ConditionType.timeRange,
        operator: RuleOperator.between,
        conditionValue: '14:00-16:00',
      );

      final contextInside = StatusContext(
        worldName: 'World',
        worldId: 'wrld_1',
        population: 1,
        instanceType: InstanceAccessType.public,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime(2026, 7, 9, 15, 30),
      );

      final contextOutside = StatusContext(
        worldName: 'World',
        worldId: 'wrld_1',
        population: 1,
        instanceType: InstanceAccessType.public,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime(2026, 7, 9, 17, 0),
      );

      expect(await matcher.matches(rule, contextInside), isTrue);
      expect(await matcher.matches(rule, contextOutside), isFalse);
    });

    test('should match overnight time range across midnight bounds', () async {
      final rule = StatusRule(
        priority: 4,
        targetStatus: StatusType.active,
        conditionType: ConditionType.timeRange,
        operator: RuleOperator.between,
        conditionValue: '22:00-04:00',
      );

      final contextLateNight = StatusContext(
        worldName: 'World',
        worldId: 'wrld_1',
        population: 1,
        instanceType: InstanceAccessType.public,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime(2026, 7, 9, 23, 30),
      );

      final contextEarlyMorning = StatusContext(
        worldName: 'World',
        worldId: 'wrld_1',
        population: 1,
        instanceType: InstanceAccessType.public,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime(2026, 7, 9, 2, 0),
      );

      final contextDuringDay = StatusContext(
        worldName: 'World',
        worldId: 'wrld_1',
        population: 1,
        instanceType: InstanceAccessType.public,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime(2026, 7, 10, 12, 0),
      );

      expect(await matcher.matches(rule, contextLateNight), isTrue);
      expect(await matcher.matches(rule, contextEarlyMorning), isTrue);
      expect(await matcher.matches(rule, contextDuringDay), isFalse);
    });
  });

  group('FriendRoleMatcher Tests', () {
    test('should verify if target role member is present in context', () async {
      final mockLocalSocial = MockILocalSocialRepository();
      final matcher = FriendRoleMatcher(mockLocalSocial);

      final rule = StatusRule(
        priority: 5,
        targetStatus: StatusType.joinMe,
        conditionType: ConditionType.friendPresent,
        operator: RuleOperator.equalTo,
        conditionValue: '99',
      );

      final context = StatusContext(
        worldName: 'World',
        worldId: 'wrld_1',
        population: 2,
        instanceType: InstanceAccessType.public,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime.now(),
        presentFriendIds: const ['usr_friend'],
      );

      when(mockLocalSocial.getUserIdsByRole(99)).thenAnswer((_) async => ['usr_friend']);

      expect(await matcher.matches(rule, context), isTrue);
    });
  });
}