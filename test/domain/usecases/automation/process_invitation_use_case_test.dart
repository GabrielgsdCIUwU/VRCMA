import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';

void main() {
  late ProcessInvitationUseCase useCase;
  
  setUp(() {
    useCase = ProcessInvitationUseCase(
      roleExtractor: UserRoleExtractor(),
      ruleSorter: RuleSorter(),
      ruleEvaluator: RuleEvaluator(),
    );
  });

  group('ProcessInvitationUseCase Logic Execution', () {
    const roleVIP = Role(id: 1, name: 'VIP');
    const roleBlocked = Role(id: 2, name: 'Blocked');
    const roleFriend = Role(id: 3, name: 'Friend');

    const mockRequest = RequestInviteEvent(
      id: 'req_1',
      senderId: 'user_1',
      senderName: '<><',
      senderTags: ['language_eng', 'system_trust_veteran'],
      avatarUrl: '',
    );

    test('Should return null immediately if the profile is not active', () {
      const profile = FilterProfile(name: 'Inactive', isActive: false);

      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [],
      );

      expect(result, isNull);
    });

    test('Should return MatchedRuleDecision with ACCEPT when assigned role matches an ACCEPT rule', () {
      final profile = FilterProfile(
        name: 'Safe Profile',
        isActive: true,
        rules: [
          ProfileRule(role: roleVIP, priority: 1, action: RuleAction.accept),
        ],
      );

      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [roleVIP],
      );

      expect(result, isNotNull);
      expect(result, isA<MatchedRuleDecision>());
      final matched = result as MatchedRuleDecision;
      expect(matched.action, RuleAction.accept);
      expect(matched.rule.role, roleVIP);
    });

    test('Should respect rule priority order when multiple rules match', () {
      final profile = FilterProfile(
        name: 'Priority Test',
        isActive: true,
        rules: [
          ProfileRule(role: roleVIP, priority: 1, action: RuleAction.accept),
          ProfileRule(role: roleBlocked, priority: 0, action: RuleAction.reject),
        ],
      );

      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [roleVIP, roleBlocked],
      );

      expect(result, isNotNull);
      expect(result, isA<MatchedRuleDecision>());
      final matched = result as MatchedRuleDecision;
      expect(matched.action, RuleAction.reject);
      expect(matched.rule.role, roleBlocked);
    });

    test('Should match roles case-insensitively', () {
      const roleLower = Role(id: 4, name: 'moderator');
      final profile = FilterProfile(
        name: 'Case Test',
        isActive: true,
        rules: [
          ProfileRule(role: roleLower, priority: 0, action: RuleAction.accept),
        ],
      );

      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [Role(id: 4, name: 'Moderator')],
      );

      expect(result, isNotNull);
      expect(result, isA<MatchedRuleDecision>());
      expect(result!.action, RuleAction.accept);
    });

    test('Should return null (ignore) if no specific rules or fallback tags match', () {
      final profile = FilterProfile(
        name: 'Strict Profile',
        isActive: true,
        rules: [
          ProfileRule(role: roleFriend, priority: 1, action: RuleAction.reject),
          ProfileRule(role: roleVIP, priority: 2, action: RuleAction.accept),
        ],
      );

      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [],
      );

      expect(result, isNull);
    });

    test('Should return MatchedFallbackTagDecision if no rules match but user has matching VrcTag', () {
      final profile = FilterProfile(
        name: 'Tag Profile',
        isActive: true,
        rules: const [],
        fallbackTagsAction: FallbackTagAction.accept,
        fallbackTags: const [
          VrcTag(id: 'system_trust_veteran', name: 'Veteran User', description: '', category: VrcTagCategory.trust),
        ],
      );

      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [],
      );

      expect(result, isNotNull);
      expect(result, isA<MatchedFallbackTagDecision>());
      final matched = result as MatchedFallbackTagDecision;
      expect(matched.action, RuleAction.accept);
      expect(matched.tag.name, 'Veteran User');
    });
  });

  group('RuleSorter Internal Logic', () {
    test('Should sort rules by priority in ascending order', () {
      final sorter = RuleSorter();
      final rule1 = ProfileRule(role: const Role(id: 1, name: 'A'), priority: 10, action: RuleAction.accept);
      final rule2 = ProfileRule(role: const Role(id: 2, name: 'B'), priority: 1, action: RuleAction.accept);
      final rule3 = ProfileRule(role: const Role(id: 3, name: 'C'), priority: 5, action: RuleAction.accept);

      final sortedRules = sorter.sort([rule1, rule2, rule3]);

      expect(sortedRules[0].priority, 1);
      expect(sortedRules[1].priority, 5);
      expect(sortedRules[2].priority, 10);
    });
  });
}