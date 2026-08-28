import 'package:vrcma/domain/entities/auth/vrc_user.dart';

enum CategoryIconType {
  favorites,
  sameInstance,
  joinMe,
  online,
  askMe,
  busy,
  activeWeb,
  offline,
  custom,
}

class FriendGroupCategory {
  final String id;
  final String title;
  final CategoryIconType iconType;
  final List<VrcUser> friends;
  final List<FriendGroupCategory> subCategories;
  
  const FriendGroupCategory({
    required this.id,
    required this.title,
    required this.iconType,
    this.friends = const [],
    this.subCategories = const [],
  });
  
  int get totalFriendsCount {
    int count = friends.length;
    for (var subCategory in subCategories) {
      count += subCategory.totalFriendsCount;
    }
    return count;
  }
}