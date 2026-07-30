import 'package:flutter/cupertino.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:vrcma/domain/entities/calendar/enums/creation_strategy.dart';
import 'package:vrcma/domain/repositories/i_local_calendar_repository.dart';
import 'package:vrcma/domain/repositories/i_remote_calendar_repository.dart';
import 'package:vrcma/domain/services/calendar/event_title_resolver.dart';
import 'package:vrcma/domain/services/calendar/occurrence_calculator.dart';

/// Orchestrates retrieving active rules, resolving future occurrences, and publishing them to VRChat.
class EvaluateAndGenerateEventsUseCase {
  final ILocalCalendarRepository _localRepo;
  final IRemoteCalendarRepository _remoteRepo;
  final OccurrenceCalculator _calculator;
  final EventTitleResolver _resolver;

  EvaluateAndGenerateEventsUseCase({
    required ILocalCalendarRepository localRepo,
    required IRemoteCalendarRepository remoteRepo,
    required OccurrenceCalculator calculator,
    required EventTitleResolver titleResolver,
  }) : _localRepo = localRepo,
       _remoteRepo = remoteRepo,
       _calculator = calculator,
       _resolver = titleResolver;
  
  Future<void> execute({required VrcUser hostUser}) async {
    final activeRules = await _localRepo.getActiveRules();
    if (activeRules.isEmpty) return;

    final hostLanguages = _extractLanguagesFromTags(hostUser.tags);

    for (final rule in activeRules) {
      if (rule.id == null) continue;

      try {
        await _processRule(rule, hostLanguages);
      } catch (e, stackTrace) {
        debugPrint('Error processing rule [${rule.name}]: $e\n$stackTrace');
      }
    }
  }

  Future<void> _processRule(CalendarAutomationRule rule, List<String> hostLanguages) async {
    final pastRuns = await _localRepo.getPastRuns(rule.id!);

    final targetLimit = rule.strategy == CreationStrategy.lazy
      ? 1
      : rule.maxVisibleFutureEvents;
    
    final pendingStartTimes = _calculator.calculatePendingOccurrences(rule, pastRuns, targetLimit);

    if (pendingStartTimes.isEmpty) return;

    var currentRuleState = rule;

    for (final startUtc in pendingStartTimes) {
      final endUtc = startUtc.add(Duration(minutes: rule.schedule.durationMinutes));

      final resolvedTexts = _resolver.resolve(currentRuleState);

      final eventLanguages = rule.languages.isNotEmpty
        ? rule.languages
        : hostLanguages.isNotEmpty
          ? hostLanguages
          : const ['eng'];
      
      final createdEventId = await _remoteRepo.createEvent(
        groupId: rule.groupId,
        title: resolvedTexts.title,
        startUtc: startUtc,
        endUtc: endUtc,
        description: resolvedTexts.description ?? '',
        category: rule.category,
        accessType: rule.accessType,
        platforms: rule.platforms,
        languages: eventLanguages,
        tags: rule.tags,
        sendCreationNotification: rule.sendNotification,
        roleIds: rule.allowedVrcRoleIds,
        hostEarlyJoinMinutes: rule.hostEarlyJoinMinutes,
        guestEarlyJoinMinutes: rule.guestEarlyJoinMinutes,
        closeInstanceAfterEndMinutes: rule.closeInstanceAfterEndMinutes,
        usesInstanceOverflow: rule.usesInstanceOverflow,
      );

      final runRecord = CalendarOccurrenceRun(
        automationId: rule.id,
        calculatedOccurrenceUtc: startUtc,
        createdVrcEventId: createdEventId,
        publishedAt: DateTime.now().toUtc(),
      );

      await _localRepo.saveOccurrenceRun(runRecord);

      if (currentRuleState.incrementalConfig.isEnabled) {
        currentRuleState = currentRuleState.copyWith(
          incrementalConfig: currentRuleState.incrementalConfig.next(),
        );
        await _localRepo.saveRule(currentRuleState);
      }

      await Future.delayed(const Duration(seconds: 3));
    }
  }

  List<String> _extractLanguagesFromTags(List<String> tags) {
    return tags
      .where((tag) => tag.startsWith('language_'))
      .map((tag) => tag.replaceFirst('language_', ''))
      .toList();
  }
}