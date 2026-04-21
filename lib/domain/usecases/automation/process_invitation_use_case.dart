import 'package:collection/collection.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';


class ProcessInvitationResult {
  final RuleAction action;
  final ProfileRule rule;
  ProcessInvitationResult({
    required this.action,
    required this.rule,
  });
}

class ProcessInvitationUseCase {
  final UserRoleExtractor roleExtractor;
  final RuleSorter ruleSorter;
  final RuleEvaluator ruleEvaluator;
  final DefaultActionResolver defaultResolver;

  ProcessInvitationUseCase({
    required this.roleExtractor,
    required this.ruleSorter,
    required this.ruleEvaluator,
    required this.defaultResolver,
  });

  ProcessInvitationResult? execute({
    required InvitationType request,
    required FilterProfile profile,
    required List<Role> userAssignedRoles,
  }) {
    if (!profile.isActive) return null;

    final userRoles = roleExtractor.extract(request, userAssignedRoles);
    final sortedRules = ruleSorter.sort(profile.rules);

    final matchedRule = ruleEvaluator.evaluate(sortedRules, userRoles);

    if (matchedRule != null) {
      return ProcessInvitationResult(
        action: matchedRule.action,
        rule: matchedRule
      );
    }
    
    if (profile.fallbackTagsAction != FallbackTagAction.disabled && profile.fallbackTags.isNotEmpty) {
      final matchedTag = profile.fallbackTags.firstWhereOrNull((tag) => userRoles.contains(tag.toLowerCase()));
      
      if (matchedTag != null) {
        final action = profile.fallbackTagsAction == FallbackTagAction.accept
            ? RuleAction.accept
            : RuleAction.reject;
        
        return ProcessInvitationResult(
          action: action,
          rule: ProfileRule(
            role: Role(id: -1, name: "Tag Match: $matchedTag"),
            priority: 999,
            action: action
          )
        );
      }
    }

    final defaultRule = defaultResolver.resolve(profile);
    if (defaultRule != null) {
      return ProcessInvitationResult(
          action: defaultRule.action,
          rule: defaultRule,
      );
    }
    return null;
  }
}

class UserRoleExtractor {
  Set<String> extract(
      InvitationType request,
      List<Role> userAssignedRoles,
      ) {
    return {
      ...request.senderTags.map((t) => t.toLowerCase()),
      ...userAssignedRoles.map((r) => r.name.toLowerCase()),
    };
  }
}

class RuleSorter {
  List<ProfileRule> sort(List<ProfileRule> rules) {
    final sorted = List<ProfileRule>.from(rules);
    sorted.sort((a, b) => a.priority.compareTo(b.priority));
    return sorted;
  }
}

class RuleEvaluator {
  ProfileRule? evaluate(
      List<ProfileRule> rules,
      Set<String> userRoles,
      ) {
    final segments = _groupRules(rules);

    for (final segment in segments) {
      final result = _evaluateSegment(segment, userRoles);
      if (result != null) return result;
    }

    return null;
  }

  List<List<ProfileRule>> _groupRules(List<ProfileRule> rules) {
    final result = <List<ProfileRule>>[];
    List<ProfileRule> current = [];

    for (final rule in rules) {
      if (rule.fallbackGroup == null) {
        if (current.isNotEmpty) {
          result.add(current);
          current = [];
        }
        result.add([rule]);
        continue;
      }

      if (current.isEmpty || current.first.fallbackGroup == rule.fallbackGroup) {
        current.add(rule);
      } else {
        result.add(current);
        current = [rule];
      }
    }

    if (current.isNotEmpty) {
      result.add(current);
    }

    return result;
  }

  ProfileRule? _evaluateSegment(
      List<ProfileRule> segment,
      Set<String> userRoles,
      ) {
    if (segment.length == 1 && segment.first.fallbackGroup == null) {
      final rule = segment.first;
      if (_matches(rule, userRoles)) {
        return rule;
      }
      return null;
    }

    for (final rule in segment) {
      if (_matches(rule, userRoles)) {
        return rule;
      }
    }

    return null;
  }

  bool _matches(ProfileRule rule, Set<String> userRoles) {
    return userRoles.contains(rule.role.name.toLowerCase());
  }
}

class DefaultActionResolver {
  ProfileRule? resolve(FilterProfile profile) {
    if (profile.defaultRole == null) return null;

    return profile.rules.firstWhereOrNull(
      (rule) => rule.role.id == profile.defaultRole!.id,
    );
  }
}