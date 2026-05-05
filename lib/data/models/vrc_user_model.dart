import 'package:vrcma/data/mappers/vrc_image_mapper.dart';
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
    super.location,
    super.status,
    super.avatarUrl
  });

  /// Factory to map the library's [LimitedUserFriend] to our domain model.
  factory VrcUserModel.fromLibrary(LimitedUserFriend user) {
    return VrcUserModel(
      id: user.id,
      displayName: user.displayName,
      bio: user.bio,
      tags: user.tags,
      location: user.location,
      status: user.status.value,
      avatarUrl: VrcImageMapper.mapAvatarUrl(
        userIcon: user.userIcon,
        profilePic: user.profilePicOverrideThumbnail,
        thumbnail: user.currentAvatarThumbnailImageUrl,
        currentAvatar: user.currentAvatarImageUrl,
        imageUrl: user.imageUrl
      ),
    );
  }
  factory VrcUserModel.fromCurrentUser(CurrentUser user) {
    return VrcUserModel(
      id: user.id,
      displayName: user.displayName,
      bio: user.bio,
      tags: user.tags,
      location: '',
      status: user.status.value,
      avatarUrl: VrcImageMapper.mapAvatarUrl(
          userIcon: user.userIcon,
          profilePic: user.profilePicOverrideThumbnail,
          thumbnail: user.currentAvatarThumbnailImageUrl,
          currentAvatar: user.currentAvatarImageUrl,
      ),
    );
  }
}