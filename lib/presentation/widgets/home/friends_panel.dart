import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';
import 'package:vrcma/presentation/widgets/home/friends/friend_category_section.dart';
import 'package:vrcma/presentation/widgets/home/friends/friend_list_tile.dart';

class FriendsPanel extends ConsumerWidget {
  const FriendsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structuredFriendsAsync = ref.watch(structuredFriendsListProvider);
    final flatList = ref.watch(flatFriendsListProvider);
    
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
              data: (_) {
                if (flatList.isEmpty) {
                  return Center(child: Text(context.l10n.noFriendsFound, style: TextStyle(color: context.colorScheme.onSurfaceVariant)));
                }
                return ListView.builder(
                  itemCount: flatList.length,
                  itemBuilder: (context, index) {
                    final item = flatList[index];
                    
                    if (item is FlatCategoryHeader) {
                      return FriendCategoryHeaderTile(category: item.category, depth: item.depth);
                    } else if (item is FlatFriendTile) {
                      return Padding(
                        padding: EdgeInsets.only(left: (item.depth -1) * 12.0),
                        child: FriendListTile(user: item.user),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text(context.l10n.stateError(err.toString()))),
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
            context.l10n.friendsHeader.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: context.colorScheme.primary,
            tooltip: context.l10n.tooltipRefreshFriends,
            onPressed: () async {
              ref.invalidate(favoriteFriendGroupsProvider);
              await ref.read(friendsListProvider.notifier).refresh();
            },
          ),
          const SizedBox(height: 4),
          TextField(
            decoration: InputDecoration(
              hintText: context.l10n.searchFriendsHint,
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
}
