import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_ocurrence_run.dart';

/// Contract defining persistence operations for calendar automations
abstract class ILocalCalendarRepository {
  /// Loads all rules flagged as active along with exceptions in a single step.
  Future<List<CalendarAutomationRule>> getActiveRules();
  Future<int> saveRule(CalendarAutomationRule rule);
  Future<void> deleteRule(int id);

  /// Retrieves past published occurence logs for checking runs.
  Future<List<CalendarOcurrenceRun>> getPastRuns(int automationId);
  Future<void> saveOccurrenceRun(CalendarOcurrenceRun run);  
}