import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/error/domain_exception.dart';

void main() {
  group('StatusType Enum Mappings', () {
    test('apiValue matches VRChat web API standard representations', () {
      expect(StatusType.active.apiValue, 'active');
      expect(StatusType.joinMe.apiValue, 'join me');
      expect(StatusType.askMe.apiValue, 'ask me');
      expect(StatusType.busy.apiValue, 'busy');
    });

    test('fromString parses both apiValue and enum name, fallback to active', () {
      expect(StatusType.fromString('join me'), StatusType.joinMe);
      expect(StatusType.fromString('joinMe'), StatusType.joinMe);
      expect(StatusType.fromString('busy'), StatusType.busy);
      expect(StatusType.fromString('invalid_status'), StatusType.active);
    });
  });

  group('ConditionType Operators Specification', () {
    test('population and batteryLevel allow numeric comparison operators', () {
      const allowed = [
        RuleOperator.greaterThan,
        RuleOperator.lessThan,
        RuleOperator.equalTo,
        RuleOperator.between,
      ];
      expect(ConditionType.population.allowedOperators, containsAll(allowed));
      expect(ConditionType.batteryLevel.allowedOperators, containsAll(allowed));
    });

    test('timeRange allows between and equalTo operators', () {
      expect(ConditionType.timeRange.allowedOperators, containsAll([RuleOperator.between, RuleOperator.equalTo]));
      expect(ConditionType.timeRange.allowedOperators.contains(RuleOperator.greaterThan), isFalse);
    });

    test('world allows equalTo and contains operators', () {
      expect(ConditionType.world.allowedOperators, containsAll([RuleOperator.equalTo, RuleOperator.contains]));
    });

    test('instanceType and friendPresent allow only equalTo operator', () {
      expect(ConditionType.instanceType.allowedOperators, equals([RuleOperator.equalTo]));
      expect(ConditionType.friendPresent.allowedOperators, equals([RuleOperator.equalTo]));
    });
  });

  group('StatusRule Invariants & Validation', () {
    test('instantiates successfully with compatible operator and non-empty value', () {
      final rule = StatusRule(
        priority: 0,
        targetStatus: StatusType.joinMe,
        conditionType: ConditionType.population,
        operator: RuleOperator.greaterThan,
        conditionValue: '10',
        messageTemplate: 'Come over!',
      );

      expect(rule.targetStatus, StatusType.joinMe);
      expect(rule.conditionValue, '10');
    });

    test('throws StatusRuleValidationException when operator is incompatible with condition', () {
      expect(
        () => StatusRule(
          priority: 0,
          targetStatus: StatusType.busy,
          conditionType: ConditionType.instanceType,
          operator: RuleOperator.greaterThan,
          conditionValue: 'friends',
        ),
        throwsA(isA<StatusRuleValidationException>().having(
          (e) => e.error,
          'error',
          isA<InvalidStatusOperatorError>(),
        )),
      );
    });

    test('throws StatusRuleValidationException when conditionValue is empty or whitespace', () {
      expect(
        () => StatusRule(
          priority: 0,
          targetStatus: StatusType.busy,
          conditionType: ConditionType.population,
          operator: RuleOperator.equalTo,
          conditionValue: '   ',
        ),
        throwsA(isA<StatusRuleValidationException>().having(
          (e) => e.error,
          'error',
          isA<EmptyStatusConditionValueError>(),
        )),
      );
    });
  });

  group('StatusProfile Aggregate Tests', () {
    test('copyWith properly mutates aggregate state preserving unchanged attributes', () {
      const profile = StatusProfile(
        id: 1,
        name: 'Main Status Profile',
        isActive: false,
        fallbackStatus: StatusType.active,
        fallbackTemplate: 'Online in {{world}}',
      );

      final updated = profile.copyWith(
        isActive: true,
        fallbackStatus: StatusType.joinMe,
      );

      expect(updated.id, 1);
      expect(updated.name, 'Main Status Profile');
      expect(updated.isActive, isTrue);
      expect(updated.fallbackStatus, StatusType.joinMe);
      expect(updated.fallbackTemplate, 'Online in {{world}}');
    });

    test('supports structural value equality via Equatable', () {
      const profile1 = StatusProfile(
        id: 1,
        name: 'Profile',
        fallbackStatus: StatusType.active,
      );
      const profile2 = StatusProfile(
        id: 1,
        name: 'Profile',
        fallbackStatus: StatusType.active,
      );

      expect(profile1, equals(profile2));
      expect(profile1.hashCode, equals(profile2.hashCode));
    });
  });
}