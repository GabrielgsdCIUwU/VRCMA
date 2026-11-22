import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';

sealed class ProcessInvitationDecision extends Equatable {
  final RuleAction action;
  const ProcessInvitationDecision(this.action);
}

class MatchedRuleDecision extends ProcessInvitationDecision {
  final ProfileRule rule;

  const MatchedRuleDecision({
    required RuleAction action,
    required this.rule,
  }) : super(action);

  CustomMessage? getResponseMessage({required bool isInvite}) {
    return isInvite ? rule.inviteResponseMessage : rule.requestResponseMessage;
  }

  @override
  List<Object?> get props => [action, rule];
}

class MatchedFallbackTagDecision extends ProcessInvitationDecision {
  final VrcTag tag;

  const MatchedFallbackTagDecision({
    required RuleAction action,
    required this.tag,
  }) : super(action);

  @override
  List<Object?> get props => [action, tag];
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

  ProcessInvitationDecision? execute({
    required IncomingUserEvent request,
    required FilterProfile profile,
    required List<Role> userAssignedRoles,
  }) {
    if (!profile.isActive) return null;

    final userRoles = roleExtractor.extract(request, userAssignedRoles);
    final sortedRules = ruleSorter.sort(profile.rules);

    final matchedRule = ruleEvaluator.evaluate(sortedRules, userRoles);

    if (matchedRule != null) {
      return MatchedRuleDecision(
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
        
        return MatchedFallbackTagDecision(
          action: action,
          tag: matchedTag
        );
      }
    }
    return null;
  }
}

class UserRoleExtractor {
  Set<String> extract(
      IncomingUserEvent request,
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
