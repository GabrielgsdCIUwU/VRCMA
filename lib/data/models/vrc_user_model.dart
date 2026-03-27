import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
/// Data model that extends the domain entity to include JSON serialization
/// or mapping from the specific VRChat API library.
class VrcUserModel extends VrcUser {
  const VrcUserModel({
    required super.id,
    required super.displayName,
    super.bio,
    required super.tags,
  });

  /// Factory to map the library's [CurrentUser] to our domain model.
  factory VrcUserModel.fromLibrary(CurrentUser user) {
    return VrcUserModel(
      id: user.id,
      displayName: user.displayName,
      bio: user.bio,
      tags: user.tags
    );
  }
}