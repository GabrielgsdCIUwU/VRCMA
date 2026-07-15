import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/presentation/state/app_settings_provider.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_avatar.dart';

class ProfileBanner extends ConsumerWidget {
  const ProfileBanner({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        return ResponsiveLayout(
          mobile: _buildBannerContent(context, ref, user, isDesktop: false),
          desktop: _buildBannerContent(context, ref, user, isDesktop: true),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildBannerContent(
    BuildContext context,
    WidgetRef ref,
    VrcUser user, {
      required bool isDesktop,
    }
  ) {
    final collapsed = ref.watch(friendsPanelCollapsedProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border(bottom: BorderSide(color: context.colorScheme.outlineVariant))),
      child: Row(
        children: [
          VrcAvatar(
            imageUrl: user.avatarUrl,
            displayName: user.displayName,
            radius: 22,
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: context.getStatusColor(user.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.getLocalizedStatus(user.status),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            IconButton(
              icon: Icon(collapsed ? Icons.people_outline : Icons.people),
              tooltip: context.l10n.navFriends,
              onPressed: () {
                ref.read(friendsPanelCollapsedProvider.notifier).toggle();
              },
            ),
            const SizedBox(width: 16),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}