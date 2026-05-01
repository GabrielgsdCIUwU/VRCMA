import 'package:flutter/material.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/usecases/social/categorization/i_friend_categorization_strategy.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_user_ui_extension.dart';

class SameInstanceStrategy implements IFriendCategorizationStrategy {
  @override
  FriendGroupCategory? execute({required List<VrcUser> friends, required Set<String> accountedIds, required Map<String, dynamic> contextData}) {
    final worldNames = contextData['worldNames'] as Map<String, String>;
    final Map<String, List<VrcUser>> groupedByLocation = {};
    
    for (final user in friends) {
      if (user.isTrulyOffline || user.status.toLowerCase() == 'active') continue;
      
      final instance = VrcInstance.parse(user.location);
      if (instance.isOffline || instance.isPrivate || instance.isTraveling) continue;
      
      groupedByLocation.putIfAbsent(user.location, () => []).add(user);
    }
    
    final List<FriendGroupCategory> instanceSubCategories = [];
    
    groupedByLocation.forEach((locationId, usersInInstance) {
      if (usersInInstance.length >= 2) {
        accountedIds.addAll(usersInInstance.map((e) => e.id));
        usersInInstance.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

        final instance = VrcInstance.parse(locationId);
        final worldName = worldNames[instance.worldId] ?? "Unknown World";
        final hash = instance.instanceId != null
            ? '#${instance.instanceId!.length > 5 ? instance.instanceId!.substring(0, 5) : instance.instanceId!}'
            : '';

        instanceSubCategories.add(FriendGroupCategory(
          id: 'inst_$locationId',
          title: "$worldName $hash ${instance.accessTypeString}".trim(),
          icon: Icons.map_outlined,
          friends: usersInInstance,
        ));
      }
    });
    
    if (instanceSubCategories.isEmpty) return null;
    
    instanceSubCategories.sort((a, b) => b.friends.length.compareTo(a.friends.length));
    
    return FriendGroupCategory(
      id: 'instances_parent',
      title: 'In Same Instance',
      icon: Icons.public,
      subCategories: instanceSubCategories,
    );
  }
}