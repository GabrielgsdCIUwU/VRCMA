import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';

void main() {
  late ProcessInvitationUseCase useCase;
  
  setUp(() {
    useCase = ProcessInvitationUseCase(
      roleExtractor: UserRoleExtractor(),
      ruleSorter: RuleSorter(),
      ruleEvaluator: RuleEvaluator(),
      defaultResolver: DefaultActionResolver(),
    );
  });
  
  group("ProcessInvitationUseCase - Logic Execution", () {
    const roleVIP = Role(id: 1, name: "VIP");
    const roleBlocked = Role(id: 1, name: "Blocked");
    const roleFriend = Role(id: 1, name: "Friend");
    
    final mockRequest = RequestInvite(
      id: "req_1",
      senderId: "user_1",
      senderName: "<><",
      senderTags: const ["language_en", "system_trust_veteran"],
      avatarUrl: ''
    );
    
    test("Should return null immediately if the profile is not active", () {
      final profile = const FilterProfile(name: "Inactive", isActive: false);
      
      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [],
      );
      
      expect(result, isNull);
    });
    
    test("Should return ACCEPT when user has an assigned role that matches an ACCEPT rule", () {
      final profile = FilterProfile(
        name: "Safe Profile",
        isActive: true,
        rules: const [
          ProfileRule(role: roleVIP, priority: 1, action: RuleAction.accept),
        ],
      );
      
      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [roleVIP],
      );
      
      expect(result, RuleAction.accept);
    });
    
    test("Should respect rule priority when multiple rules match", () {
      final profile = FilterProfile(
        name: "Priority Test",
        isActive: true,
        rules: const [
          ProfileRule(role: roleVIP, priority: 1, action: RuleAction.accept),
          ProfileRule(role: roleBlocked, priority: 0, action: RuleAction.reject),
        ]
      );
      
      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [roleVIP, roleBlocked],
      );
      
      expect(result, RuleAction.reject);
    });
    
    test("Should match roles case-insensitively", () {
      final roleLower = const Role(id: 4, name: "moderator");
      final profile = FilterProfile(
        name: "Case Test",
        isActive: true,
        rules: [
          ProfileRule(role: roleLower, priority: 0, action: RuleAction.accept),
        ],
      );
      
      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [Role(id: 4, name: "Moderator")],
      );
      
      expect(result, RuleAction.accept);
    });
    
    test("Should return profile default action if no specific rules match", () {
      final profile = FilterProfile(
        name: "Fallback Profile",
        isActive: true,
        defaultRole: roleFriend,
        rules: const [
          ProfileRule(role: roleFriend, priority: 10, action: RuleAction.reject),
          ProfileRule(role: roleVIP, priority: 1, action: RuleAction.accept),
        ],
      );
      
      final result = useCase.execute(
        request: mockRequest,
        profile: profile,
        userAssignedRoles: const [],
      );
      
      expect(result, RuleAction.reject);
    });
  });
  
  group("RuleSorter - Internal Logic", () {
    test("Should sort rules by priority in ascending order", () {
      final sorter = RuleSorter();
      const rule1 = ProfileRule(
        role: Role(id: 1, name: "A"),
        priority: 10,
        action: RuleAction.accept
      );
      const rule2 = ProfileRule(
        role: Role(id: 2, name: "B"),
        priority: 1,
        action: RuleAction.accept
      );
      const rule3 = ProfileRule(
        role: Role(id: 3, name: "C"),
        priority: 5,
        action: RuleAction.accept
      );
      
      final sortedRules = sorter.sort([rule1, rule2, rule3]);
      
      expect(sortedRules[0].priority, 1);
      expect(sortedRules[1].priority, 5);
      expect(sortedRules[2].priority, 10);
    });
  });
}