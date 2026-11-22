import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:vrcma/domain/entities/calendar/enums/creation_strategy.dart';
import 'package:vrcma/domain/entities/calendar/enums/planned_occurrence_status.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/calendar/planned_occurrence.dart';
import 'package:vrcma/domain/entities/calendar/remote_calendar_event.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';
import 'package:vrcma/domain/error/calendar_domain_exception.dart';
import 'package:vrcma/domain/repositories/i_local_calendar_repository.dart';
import 'package:vrcma/domain/repositories/i_remote_calendar_repository.dart';
import 'package:vrcma/domain/services/app_logger.dart';
import 'package:vrcma/domain/services/calendar/event_title_resolver.dart';
import 'package:vrcma/domain/services/calendar/occurrence_calculator.dart';

/// Orchestrates retrieving active rules, reconciling with existing VRChat events,
/// and publishing missing upcoming occurrences without creating duplicates.
class EvaluateAndGenerateEventsUseCase {
  static const int _vrcMaxTitleLength = 64;
  static const int _vrcMaxLanguages = 3;
  static const int _vrcMaxTags = 5;
  static const Duration _publishSpacing = Duration(seconds: 3);

  final ILocalCalendarRepository _localRepo;
  final IRemoteCalendarRepository _remoteRepo;
  final AppLogger _logger;
  final OccurrenceCalculator _calculator;
  final EventTitleResolver _resolver;

  DateTime? _rateLimitUntilUtc;

  EvaluateAndGenerateEventsUseCase({
    required ILocalCalendarRepository localRepo,
    required IRemoteCalendarRepository remoteRepo,
    required AppLogger logger,
    required OccurrenceCalculator calculator,
    required EventTitleResolver titleResolver,
  })  : _localRepo = localRepo,
        _remoteRepo = remoteRepo,
        _logger = logger,
        _calculator = calculator,
        _resolver = titleResolver;

  /// Evaluates all active calendar automation rules for [hostUser].
  Future<void> execute({required VrcUser hostUser}) async {
    if (_isInRateLimitCooldown()) return;

    final activeRules = await _localRepo.getActiveRules();
    if (activeRules.isEmpty) return;

    final hostLanguages = _extractLanguagesFromTags(hostUser.tags);
    final rulesByGroup = groupBy(activeRules, (rule) => rule.groupId);

    for (final entry in rulesByGroup.entries) {
      if (_isInRateLimitCooldown()) break;
      await _processGroupRules(entry.key, entry.value, hostLanguages);
    }
  }

  Future<void> _processGroupRules(
      String groupId,
      List<CalendarAutomationRule> rules,
      List<String> hostLanguages,
      ) async {
    final remoteEvents = await _fetchRemoteEventsSafely(groupId, rules.first);
    if (remoteEvents == null) return;

    for (final rule in rules) {
      if (_isInRateLimitCooldown()) break;
      await _processRuleSafely(rule, remoteEvents, hostLanguages);
    }
  }

  Future<List<RemoteCalendarEvent>?> _fetchRemoteEventsSafely(
      String groupId,
      CalendarAutomationRule sampleRule,
      ) async {
    try {
      return await _remoteRepo.getUpcomingGroupEvents(groupId);
    } on CalendarRateLimitException catch (rateLimitError) {
      _activateCooldown(rateLimitError.retryAfterMinutes);
      await _logWarning(sampleRule, rateLimitError.defaultMessage);
      return null;
    } catch (error, stackTrace) {
      // Abort this group cycle if remote state cannot be verified to avoid duplicates.
      debugPrint('Failed to fetch remote events for [$groupId]: $error\n$stackTrace');
      await _logError(sampleRule, '$error\n$stackTrace');
      return null;
    }
  }

  Future<void> _processRuleSafely(
      CalendarAutomationRule rule,
      List<RemoteCalendarEvent> remoteEvents,
      List<String> hostLanguages,
      ) async {
    if (rule.id == null) return;

    try {
      await _processRule(rule, remoteEvents, hostLanguages);
    } on CalendarRateLimitException catch (rateLimitError) {
      _activateCooldown(rateLimitError.retryAfterMinutes);
      await _logWarning(rule, rateLimitError.defaultMessage);
    } catch (error, stackTrace) {
      debugPrint('Error processing rule [${rule.name}]: $error\n$stackTrace');
      await _logError(rule, '$error\n$stackTrace');
    }
  }

  Future<void> _processRule(
      CalendarAutomationRule rule,
      List<RemoteCalendarEvent> remoteEvents,
      List<String> hostLanguages,
      ) async {
    final pastRuns = await _localRepo.getPastRuns(rule.id!);
    final targetLimit = rule.strategy == CreationStrategy.lazy
        ? 1
        : rule.maxVisibleFutureEvents;

    final plannedSlots = _calculator.planUpcomingOccurrences(
      rule: rule,
      pastRuns: pastRuns,
      visibleSlotLimit: targetLimit,
      remoteEvents: remoteEvents,
    );

    if (plannedSlots.isEmpty) return;

    await _reconcileRemoteRuns(rule.id!, pastRuns, plannedSlots);

    final pendingSlots = plannedSlots
        .where((slot) => slot.status == PlannedOccurrenceStatus.pendingPublish)
        .toList();
    if (pendingSlots.isEmpty) return;

    await _publishPendingSlots(rule, pendingSlots, hostLanguages);
  }

  Future<void> _reconcileRemoteRuns(
      int ruleId,
      List<CalendarOccurrenceRun> pastRuns,
      List<PlannedOccurrence> plannedSlots,
      ) async {
    final recordedEventIds = pastRuns.map((run) => run.createdVrcEventId).toSet();

    for (final slot in plannedSlots) {
      final remoteId = slot.existingRemoteEventId;
      if (slot.status != PlannedOccurrenceStatus.alreadyPublished) continue;
      if (remoteId == null || recordedEventIds.contains(remoteId)) continue;

      await _localRepo.saveOccurrenceRun(
        CalendarOccurrenceRun(
          automationId: ruleId,
          calculatedOccurrenceUtc: slot.startUtc,
          createdVrcEventId: remoteId,
          publishedAt: DateTime.now().toUtc(),
        ),
      );
      recordedEventIds.add(remoteId);
    }
  }

  Future<void> _publishPendingSlots(
      CalendarAutomationRule initialRule,
      List<PlannedOccurrence> pendingSlots,
      List<String> hostLanguages,
      ) async {
    var currentRule = initialRule;

    for (final slot in pendingSlots) {
      currentRule = await _publishSingleSlot(currentRule, slot, hostLanguages);
      await Future.delayed(_publishSpacing);
    }
  }

  Future<CalendarAutomationRule> _publishSingleSlot(
      CalendarAutomationRule rule,
      PlannedOccurrence slot,
      List<String> hostLanguages,
      ) async {
    final resolved = _resolver.resolve(rule, titleOverride: slot.titleOverride);
    final sanitizedTitle = _clampTitle(resolved.title);
    final sanitizedDescription = _ensureDescription(resolved.description, sanitizedTitle);
    final startUtc = slot.startUtc;
    final endUtc = startUtc.add(Duration(minutes: rule.schedule.durationMinutes));

    final createdEventId = await _remoteRepo.createEvent(
      groupId: rule.groupId,
      title: sanitizedTitle,
      startUtc: startUtc,
      endUtc: endUtc,
      description: sanitizedDescription,
      category: rule.category,
      accessType: rule.accessType,
      platforms: rule.platforms,
      languages: _resolveLanguages(rule, hostLanguages),
      tags: rule.tags.take(_vrcMaxTags).toList(),
      sendCreationNotification: rule.sendNotification,
      roleIds: rule.allowedVrcRoleIds,
      hostEarlyJoinMinutes: rule.hostEarlyJoinMinutes,
      guestEarlyJoinMinutes: rule.guestEarlyJoinMinutes,
      closeInstanceAfterEndMinutes: rule.closeInstanceAfterEndMinutes,
      usesInstanceOverflow: rule.usesInstanceOverflow,
    );

    await _localRepo.saveOccurrenceRun(
      CalendarOccurrenceRun(
        automationId: rule.id,
        calculatedOccurrenceUtc: startUtc,
        createdVrcEventId: createdEventId,
        publishedAt: DateTime.now().toUtc(),
      ),
    );

    await _logger.logCalendar(
      ruleId: rule.id,
      ruleName: rule.name,
      eventTitle: sanitizedTitle,
      eventId: createdEventId,
      occurrenceUtc: startUtc,
      groupId: rule.groupId,
      severity: LogSeverity.info,
    );

    return _advanceRuleState(rule);
  }

  Future<CalendarAutomationRule> _advanceRuleState(
      CalendarAutomationRule rule,
      ) async {
    var updated = rule;
    bool requiresSave = false;

    if (rule.incrementalConfig.isEnabled) {
      updated = updated.copyWith(
        incrementalConfig: rule.incrementalConfig.next(),
      );
      requiresSave = true;
    }

    if (rule.recurrence.type == RecurrenceType.once && rule.isActive) {
      updated = updated.copyWith(isActive: false);
      requiresSave = true;
    }

    if (requiresSave) {
      await _localRepo.saveRule(updated);
    }

    return updated;
  }

  String _clampTitle(String rawTitle) {
    final trimmed = rawTitle.trim();
    if (trimmed.isEmpty) return 'Group Event';
    if (trimmed.length <= _vrcMaxTitleLength) return trimmed;
    return '${trimmed.substring(0, _vrcMaxTitleLength - 3)}...';
  }

  String _ensureDescription(String? rawDescription, String fallbackTitle) {
    final trimmed = rawDescription?.trim() ?? '';
    // VRChat rejects calendar event creation if description length < 1.
    return trimmed.isNotEmpty ? trimmed : fallbackTitle;
  }

  List<String> _resolveLanguages(
      CalendarAutomationRule rule,
      List<String> hostLanguages,
      ) {
    final source = rule.languages.isNotEmpty
        ? rule.languages
        : (hostLanguages.isNotEmpty ? hostLanguages : const ['eng']);
    return source.take(_vrcMaxLanguages).toList();
  }

  List<String> _extractLanguagesFromTags(List<String> tags) {
    return tags
        .where((tag) => tag.startsWith('language_'))
        .map((tag) => tag.replaceFirst('language_', ''))
        .toList();
  }

  bool _isInRateLimitCooldown() {
    if (_rateLimitUntilUtc == null) return false;
    return DateTime.now().toUtc().isBefore(_rateLimitUntilUtc!);
  }

  void _activateCooldown(int retryAfterMinutes) {
    _rateLimitUntilUtc =
        DateTime.now().toUtc().add(Duration(minutes: retryAfterMinutes));
  }

  Future<void> _logWarning(CalendarAutomationRule rule, String details) {
    return _logger.logCalendar(
      ruleId: rule.id,
      ruleName: rule.name,
      groupId: rule.groupId,
      severity: LogSeverity.warning,
      details: details,
    );
  }

  Future<void> _logError(CalendarAutomationRule rule, String details) {
    return _logger.logCalendar(
      ruleId: rule.id,
      ruleName: rule.name,
      groupId: rule.groupId,
      severity: LogSeverity.error,
      details: details,
    );
  }
}