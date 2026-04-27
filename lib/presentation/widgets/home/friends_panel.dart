import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_avatar.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_user_ui_extension.dart';
import 'package:vrcma/presentation/widgets/home/window/user_details_sheet.dart';

class FriendsPanel extends ConsumerWidget {
  const FriendsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structuredFriendsAsync = ref.watch(structuredFriendsListProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, ref),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(favoriteFriendGroupsProvider);
              await ref.read(friendsListProvider.notifier).refresh();
            },
            child: structuredFriendsAsync.when(
              data: (groups) => _buildGroupedList(context, groups),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        )
      ],
    );
  }
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FRIENDS",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: "Search friends...",
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (val) => ref.read(friendsSearchQueryProvider.notifier).updateQuery(val),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGroupedList(BuildContext context, List<FriendGroupCategory> groups) {
    if (groups.isEmpty) {
      return Center(
        child: Text("Certified lonely moment ;w;", style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
      );
    }
    
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final category = groups[index];
        return _CategorySection(category: category);
      },
    );
  }
}

class _CategorySection extends ConsumerWidget {
  final FriendGroupCategory category;
  
  const _CategorySection({required this.category});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(categoryExpandedProvider(category.id));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryHeader(
          category: category,
          isExpanded: isExpanded,
          onToggle: () {
            ref.read(categoryExpandedProvider(category.id).notifier).toggle();
          },
        ),
        if (isExpanded)
          ...category.friends.map((user) => _FriendTitle(user: user)),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final FriendGroupCategory category;
  final bool isExpanded;
  final VoidCallback onToggle;
  
  const _CategoryHeader({required this.category, required this.isExpanded, required this.onToggle});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 16,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Icon(category.icon, size: 14, color: context.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              category.title.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
                color: context.colorScheme.primary,
              ),
            ),
            const Spacer(),
            Text(
              "${category.friends.length}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      )
    );
  }
}

class _FriendTitle extends StatelessWidget {
  final VrcUser user;

  const _FriendTitle({required this.user});

  Color _getStatusColor(BuildContext context) {
    if (user.isTrulyOffline) return context.vrcColors.statusOffline;
    
    switch (user.status.toLowerCase()) {
      case 'active':
        return context.vrcColors.statusOnline;
      case 'join me':
        return context.vrcColors.statusJoinMe;
      case 'ask me':
        return context.vrcColors.statusAskMe;
      case 'busy':
        return context.vrcColors.statusBusy;
      default:
        return context.vrcColors.statusOffline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Stack(
        children: [
          Opacity(
            opacity: user.isTrulyOffline ? 0.5 : 1,
            child: VrcAvatar(
              imageUrl: user.avatarUrl,
              displayName: user.displayName,
              radius: 20,
            ),
          ),

          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.colorScheme.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        user.displayName,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: user.isTrulyOffline ? context.colorScheme.onSurfaceVariant : context.colorScheme.onSurface),
      ),
      subtitle: Text(
        user.formattedLocation,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: context.colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => UserDetailsSheet(user: user),
        );
      },
    );
  }
}
