import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';

/// service dedicated to template placeholder resolution.
class EventTitleResolver {
  static const String _incrementalPlaceholder = '{{incremental}}';

  ResolvedEventTexts resolve(CalendarAutomationRule rule) {
    final int value = rule.incrementalConfig.currentValue;

    final String resolvedTitle = rule.titleTemplate.replaceAll(
      _incrementalPlaceholder,
      value.toString(),
    );

    String? resolvedDescription;
    if (rule.descriptionTemplate != null) {
      resolvedDescription = rule.descriptionTemplate!.replaceAll(
        _incrementalPlaceholder,
        value.toString(),
      );
    }

    return ResolvedEventTexts(title: resolvedTitle, description: resolvedDescription);
  }
}

/// Helper container representing pure resolved text entities.
class ResolvedEventTexts {
  final String title;
  final String? description;

  const ResolvedEventTexts({required this.title, required this.description});
}