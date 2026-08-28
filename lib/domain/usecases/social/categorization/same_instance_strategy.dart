import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/usecases/social/categorization/i_friend_categorization_strategy.dart';

class SameInstanceStrategy implements IFriendCategorizationStrategy {
  static const int _minimumUsersToFormGroup = 2;
  @override
  FriendGroupCategory? execute({required List<VrcUser> friends, required Set<String> accountedIds, required Map<String, dynamic> contextData}) {
    final worldNames = contextData["worldNames"] as Map<String, String>;
    
    final groupedUsers = _groupUsersByInstance(friends);
    final subCategories = _createSubcategories(groupedUsers, worldNames, accountedIds);
    
    if (subCategories.isEmpty) return null;
    
    subCategories.sort((a, b) => b.friends.length.compareTo(a.friends.length));
    
    return FriendGroupCategory(
      id: 'instances_parent',
      title: 'Same Instance',
      iconType: CategoryIconType.sameInstance,
      subCategories: subCategories,
    );
  }
  
  Map<String, List<VrcUser>> _groupUsersByInstance(List<VrcUser> friends) {
    final Map<String, List<VrcUser>> grouped = {};
    
    for (final user in friends) {
      if (!_isUserEligible(user)) continue;
      
      final instance = VrcInstance.parse(user.location);
      if (!_isInstanceEligible(instance)) continue;
      
      final instanceKey = "${instance.worldId}:${instance.instanceId}";
      grouped.putIfAbsent(instanceKey, () => []).add(user);
    }
    
    return grouped;
  }
  
  bool _isUserEligible(VrcUser user) {
    return !user.isTrulyOffline && user.location.isNotEmpty;
  }
  
  bool _isInstanceEligible(VrcInstance instance) {
    return !instance.isOffline &&
      !instance.isPrivate &&
      !instance.isTraveling &&
      instance.isResolvableWorld;
  }
  
  List<FriendGroupCategory> _createSubcategories(
      Map<String, List<VrcUser>> groupedUsers,
      Map<String, String> worldNames,
      Set<String> accountedIds,
      ) {
    final List<FriendGroupCategory> categories = [];
    
    for (final entry in groupedUsers.entries) {
      final users = entry.value;
      if (users.length < _minimumUsersToFormGroup) continue;
      
      accountedIds.addAll(users.map((e) => e.id));
      users.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
      
      final instance = VrcInstance.parse(users.first.location);
      final title = _buildInstanceTitle(instance, worldNames);
      
      categories.add(FriendGroupCategory(
        id: 'inst_${entry.key}',
        title: title,
        iconType: CategoryIconType.sameInstance,
        friends: users,
      ));
    }
    
    return categories;
  }
  
  String _buildInstanceTitle(VrcInstance instance, Map<String, String> worldNames) {
    final worldName = worldNames[instance.worldId] ?? "Unknown World";
    final hash = _formatInstanceHash(instance.instanceId);
    return "$worldName $hash ${instance.accessTypeString}".trim();
  }
  
  String _formatInstanceHash(String? instanceId) {
    if (instanceId == null || instanceId.isEmpty) return '';
    final truncated = instanceId.length > 5 ? instanceId.substring(0, 5) : instanceId;
    return '#$truncated';
  }
}