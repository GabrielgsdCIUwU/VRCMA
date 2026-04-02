import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';
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
         _AvatarWidget(user: user),

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
        user.location == 'private' ? "Private Instance" : (user.location),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
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

class _AvatarWidget extends ConsumerWidget {
  final VrcUser user;

  const _AvatarWidget({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headersAsync = ref.watch(vrcResolvedImageProvider(user.avatarUrl));

    return headersAsync.when(
      data: (finalUrl) {
        if (finalUrl.isEmpty) {
          return _buildErrorIcon(context, "URL EMPTY!");
        }

        return ClipOval(
          child: Image.network(
            finalUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(strokeWidth: 2);
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                "Error loading avatar from: ${user.displayName}: $error",
              );
              debugPrint("URL: ${user.avatarUrl}");
              return _buildErrorIcon(context, error.toString());
            },
          ),
        );
      },
      loading: () => CircularProgressIndicator(strokeWidth: 2),
      error: (e, _) => _buildErrorIcon(context, "AUTH ERROR"),
    );
  }

  Widget _buildErrorIcon(BuildContext context, String error) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error on avatar: ${user.displayName}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("User ID: ${user.id}"),
                const SizedBox(height: 8),
                const Text("URL detected:", style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(user.avatarUrl.isEmpty ? "(Empty)" : user.avatarUrl),
                const SizedBox(height: 8),
                const Text("Technical error:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(error),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        child: const Icon(Icons.broken_image, size: 20, color: Colors.white),
      ),
    );
  }
}
