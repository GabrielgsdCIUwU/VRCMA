import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/favorite_group.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/domain/usecases/social/categorization/favorites_strategy.dart';
import 'package:vrcma/domain/usecases/social/categorization/i_friend_categorization_strategy.dart';
import 'package:vrcma/domain/usecases/social/categorization/same_instance_strategy.dart';
import 'package:vrcma/domain/usecases/social/categorization/status_strategy.dart';
import 'package:vrcma/presentation/extensions/entity_extensions.dart';

class CategorizeFriendsUseCase {
  final List<VrcUser> friends;
  final List<FavoriteGroup> favoriteGroups;
  final Map<String, String> worldNames;
  final String searchQuery;
  
  CategorizeFriendsUseCase({
    required this.friends,
    required this.favoriteGroups,
    required this.worldNames,
    this.searchQuery = '',
  });
  
  List<FriendGroupCategory> execute() {
    final filteredFriends = searchQuery.isEmpty
        ? friends
        : friends.where((f) => f.displayName.toLowerCase().contains(searchQuery)).toList();
    
    final Set<String> accountedIds = {};
    final Map<String, dynamic> contextData = {
      'favoriteGroups': favoriteGroups,
      'worldNames': worldNames,
    };
    
    final List<IFriendCategorizationStrategy> strategies = [
      FavoritesStrategy(),
      SameInstanceStrategy(),
      StatusStrategy(id: 'online', title: 'Online', iconType: CategoryIconType.online,
        condition: (u) => !u.isTrulyOffline && u.status.isNotEmpty
      ),
      StatusStrategy(id: 'active', title: 'Active (Website)', iconType: CategoryIconType.activeWeb,
        condition: (u) => !u.isTrulyOffline && u.status.isEmpty
      ),
      StatusStrategy(id: 'offline', title: 'Offline', iconType: CategoryIconType.offline,
        condition: (u) => u.isTrulyOffline
      ),
    ];
    
    final List<FriendGroupCategory> result = [];
    
    for (final strategy in strategies) {
      final category = strategy.execute(
        friends: filteredFriends,
        accountedIds: accountedIds,
        contextData: contextData,
      );
      if (category != null) result.add(category);
    }
    
    return result;
  }
}