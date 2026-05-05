import 'package:collection/collection.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';


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

  ProcessInvitationUseCase({
    required this.roleExtractor,
    required this.ruleSorter,
    required this.ruleEvaluator,
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
      final matchedTag = profile.fallbackTags.firstWhereOrNull(
              (tag) => userRoles.contains(tag.id.toLowerCase())
                  || userRoles.contains(tag.name.toLowerCase())
      );
      
      if (matchedTag != null) {
        final action = profile.fallbackTagsAction == FallbackTagAction.accept
            ? RuleAction.accept
            : RuleAction.reject;
        
        return ProcessInvitationResult(
          action: action,
          rule: ProfileRule(
            role: Role(id: -1, name: "Tag ${matchedTag.name}"),
            priority: 999,
            action: action
          )
        );
      }
    }
    return null;
  }
}

class UserRoleExtractor {
  Set<String> extract(
      InvitationType request,
      List<Role> userAssignedRoles,
      ) {
    final rawTags = request.senderTags.map((t) => t.toLowerCase()).toSet();
    
    final humanReadableTags = rawTags.map((tagId) {
      final knownTag = VrcTag.allTags.firstWhereOrNull((t) => t.id.toLowerCase() == tagId);
      return knownTag?.name.toLowerCase();
    }).nonNulls;
    return {
      ...rawTags,
      ...humanReadableTags,
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
