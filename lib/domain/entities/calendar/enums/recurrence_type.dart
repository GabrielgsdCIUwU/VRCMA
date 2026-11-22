/// Defines the supported schedule recurrence frequencies.
enum RecurrenceType {
  once,
  daily,
  weekly,
  monthly;

  String get apiValue => name;

  static RecurrenceType fromString(String value) {
    return RecurrenceType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RecurrenceType.once,
    );
  }
}