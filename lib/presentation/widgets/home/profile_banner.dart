import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

class ProfileBanner extends ConsumerWidget {
  const ProfileBanner({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        final resolvedUrlAsync = ref.watch(vrcResolvedImageProvider(user.avatarUrl));

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: const Border(bottom: BorderSide(color: Colors.white10))),
          child: Row(
            children: [
              resolvedUrlAsync.when(
                data: (finalUrl) => ClipOval(
                  child: Image.network(
                    finalUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, _) => _buildPlaceholder(user.displayName),
                  ),
                ),
                loading: () => const SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, _) => _buildPlaceholder(user.displayName),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(user.id, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => ref.read(authStateProvider.notifier).logout(),
              )
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildPlaceholder(String name) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.deepPurple,
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
    );
  }
}