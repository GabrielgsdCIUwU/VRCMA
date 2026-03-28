import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

class ProfileBanner extends ConsumerWidget {
  const ProfileBanner({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    
    return userAsync.when(
      data: (user) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: const Border(bottom: BorderSide(color: Colors.white10))
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(user?.displayName[0] ?? '?'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.displayName ?? 'Guest',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(user?.id ?? '', style: Theme.of(context).textTheme.bodySmall)
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
            )
          ],
        ),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink()
    );
  }
}