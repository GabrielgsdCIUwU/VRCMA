import 'package:flutter/material.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/favorite_group.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/domain/usecases/social/categorization/i_friend_categorization_strategy.dart';
import 'package:vrcma/presentation/extensions/entity_extensions.dart';

class FavoritesStrategy implements IFriendCategorizationStrategy {
  @override
  FriendGroupCategory? execute({required List<VrcUser> friends, required Set<String> accountedIds, required Map<String, dynamic> contextData}) {
    final favoriteGroups = contextData['favoriteGroups'] as List<FavoriteGroup>;
    final List<FriendGroupCategory> subCategories = [];
    
    for (final group in favoriteGroups) {
      final eligible = friends.where((u) => group.friendIds.contains(u.id) &&
        !u.isTrulyOffline).toList();
      
      if (eligible.isNotEmpty) {
        eligible.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
        
        accountedIds.addAll(eligible.map((e) => e.id));
        
        subCategories.add(FriendGroupCategory(
          id: 'fav_${group.id}',
          title: group.name,
          icon: Icons.star,
          friends: eligible,
        ));
      }
    }
    
    if (subCategories.isEmpty) return null;
    
    return FriendGroupCategory(
      id: 'favorites_parent',
      title: 'Favorites',
      icon: Icons.star,
      subCategories: subCategories
    );
  }
}