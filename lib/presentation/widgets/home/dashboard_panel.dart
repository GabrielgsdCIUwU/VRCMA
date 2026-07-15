import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/presentation/state/profile_management_provider.dart';
import 'package:vrcma/presentation/state/status_profile_management_provider.dart';
import 'package:vrcma/presentation/widgets/home/settings_panel.dart';
import 'package:vrcma/presentation/widgets/home/window/profile_editor_sheet.dart';
import 'package:vrcma/presentation/widgets/home/window/status_profile_editor_sheet.dart';

enum DashboardContextAction {
  toggle,
  edit,
  delete,
}

class DashboardPanel extends ConsumerWidget {
  const DashboardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profileManagementProviderProvider);
    final statusProfilesAsync = ref.watch(statusProfileManagementProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, context.l10n.sectionProfiles),
            const SizedBox(height: 12),
            profilesAsync.when(
              data: (profiles) => _buildFilterProfileGrid(context, ref, profiles),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text(context.l10n.stateError(err.toString())))
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, context.l10n.sectionStatusAutomation),
            const SizedBox(height: 12),
            statusProfilesAsync.when(
              data: (statusProfiles) => _buildStatusProfileGrid(context, ref, statusProfiles),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text(context.l10n.stateError(err.toString()))),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, context.l10n.dashboardManagementTools),
            const SizedBox(height: 12),
            _buildManagementAssetsGrid(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.dashboardHeader,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.dashboardSubheader,
          style: TextStyle(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: context.colorScheme.primary,
      ),
    );
  }

  Widget _buildFilterProfileGrid(BuildContext context, WidgetRef ref, List<FilterProfile> profiles) {
    if (profiles.isEmpty) {
      return _buildEmptyState(context, context.l10n.noProfilesAdded, () {
        _showAddFilterProfileDialog(context, ref);
      });
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profiles.length + 1,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 140,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, i) {
        if (i == profiles.length) {
          return _buildAddCard(context, () => _showAddFilterProfileDialog(context, ref));
        }
        final profile = profiles[i];
        return AdaptiveContextMenuWrapper<DashboardContextAction>(
          menuItems: [
            PopupMenuItem(
              value: DashboardContextAction.toggle,
              child: Text(profile.isActive ? context.l10n.contextMenuDeactivate : context.l10n.contextMenuActivate),
            ),
            PopupMenuItem(
              value: DashboardContextAction.edit,
              child: Text(context.l10n.contextMenuEdit),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: DashboardContextAction.delete,
              child: Text(context.l10n.contextMenuDelete, style: TextStyle(color: context.colorScheme.error)),
            )
          ],
          onSelected: (action) {
            switch (action) {
              case DashboardContextAction.toggle:
                ref.read(profileManagementProviderProvider.notifier).toggleProfileActive(profile);
              case DashboardContextAction.edit:
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileEditorSheet(profile: profile)));
              case DashboardContextAction.delete:
                _showDeleteFilterProfileConfirmation(context, ref, profile);
            }
          },
          child: _buildProfileCard(
            context,
            title: profile.name,
            subtitle: context.l10n.profileRulesCount(profile.rules.length),
            isActive: profile.isActive,
            onTap: () {
              ref.read(profileManagementProviderProvider.notifier).toggleProfileActive(profile);
            },
            onEdit: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileEditorSheet(profile: profile)));
            }
          ),
        );
      },
    );
  }

  Widget _buildStatusProfileGrid(BuildContext context, WidgetRef ref, List<StatusProfile> profiles) {
    if (profiles.isEmpty) {
      return _buildEmptyState(context, context.l10n.noStatusRulesAdded, () {
        _showAddStatusProfileDialog(context, ref);
      });
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profiles.length + 1,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 140,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, i) {
        if (i == profiles.length) {
          return _buildAddCard(context, () => _showAddStatusProfileDialog(context, ref));
        }
        final profile = profiles[i];
        return AdaptiveContextMenuWrapper<DashboardContextAction>(
          menuItems: [
            PopupMenuItem(
              value: DashboardContextAction.toggle,
              child: Text(profile.isActive ? context.l10n.contextMenuDeactivate : context.l10n.contextMenuActivate),
            ),
            PopupMenuItem(
              value: DashboardContextAction.edit,
              child: Text(context.l10n.contextMenuEdit),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: DashboardContextAction.delete,
              child: Text(context.l10n.contextMenuDelete, style: TextStyle(color: context.colorScheme.error)),
            ),
          ],
          onSelected: (action) {
            switch (action) {
              case DashboardContextAction.toggle:
                ref.read(statusProfileManagementProvider.notifier).toggleProfileActive(profile);
              case DashboardContextAction.edit:
                Navigator.push(context, MaterialPageRoute(builder: (_) => StatusProfileEditorSheet(profile: profile)));
              case DashboardContextAction.delete:
                _showDeleteStatusProfileConfirmation(context, ref, profile);
            }
          },
          child: _buildProfileCard(
            context,
            title: profile.name,
            subtitle: context.l10n.statusProfileSubtitle(profile.rules.length, profile.fallbackStatus.name),
            isActive: profile.isActive,
            onTap: () {
              ref.read(statusProfileManagementProvider.notifier).toggleProfileActive(profile);
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StatusProfileEditorSheet(profile: profile)),
              );
            }
          ),
        );
      },
    );
  }

  Widget _buildManagementAssetsGrid(BuildContext context, WidgetRef ref) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 80,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12
      ),
      children: [
        _buildAssetLinkCard(
          context,
          icon: Icons.supervised_user_circle_outlined,
          title: context.l10n.sectionRoles,
          subtitle: context.l10n.rolesManagementDesc,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const DraggableScrollableSheet(
                initialChildSize: 0.8,
                maxChildSize: 0.95,
                minChildSize: 0.5,
                expand: false,
                builder: _buildRoleSheetScrollBody,
              ),
            );
          }
        ),
        _buildAssetLinkCard(
          context,
          icon: Icons.smart_toy_outlined,
          title: context.l10n.sectionFriendAutomations,
          subtitle: context.l10n.automationManagementDesc,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const DraggableScrollableSheet(
                initialChildSize: 0.8,
                maxChildSize: 0.95,
                minChildSize: 0.5,
                expand: false,
                builder: _buildAutomationSheetScrollBody,
              ),
            );
          },
        ),
      ],
    );
  }

  static Widget _buildRoleSheetScrollBody(BuildContext _, ScrollController _) => const RoleManagerSubsheet();
  static Widget _buildAutomationSheetScrollBody(BuildContext _, ScrollController _) => const AutomationManagerSubsheet();

  Widget _buildAssetLinkCard(
    BuildContext context, {
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }
  ) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: context.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
      required String title,
      required String subtitle,
      required bool isActive,
      required VoidCallback onTap,
      required VoidCallback onEdit,
    }
  ) {
    final activeBg = context.vrcColors.success.withValues(alpha: 0.08);
    final activeBorder = context.vrcColors.success.withValues(alpha: 0.4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? activeBg : context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? activeBorder : context.colorScheme.outlineVariant,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.radio_button_off,
                  color: isActive ? context.vrcColors.success : context.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.tune_outlined, size: 18),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard(BuildContext context, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, color: context.colorScheme.primary, size: 28),
              const SizedBox(height: 4),
              Text(
                context.l10n.btnCreate.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, VoidCallback onCreate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.widgets_outlined, size: 32, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onCreate, child: Text(context.l10n.btnCreate)),
        ],
      ),
    );
  }

  void _showAddFilterProfileDialog(BuildContext context, WidgetRef ref) {
    _showNameDialog(
      context,
      title: context.l10n.dialogNewProfileTitle,
      label: context.l10n.dialogNewProfileLabel,
      onConfirm: (name) {
        ref.read(profileManagementProviderProvider.notifier).addProfile(name);
      }
    );
  }

  void _showAddStatusProfileDialog(BuildContext context, WidgetRef ref) {
    _showNameDialog(
      context,
      title: context.l10n.dialogNewStatusProfileTitle,
      label: context.l10n.dialogNewStatusProfileLabel,
      onConfirm: (name) {
        ref.read(statusProfileManagementProvider.notifier).addProfile(name);
      }
    );
  }

  void _showNameDialog(
    BuildContext context, {
      required String title,
      required String label,
      required Function(String) onConfirm,
    }
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.btnCancel)),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onConfirm(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text(context.l10n.btnCreate),
          ),
        ],
      ),
    );
  }

  void _showDeleteFilterProfileConfirmation(BuildContext context, WidgetRef ref, FilterProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.dialogDeleteProfileTitle),
        content: Text(context.l10n.dialogDeleteProfileContent(profile.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.btnCancel)),
          TextButton(onPressed: () {
            ref.read(profileManagementProviderProvider.notifier).deleteProfile(profile.id!);
            Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            child: Text(context.l10n.btnDelete),
          ),
        ],
      ),
    );
  }

  void _showDeleteStatusProfileConfirmation(BuildContext context, WidgetRef ref, StatusProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.dialogDeleteStatusProfileTitle),
        content: Text(context.l10n.dialogDeleteStatusProfileContent(profile.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.btnCancel)),
          TextButton(onPressed: () {
            ref.read(statusProfileManagementProvider.notifier).deleteProfile(profile.id!);
            Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            child: Text(context.l10n.btnDelete),
          ),
        ],
      ),
    );
  }
}

class AdaptiveContextMenuWrapper<T> extends StatefulWidget {
  final Widget child;
  final List<PopupMenuEntry<T>> menuItems;
  final ValueChanged<T> onSelected;

  const AdaptiveContextMenuWrapper({
    super.key,
    required this.child,
    required this.menuItems,
    required this.onSelected,
  });

  @override
  State<AdaptiveContextMenuWrapper<T>> createState() => _AdaptiveContextMenuWrapperState<T>();
}

class _AdaptiveContextMenuWrapperState<T> extends State<AdaptiveContextMenuWrapper<T>> {

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: widget.menuItems,
    ).then((value) {
      if (value != null && mounted) {
        widget.onSelected(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      child: widget.child,
    );
  }
}