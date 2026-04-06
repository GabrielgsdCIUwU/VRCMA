import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';

void main() {
  group('FilterProfile and rules Entities Tests', () {
    const roleVIP = Role(id: 1, name: 'VIP');
    const roleGuest = Role(id: 2, name: 'Guest');
    
    test('ProfileRule copyWith should update only specified fields', () {
      const rule = ProfileRule(
        id: 1,
        role: roleVIP,
        priority: 0,
        action: RuleAction.accept
      );
      
      final updatedRule = rule.copyWith(action: RuleAction.reject);
      
      expect(updatedRule.action, RuleAction.reject);
      expect(updatedRule.role, roleVIP);
      expect(updatedRule.id, 1);
    });
    
    test('FilterProfile copyWith should handle list updates correctly', () {
      const profile = FilterProfile(name: 'Default', isActive: false);
      
      final rule = ProfileRule(role: roleGuest, priority: 1, action: RuleAction.accept);
      final updatedProfile = profile.copyWith(
        isActive: true,
        rules: [rule],
      );
      
      expect(updatedProfile.isActive, true);
      expect(updatedProfile.name, 'Default');
      expect(updatedProfile.rules.length, 1);
      expect(updatedProfile.rules.first.role.name, 'Guest');
    });
    
    test('Role equality should be based on ID and name', (){
      const r1 = Role(id: 1, name: 'Admin');
      const r2 = Role(id: 1, name: 'Admin');
      const r3 = Role(id: 2, name: 'Admin');

      expect(r1, equals(r2));
      expect(r1.hashCode, equals(r2.hashCode));
      expect(r1, isNot(equals(r3)));
      expect(r1.hashCode, isNot(equals(r3.hashCode)));
    });
  });
}