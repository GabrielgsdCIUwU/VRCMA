class VrcImageMapper {
  static String mapAvatarUrl({
    String? userIcon, //* <- VRC+ Icon
    String? profilePic,
    String? thumbnail,
    String? currentAvatar,
    String? imageUrl,
  }) {
    final potentialUrls = [
      userIcon,
      profilePic,
      thumbnail,
      currentAvatar,
      imageUrl
    ];
    
    return potentialUrls.firstWhere(
        (url) => url != null && url.isNotEmpty,
      orElse: () => '',
    )!;
  } 
}