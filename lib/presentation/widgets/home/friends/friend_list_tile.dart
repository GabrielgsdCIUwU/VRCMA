import 'package:flutter/material.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_avatar.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_user_ui_extension.dart';
import 'package:vrcma/presentation/widgets/home/window/user_details_sheet.dart';

class FriendListTile extends StatelessWidget {
  final VrcUser user;

  const FriendListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final statusColor = user.isTrulyOffline
      ? context.vrcColors.statusOffline
      : context.getStatusColor(user.status);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => UserDetailsSheet(user: user),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Stack(
              children: [
                Opacity(
                  opacity: user.isTrulyOffline ? 0.5 : 1,
                  child: VrcAvatar(imageUrl: user.avatarUrl, displayName: user.displayName, radius: 20),
                ),
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: statusColor, shape: BoxShape.circle,
                      border: Border.all(color: context.colorScheme.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: user.isTrulyOffline ? context.colorScheme.onSurfaceVariant : context.colorScheme.onSurface
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user.getLocalizedFormattedLocation(context),
                    style: TextStyle(color: context.colorScheme.onSurfaceVariant, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}