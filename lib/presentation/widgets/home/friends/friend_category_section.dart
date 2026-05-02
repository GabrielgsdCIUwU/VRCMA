import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';

class FriendCategoryHeaderTile extends ConsumerWidget {
  final FriendGroupCategory category;
  final int depth;

  const FriendCategoryHeaderTile({super.key, required this.category, this.depth = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsedSet = ref.watch(collapsedCategoriesProvider);
    final isExpanded = !collapsedSet.contains(category.id);

    return InkWell(
      onTap: () {
        ref.read(collapsedCategoriesProvider.notifier).toggle(category.id);
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(16 + (depth * 12), 12, 16, 12),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 18,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Icon(category.icon, size: 16, color: context.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category.title.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: context.colorScheme.primary
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${category.totalFriendsCount}",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}