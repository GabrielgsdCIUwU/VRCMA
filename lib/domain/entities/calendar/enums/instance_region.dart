/// Supported regional servers for hosting VRChat instances.
enum InstanceRegion {
  us,
  eu,
  jp,
  as;

  String get apiValue => name.toUpperCase();

  static InstanceRegion fromString(String value) {
    return InstanceRegion.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => InstanceRegion.eu,
    );
  }
}