import 'package:vrcma/domain/entities/automation/status_context.dart';

class StatusTemplateResolver {
  static const int _vrcMaxStatusLength = 42;

  /// Resolves placeholders in a template string using the provided context.
  String resolve(String template, StatusContext context) {
    if (template.isEmpty) return "";

    final Map<String, String> placeholders = {
      '{{world}}': context.worldName,
      '{{count}}': context.population.toString(),
      '{{battery}}': "${context.batteryLevel}%",
      '{{instance}}': context.instanceType.name,
      '{{time}}': _formatTime(context.timestamp),
    };

    String result = template;
    placeholders.forEach((tag, value) {
      result = result.replaceAll(RegExp(tag, caseSensitive: false), value);
    });

    return _sanitize(result);
  }

  String _sanitize(String input) {
    final trimmed = input.trim();
    return trimmed.length > _vrcMaxStatusLength
      ? "${trimmed.substring(0, _vrcMaxStatusLength - 3)}..."
      : trimmed;
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}";
  }
}