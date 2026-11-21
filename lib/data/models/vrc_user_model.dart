import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/data/mappers/vrc_image_mapper.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';

/// Data model adapting VRChat SDK user DTOs into the domain [VrcUser] entity.
class VrcUserModel extends VrcUser {
  const VrcUserModel({
    required super.id,
    required super.displayName,
    super.bio,
    required super.tags,
    super.location,
    super.status,
    super.avatarUrl,
  });

  static final Map<String, VrcTag> _tagsLookupMap = {
    for (final tag in VrcTag.allTags) tag.id: tag,
  };

  /// Maps a friend item returned by `/auth/user/friends`.
  factory VrcUserModel.fromLibrary(LimitedUserFriend user) {
    return VrcUserModel(
      id: user.id,
      displayName: user.displayName,
      tags: _internTags(user.tags),
      location: user.location,
      status: user.status.value,
      avatarUrl: VrcImageMapper.mapAvatarUrl(
        userIcon: user.iconUrl,
        currentAvatar: user.currentAvatarImageUrl,
      ),
    );
  }

  /// Maps a full [CurrentUser] model into [VrcUserModel].
  factory VrcUserModel.fromCurrentUser(CurrentUser user) {
    return VrcUserModel(
      id: user.id,
      displayName: user.displayName,
      tags: _internTags(user.tags),
      location: user.location ?? '',
      status: user.status.value,
      avatarUrl: VrcImageMapper.mapAvatarUrl(
        userIcon: user.iconUrl,
        thumbnail: user.currentAvatarThumbnailImageUrl,
        currentAvatar: user.currentAvatarImageUrl,
      ),
    );
  }

  /// Maps the login response returned by `getCurrentUser()` in `vrchat_dart` 5.x.
  factory VrcUserModel.fromCurrentUserLoginResponse(
      CurrentUserLoginResponse user,
      ) {
    return VrcUserModel(
      id: user.id ?? '',
      displayName: user.displayName ?? '',
      tags: _internTags(user.tags ?? const []),
      location: user.location ?? '',
      status: user.status?.value ?? '',
      avatarUrl: VrcImageMapper.mapAvatarUrl(
        userIcon: user.iconUrl,
        thumbnail: user.currentAvatarThumbnailImageUrl,
        currentAvatar: user.currentAvatarImageUrl,
      ),
    );
  }

  static List<String> _internTags(List<String> rawTags) {
    return rawTags.map((rawTag) {
      final knownTag = _tagsLookupMap[rawTag];
      return knownTag != null ? knownTag.id : rawTag;
    }).toList();
  }
}