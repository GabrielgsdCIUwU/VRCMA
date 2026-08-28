import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/domain/usecases/social/categorization/i_friend_categorization_strategy.dart';

class StatusStrategy implements IFriendCategorizationStrategy {
  final String id;
  final String title;
  final CategoryIconType iconType;
  final bool Function(VrcUser) condition;
  
  StatusStrategy({
    required this.id,
    required this.title,
    required this.iconType,
    required this.condition,
  });
  
  @override
  FriendGroupCategory? execute({required List<VrcUser> friends, required Set<String> accountedIds, required Map<String, dynamic> contextData}) {
    final matched = friends.where((f) => !accountedIds.contains(f.id) && condition(f)).toList();
    
    if (matched.isEmpty) return null;
    
    accountedIds.addAll(matched.map((u) => u.id));
    matched.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    
    return FriendGroupCategory(
      id: id,
      title: title,
      iconType: iconType,
      friends: matched
    );
  }
}