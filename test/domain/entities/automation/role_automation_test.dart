import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';
import 'package:vrcma/domain/error/domain_exception.dart';

void main() {
  group('RoleAutomation Entity & Validation Tests', () {
    const roleVip = Role(id: 1, name: 'VIP');

    test('validate succeeds on valid newFriend trigger without targetValue', () {
      const automation = RoleAutomation(
        id: 1,
        trigger: AutomationTrigger.newFriend,
        roles: [roleVip],
      );

      expect(() => automation.validate(), returnsNormally);
    });

    test('validate succeeds on valid hasTag trigger with non-empty targetValue', () {
      const automation = RoleAutomation(
        id: 2,
        trigger: AutomationTrigger.hasTag,
        targetValue: 'language_eng',
        roles: [roleVip],
      );

      expect(() => automation.validate(), returnsNormally);
    });

    test('validate throws RoleAutomationValidationException when roles list is empty', () {
      const automation = RoleAutomation(
        id: 3,
        trigger: AutomationTrigger.newFriend,
        roles: [],
      );

      expect(
        () => automation.validate(),
        throwsA(isA<RoleAutomationValidationException>().having(
          (e) => e.error,
          'error',
          isA<EmptyRoleAssignmentError>(),
        )),
      );
    });

    test('validate throws RoleAutomationValidationException when hasTag trigger lacks targetValue', () {
      const automationNullTag = RoleAutomation(
        trigger: AutomationTrigger.hasTag,
        targetValue: null,
        roles: [roleVip],
      );

      const automationEmptyTag = RoleAutomation(
        trigger: AutomationTrigger.hasTag,
        targetValue: '   ',
        roles: [roleVip],
      );

      expect(
        () => automationNullTag.validate(),
        throwsA(isA<RoleAutomationValidationException>().having(
          (e) => e.error,
          'error',
          isA<MissingTriggerTagError>(),
        )),
      );

      expect(
        () => automationEmptyTag.validate(),
        throwsA(isA<RoleAutomationValidationException>().having(
          (e) => e.error,
          'error',
          isA<MissingTriggerTagError>(),
        )),
      );
    });

    test('copyWith creates new instance with selectively updated fields', () {
      const automation = RoleAutomation(
        id: 1,
        trigger: AutomationTrigger.newFriend,
        roles: [roleVip],
      );

      final updated = automation.copyWith(
        trigger: AutomationTrigger.hasTag,
        targetValue: 'system_supporter',
      );

      expect(updated.id, 1);
      expect(updated.trigger, AutomationTrigger.hasTag);
      expect(updated.targetValue, 'system_supporter');
      expect(updated.roles, [roleVip]);
    });

    test('supports structural value equality via Equatable', () {
      const auto1 = RoleAutomation(id: 1, trigger: AutomationTrigger.newFriend, roles: [roleVip]);
      const auto2 = RoleAutomation(id: 1, trigger: AutomationTrigger.newFriend, roles: [roleVip]);

      expect(auto1, equals(auto2));
      expect(auto1.hashCode, equals(auto2.hashCode));
    });
  });
}