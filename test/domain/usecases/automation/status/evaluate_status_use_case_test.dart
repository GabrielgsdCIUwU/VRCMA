import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/usecases/automation/status/evaluate_status_use_case.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_condition_matcher.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_template_resolver.dart';


void main() {
  group('EvaluateStatusUseCase Tests', () {
    late EvaluateStatusUseCase useCase;

    setUp(() {
      useCase = EvaluateStatusUseCase(
        matchers: [
          NumericConditionMatcher(),
          InstanceTypeMatcher(),
        ],
        resolver: StatusTemplateResolver(),
      );
    });

    test('should select the highest priority rule (lowest priority number) that evaluates to true', () async {
      const ruleLowPriority = StatusRule(
        priority: 0,
        targetStatus: StatusType.busy,
        conditionType: ConditionType.population,
        operator: RuleOperator.greaterThan,
        conditionValue: '50',
        messageTemplate: 'Busy in a crowded room',
      );

      const ruleHighPriority = StatusRule(
        priority: 1,
        targetStatus: StatusType.joinMe,
        conditionType: ConditionType.population,
        operator: RuleOperator.greaterThan,
        conditionValue: '10',
        messageTemplate: 'Come join me!',
      );

      final profile = StatusProfile(
        name: 'Streamer Mode',
        fallbackStatus: StatusType.active,
        fallbackTemplate: 'VRChatting',
        rules: [ruleLowPriority, ruleHighPriority],
      );

      final context = StatusContext(
        worldName: 'VRChat Home',
        worldId: 'wrld_default',
        population: 15,
        instanceType: InstanceAccessType.public,
        batteryLevel: 100,
        isCharging: true,
        timestamp: DateTime.now(),
      );

      final result = await useCase.execute(profile: profile, context: context);

      expect(result.status, equals(StatusType.joinMe));
      expect(result.message, equals('Come join me!'));
      expect(result.matchedRule, equals(ruleHighPriority));
    });

    test('should fallback to profile base configurations if no conditional rules match', () async {
      const ruleNoMatch = StatusRule(
        priority: 0,
        targetStatus: StatusType.busy,
        conditionType: ConditionType.population,
        operator: RuleOperator.greaterThan,
        conditionValue: '100',
        messageTemplate: 'Super busy',
      );

      final profile = StatusProfile(
        name: 'Casual Mode',
        fallbackStatus: StatusType.askMe,
        fallbackTemplate: 'Relaxing in {{world}}',
        rules: [ruleNoMatch],
      );

      final context = StatusContext(
        worldName: 'Space',
        worldId: 'wrld_space',
        population: 1,
        instanceType: InstanceAccessType.inviteOnly,
        batteryLevel: 95,
        isCharging: false,
        timestamp: DateTime.now(),
      );

      final result = await useCase.execute(profile: profile, context: context);

      expect(result.status, equals(StatusType.askMe));
      expect(result.message, equals('Relaxing in Space'));
      expect(result.matchedRule, isNull);
    });
  });
}