import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';

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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.greenAccent;
      case 'join me':
        return Colors.blueAccent;
      case 'ask me':
        return Colors.orangeAccent;
      case 'busy':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[900],
            backgroundImage: NetworkImage(user.avatarUrl),
            child: Text(user.displayName[0]),
          ),
          
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(user.status),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
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
        user.location == 'private'
            ? "Private Instance"
            : (user.location),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
      ),
      onTap: () {
        //? What info show when tap?
      },
    );
  }
}
