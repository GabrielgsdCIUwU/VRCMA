import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';


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

  RuleAction? execute({
    required InvitationType request,
    required FilterProfile profile,
    required List<Role> userAssignedRoles,
  }) {
    if (!profile.isActive) return null;

    final userRoles = roleExtractor.extract(request, userAssignedRoles);
    final sortedRules = ruleSorter.sort(profile.rules);

    final result = ruleEvaluator.evaluate(sortedRules, userRoles);

    if (result != null) return result;

    return defaultResolver.resolve(profile);
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
  RuleAction? evaluate(
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

  RuleAction? _evaluateSegment(
      List<ProfileRule> segment,
      Set<String> userRoles,
      ) {
    if (segment.length == 1 && segment.first.fallbackGroup == null) {
      final rule = segment.first;
      if (_matches(rule, userRoles)) {
        return rule.action;
      }
      return null;
    }

    for (final rule in segment) {
      if (_matches(rule, userRoles)) {
        return rule.action;
      }
    }

    return null;
  }

  bool _matches(ProfileRule rule, Set<String> userRoles) {
    return userRoles.contains(rule.role.name.toLowerCase());
  }
}

class DefaultActionResolver {
  RuleAction? resolve(FilterProfile profile) {
    if (profile.defaultRole == null) return null;

    final defaultRule = profile.rules
        .where((r) => r.role.id == profile.defaultRole!.id)
        .firstOrNull;

    return defaultRule?.action;
  }
}