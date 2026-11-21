import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';

/// Service dedicated to resolving template placeholders in calendar event text.
class EventTitleResolver {
  static const String _incrementalPlaceholder = '{{incremental}}';

  /// Resolves title and description templates for [rule], applying [titleOverride] if provided.
  ResolvedEventTexts resolve(
      CalendarAutomationRule rule, {
        String? titleOverride,
      }) {
    final incrementStr = rule.incrementalConfig.currentValue.toString();
    final rawTitle = (titleOverride != null && titleOverride.trim().isNotEmpty)
        ? titleOverride
        : rule.titleTemplate;

    final resolvedTitle = rawTitle.replaceAll(_incrementalPlaceholder, incrementStr);
    final resolvedDescription = rule.descriptionTemplate
        ?.replaceAll(_incrementalPlaceholder, incrementStr);

    return ResolvedEventTexts(
      title: resolvedTitle,
      description: resolvedDescription,
    );
  }
}

/// Immutable container holding resolved event title and optional description.
class ResolvedEventTexts {
  final String title;
  final String? description;

  const ResolvedEventTexts({required this.title, required this.description});
}