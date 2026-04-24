import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_avatar.dart';
import 'package:vrcma/presentation/widgets/home/window/user_details_sheet.dart';

class FriendsPanel extends ConsumerWidget {
  const FriendsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsListProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(friendsListProvider.notifier).refresh(),
      child: friendsAsync.when(
        data: (friends) {
          if (friends.isEmpty) {
            return const Center(child: Text("No online friends"));
          }
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) => _FriendTitle(user: friends[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

class _FriendTitle extends StatelessWidget {
  final VrcUser user;

  const _FriendTitle({required this.user});

  Color _getStatusColor(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
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
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Stack(
        children: [
         VrcAvatar(
           imageUrl: user.avatarUrl,
           displayName: user.displayName,
           radius: 20,
         ),

          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(context, user.status),
                shape: BoxShape.circle,
                border: Border.all(color: context.colorScheme.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        user.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        user.location == 'private' ? "Private Instance" : (user.location),
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
