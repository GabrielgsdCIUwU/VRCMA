import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_condition_matcher.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_template_resolver.dart';

class EvaluateStatusResult {
  final StatusType status;
  final String message;
  final StatusRule? matchedRule;

  EvaluateStatusResult({required this.status, required this.message, this.matchedRule});
}

class EvaluateStatusUseCase {
  final List<IStatusConditionMatcher> _matchers;
  final StatusTemplateResolver _resolver;

  EvaluateStatusUseCase({
    required List<IStatusConditionMatcher> matchers,
    required StatusTemplateResolver resolver,
  }) : _matchers = matchers, _resolver = resolver;

  /// Evaluates the profile rules against the current context to determine 
  /// the optimal VRChat status and message.
  Future<EvaluateStatusResult> execute({
    required StatusProfile profile,
    required StatusContext context
  }) async {
    final winningRule = await _findWinningRule(profile.rules, context);

    final template = winningRule?.messageTemplate ?? profile.fallbackTemplate ?? "";
    final resolvedMessage = _resolver.resolve(template, context);

    final targetStatus = winningRule?.targetStatus ?? profile.fallbackStatus;
    return EvaluateStatusResult(
      status: targetStatus,
      message: resolvedMessage,
      matchedRule: winningRule,
    );

  }

  Future<StatusRule?> _findWinningRule(List<StatusRule> rules, StatusContext context) async {
    for (final rule in rules) {
      try {
        final matcher = _matchers.firstWhere((m) => m.canHandle(rule.conditionType));
        if (await matcher.matches(rule, context)) {
          return rule;
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }
}