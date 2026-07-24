import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/error/domain_exception.dart';

void main() {
  group('RoleAutomation Domain Validation', () {
    test('validate should throw if roles list is empty', () {
      const automation = RoleAutomation(
        trigger: AutomationTrigger.newFriend,
        roles: [],
      );

      expect(
        () => automation.validate(),
        throwsA(isA<RoleAutomationValidationException>().having(
          (e) => e.error, 'error', isA<EmptyRoleAssignmentError>(),
        )),
      );
    });

    test('validate should throw if trigger is hasTag but targetValue is null or empty', () {
      const automation = RoleAutomation(
        trigger: AutomationTrigger.hasTag,
        roles: [Role(id: 1, name: 'VIP')],
        targetValue: '  ',
      );

      expect(
        () => automation.validate(),
        throwsA(isA<RoleAutomationValidationException>().having(
          (e) => e.error, 'error', isA<MissingTriggerTagError>(),
        )),
      );
    });
  });

  group('StatusRule Domain Validation', () {
    test('should throw if operator is incompatible with condition type', () {
      expect(
        () => StatusRule(
          priority: 1,
          targetStatus: StatusType.joinMe,
          conditionType: ConditionType.instanceType,
          operator: RuleOperator.greaterThan,
          conditionValue: 'Friends',
        ),
        throwsA(isA<StatusRuleValidationException>().having(
          (e) => e.error, 'error', isA<InvalidStatusOperatorError>(),
        )),
      );

      test('should throw if condition value is completely empty', () {
        expect(
          () => StatusRule(
            priority: 1,
            targetStatus: StatusType.joinMe,
            conditionType: ConditionType.population,
            operator: RuleOperator.equalTo,
            conditionValue: '  ',
          ),
          throwsA(isA<StatusRuleValidationException>().having(
            (e) => e.error, 'error', isA<EmptyStatusConditionValueError>(),
          ))
        );
      });
    });
  });
}