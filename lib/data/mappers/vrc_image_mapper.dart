class VrcImageMapper {
  static String mapAvatarUrl({
    String? profilePic,
    String? thumbnail,
    String? currentAvatar,
    String? imageUrl,
  }) {
    final potentialUrls = [
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