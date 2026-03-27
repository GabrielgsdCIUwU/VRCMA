import 'package:equatable/equatable.dart';
/// Represents a VRChat user within our domain logic.
class VrcUser extends Equatable {
  final String id;
  final String displayName;
  final String? bio;
  final List<String> tags;

  const VrcUser({
    required this.id,
    required this.displayName,
    this.bio,
    required this.tags,
  });

  @override
  List<Object?> get props => [id, displayName, bio, tags];
}

