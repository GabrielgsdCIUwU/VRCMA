import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';

/// Contract defining persistence operations for calendar automations
abstract class ILocalCalendarRepository {
  /// Loads all rules flagged as active along with exceptions in a single step.
  Future<List<CalendarAutomationRule>> getActiveRules();
  Future<List<CalendarAutomationRule>> getAllRules();
  Future<int> saveRule(CalendarAutomationRule rule);
  Future<void> deleteRule(int id);

  /// Retrieves past published occurence logs for checking runs.
  Future<List<CalendarOccurrenceRun>> getPastRuns(int automationId);
  Future<void> saveOccurrenceRun(CalendarOccurrenceRun run);  
}