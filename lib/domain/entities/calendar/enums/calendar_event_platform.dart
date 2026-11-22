/// Enumerates the supported OS for VRChat events.
enum CalendarEventPlatform {
  standalonewindows,
  android,
  ios;

  String get apiValue => name;

  static CalendarEventPlatform fromString(String value) {
    return CalendarEventPlatform.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => CalendarEventPlatform.standalonewindows,
    );
  }
}