import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';

abstract class IFriendCategorizationStrategy {
  FriendGroupCategory? execute({
    required List<VrcUser> friends,
    required Set<String> accountedIds,
    required Map<String, dynamic> contextData,
  });
}