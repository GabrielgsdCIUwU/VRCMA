import 'package:equatable/equatable.dart';
/// Represents a VRChat user within our domain logic.
class VrcUser extends Equatable {
  final String id;
  final String displayName;
  final String? bio;
  final List<String> tags;
  final String location; // ID World or offline if not friends
  final String status; // Online, Join me, Ask me, Offline
  final String avatarUrl;

  const VrcUser({
    required this.id,
    required this.displayName,
    this.bio,
    required this.tags,
    this.location = '',
    this.status = '',
    this.avatarUrl = ''
  });

  bool get isTrulyOffline => location == 'offline' || status.toLowerCase() == 'offline';

  @override
  List<Object?> get props => [id, displayName, bio, tags, location, status, avatarUrl];
}

