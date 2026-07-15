/// Defines the visibility level of a VRChat group event.
enum GroupEventAccessType {
  public,
  group;

  String get apiValue => name;

  static GroupEventAccessType fromString(String value) {
    return GroupEventAccessType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => GroupEventAccessType.group
    );
  }
}