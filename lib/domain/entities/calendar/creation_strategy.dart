/// Strategy used to determine how many upcoming occurrences are generated.
enum CreationStrategy {
  lazy,
  batch;

  String get apiValue => name;

  static CreationStrategy fromString(String value) {
    return CreationStrategy.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => CreationStrategy.lazy
    );
  }
}