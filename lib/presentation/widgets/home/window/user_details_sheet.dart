import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/usecase_provider.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/presentation/extensions/entity_extensions.dart';
import 'package:vrcma/presentation/state/user_details_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_avatar.dart';

class UserDetailsSheet extends ConsumerStatefulWidget {
  final VrcUser user;
  const UserDetailsSheet({super.key, required this.user});
  
  static void show(BuildContext context, VrcUser user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: UserDetailsSheet(user: user),
      ),
    );
  }

  @override
  ConsumerState<UserDetailsSheet> createState() => _UserDetailsSheetState();
}

class _UserDetailsSheetState extends ConsumerState<UserDetailsSheet> {
  @override
  Widget build(BuildContext context) {
    final assignedRolesAsync = ref.watch(userMetadataProvider(widget.user.id));
    final allRolesAsync = ref.watch(allAvailableRolesProvider);
    
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context, assignedRolesAsync, allRolesAsync),
      desktop: _buildDesktopLayout(context, assignedRolesAsync, allRolesAsync),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context,
      AsyncValue<List<Role>> assignedRolesAsync,
      AsyncValue<List<Role>> allRolesAsync,
      ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 750, maxHeight: 500),
      child: Container(
        padding: const EdgeInsets.all(28),
        color: context.colorScheme.surface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, widget.user, avatarRadius: 36),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                      context.l10n.sectionVrcTagsReadOnly.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: context.colorScheme.onSurfaceVariant,
                          letterSpacing: 1.1
                      )
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.user.tags.map((t) =>
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(t, style: const TextStyle(fontSize: 10)),
                          backgroundColor: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          side: BorderSide(color: context.colorScheme.outlineVariant),
                        )
                    ).toList(),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 48, indent: 8, endIndent: 8),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      context.l10n.sectionAppRoles.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: context.colorScheme.primary,
                          letterSpacing: 1.1
                      )
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: context.colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                        color: context.colorScheme.surfaceContainerLow,
                      ),
                      child: allRolesAsync.when(
                        data: (allRoles) => ListView.separated(
                          shrinkWrap: true,
                          itemCount: allRoles.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final role = allRoles[index];
                            final isAssigned = assignedRolesAsync.value?.contains(role) ?? false;

                            return CheckboxListTile(
                              dense: true,
                              title: Text(role.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              value: isAssigned,
                              onChanged: (val) {
                                ref.read(userMetadataProvider(widget.user.id).notifier)
                                    .toggleRole(role, val ?? false);
                              },
                            );
                          },
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(context.l10n.stateError(error.toString())),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      AsyncValue<List<Role>> assignedRolesAsync,
      AsyncValue<List<Role>> allRolesAsync,
      ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, widget.user, avatarRadius: 28),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                  context.l10n.sectionAppRoles.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: context.colorScheme.primary,
                      letterSpacing: 1.1
                  )
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: allRolesAsync.when(
                      data: (allRoles) => ListView.builder(
                        shrinkWrap: true,
                        itemCount: allRoles.length,
                        itemBuilder: (context, index) {
                          final role = allRoles[index];
                          final isAssigned = assignedRolesAsync.value?.contains(role) ?? false;

                          return CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(role.name, style: const TextStyle(fontSize: 14)),
                            value: isAssigned,
                            onChanged: (val) {
                              ref.read(userMetadataProvider(widget.user.id).notifier)
                                  .toggleRole(role, val ?? false);
                            },
                          );
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Text(context.l10n.stateError(error.toString()))
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                  context.l10n.sectionVrcTagsReadOnly.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: context.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.1
                  )
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.user.tags.map((t) =>
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(t, style: const TextStyle(fontSize: 10)),
                      backgroundColor: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      side: BorderSide(color: context.colorScheme.outlineVariant),
                    )
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, VrcUser user, {required double avatarRadius}) {
    final statusColor = user.status.toLowerCase() == 'offline'
        ? context.vrcColors.statusOffline
        : context.getStatusColor(user.status);

    return Row(
      children: [
        Stack(
          children: [
            VrcAvatar(imageUrl: user.avatarUrl, displayName: user.displayName, radius: avatarRadius),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: avatarRadius * 0.45,
                height: avatarRadius * 0.45,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colorScheme.surface, width: 2),
                ),
              ),
            )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                context.getLocalizedStatus(user.status).toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.5
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}