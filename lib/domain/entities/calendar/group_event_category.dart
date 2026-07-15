/// Represents the official categories supported by VRChat group events.
enum GroupEventCategory {
  arts,
  avatars,
  dance,
  education,
  exploration,
  // ignore: constant_identifier_names
  film_media,
  gaming,
  hangout,
  music,
  performance,
  roleplaying,
  wellness,
  other;

  String get apiValue => name;

  static GroupEventCategory fromString(String value) {
    return GroupEventCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => GroupEventCategory.other,
    );
  }
}