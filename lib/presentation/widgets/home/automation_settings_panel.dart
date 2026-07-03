import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';
import 'package:vrcma/presentation/state/automation_settings_provider.dart';
import 'package:vrcma/presentation/state/background_service_provider.dart';
import 'package:vrcma/presentation/state/profile_management_provider.dart';
import 'package:vrcma/presentation/state/role_automation_provider.dart';
import 'package:vrcma/presentation/state/role_management_provider.dart';
import 'package:vrcma/presentation/widgets/home/window/profile_editor_sheet.dart';
import 'package:vrcma/presentation/widgets/home/window/role_automation_editor_sheet.dart';
import 'package:vrcma/presentation/widgets/home/window/role_editor_sheet.dart';

class AutomationSettingsPanel extends ConsumerWidget {
  const AutomationSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final isMobile = Platform.isAndroid || Platform.isIOS;

  final collapsedSections = ref.watch(automationPanelSectionsProvider);
  bool isExpanded(String id) => !collapsedSections.contains(id);
  
   return Column(
     children: [
       if (isMobile) ...[
         _buildBackgroundToggle(context, ref),
         const Divider(height: 1, thickness: 1),
       ],
       Flexible(
         flex: isExpanded("profiles") ? 1 : 0,
         child: _CollapsibleSection(
           id: "profiles",
           title: context.l10n.sectionProfiles,
           onAdd: () => _showCreateProfileDialog(context, ref),
           child: const _ProfileListContent(),
         ),
       ),
       const Divider(height: 1, thickness: 1),
       
       Flexible(
         flex: isExpanded("roles") ? 1 : 0,
         child: _CollapsibleSection(
           id: "roles",
           title: context.l10n.sectionRoles,
           onAdd: () => _showCreateRoleDialog(context, ref),
           child: const _RoleListContent(),
         ),
       ),
       const Divider(height: 1, thickness: 1),

       Flexible(
         flex: isExpanded("automations") ? 1 : 0,
         child: _CollapsibleSection(
           id: "automations",
           title: context.l10n.sectionFriendAutomations,
           onAdd: () {
             Navigator.push(context, MaterialPageRoute(
               builder: (_) => const RoleAutomationEditorSheet()
             ));
           },
           child: const _RoleAutomationListContent(),
         ),
       ),
     ],
   );
  }
  
  
  void _showCreateProfileDialog(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (_) => _GenericAddDialog(
          title: context.l10n.dialogNewProfileTitle,
          label: context.l10n.dialogNewProfileLabel,
          onConfirm: (name) {
            ref.read(profileManagementProviderProvider.notifier).addProfile(name);
            ref.read(automationPanelSectionsProvider.notifier).expand('profiles');
          },
        ),
    );
  }
  
  void _showCreateRoleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _GenericAddDialog(
        title: context.l10n.dialogNewRoleTitle,
        label: context.l10n.dialogNewRoleLabel,
        onConfirm: (name) {
          ref.read(roleManagementProvider.notifier).createRole(name);
          ref.read(automationPanelSectionsProvider.notifier).expand('roles');
        },
      )
    );
  }
  
  Widget _buildBackgroundToggle(BuildContext context, WidgetRef ref) {
    final bgState = ref.watch(backgroundServiceToggleProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.bgAutomationTitle.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.2, color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold, fontSize: 14,
                  ),
                ),
                Text(
                  context.l10n.bgAutomationDesc,
                  style: TextStyle(fontSize: 12, color: context.colorScheme.onSurfaceVariant),
                )
              ],
            ),
          ),
          bgState.when(
            data: (isEnabled) => Switch(
              value: isEnabled,
              onChanged: (val) {
                ref.read(backgroundServiceToggleProvider.notifier).toggle(val);
              },
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, _) => Icon(Icons.error, color: context.colorScheme.error),
          ),
        ],
      ),
    );
  }
}

class _CollapsibleSection extends ConsumerWidget {
  final String id;
  final String title;
  final VoidCallback onAdd;
  final Widget child;
  
  const _CollapsibleSection({
    required this.id,
    required this.title,
    required this.onAdd,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsedSections = ref.watch(automationPanelSectionsProvider);
    final isExpanded = !collapsedSections.contains(id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            ref.read(automationPanelSectionsProvider.notifier).toggle(id);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  size: 20,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.2,
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: onAdd,
                  visualDensity: VisualDensity.compact,
                  tooltip: context.l10n.btnCreate,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Expanded(child: child),
      ],
    );
  }
}

class _GenericAddDialog extends StatefulWidget {
  final String title;
  final String label;
  final Function(String) onConfirm;
  
  const _GenericAddDialog({required this.title, required this.label, required this.onConfirm});
  
  @override
  State<_GenericAddDialog> createState() => _GenericAddDialogState();
}

class _GenericAddDialogState extends State<_GenericAddDialog> {
  final _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: (val) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.btnCancel)),
        ElevatedButton(onPressed: _submit, child: Text(context.l10n.btnCreate)),
      ],
    );
  }
  void _submit() {
    if (_controller.text.isNotEmpty) {
      widget.onConfirm(_controller.text);
      Navigator.pop(context);
    }
  }
}

class _RoleListContent extends ConsumerWidget {
  const _RoleListContent();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(roleManagementProvider);
    return rolesAsync.when(
      data: (roles) => ListView.builder(
        itemCount: roles.length,
        itemBuilder: (context, i) => _RoleTile(role: roles[i]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(context.l10n.stateError(err.toString()))),
    );
  }
}

class _RoleTile extends ConsumerWidget {
  final Role role;
  const _RoleTile({required this.role});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(roleMemberCountProvider(role.id));
    
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(Icons.label_outline, color: context.colorScheme.primary, size: 22),
      title: Text(
          role.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: countAsync.when(
        data: (count) => Text(context.l10n.roleMembersCount(count), style: const TextStyle(fontSize: 12)),
        loading: () => Text(context.l10n.stateLoading, style: TextStyle(fontSize: 12)),
        error: (err, _) => Text(context.l10n.stateError(err.toString()), style: const TextStyle(fontSize: 12)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RoleEditorSheet(role: role)));
            },
            visualDensity: VisualDensity.compact,
          ),
          _CommonOptionsMenu(
            onDelete: () => _showDeleteRoleConfirmation(context, ref),
          )
        ],
      ),
    );
  }
  
  void _showDeleteRoleConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.dialogDeleteRoleTitle),
        content: Text(
          context.l10n.dialogDeleteRoleContent(role.name),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.btnCancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(roleManagementProvider.notifier).deleteRole(role.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            child: Text(context.l10n.btnDelete),
          )
        ],
      )
    );
  }
}

class _ProfileListContent extends ConsumerWidget {
  const _ProfileListContent();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profileManagementProviderProvider);
    
    return profilesAsync.when(
      data: (profiles) => _ProfileListView(profiles: profiles),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(context.l10n.stateError(err.toString()))),
    );
  }
}

class _ProfileListView extends StatelessWidget {
  final List<FilterProfile> profiles;
  const _ProfileListView({required this.profiles});
  
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: profiles.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 70),
      itemBuilder: (context, index) => _ProfileTile(profile: profiles[index]),
    );
  }
}

class _ProfileTile extends ConsumerWidget {
  final FilterProfile profile;
  const _ProfileTile({required this.profile});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isActive = profile.isActive;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      onTap: () => _handleToggle(ref),
      onLongPress: () => _handleToggle(ref),
      leading: _StatusIcon(
        isActive: isActive,
        onPressed: () => _handleToggle(ref),
      ),
      title: Text(
        profile.name,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? context.vrcColors.success : null,
          fontSize: 14,
        ),
      ),
      subtitle: Text(context.l10n.profileRulesCount(profile.rules.length)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEditor(context),
            visualDensity: VisualDensity.compact,
            tooltip: context.l10n.tooltipEdit,
          ),
          _CommonOptionsMenu(
            onDelete: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      )
    );
  }
  
  void _handleToggle(WidgetRef ref) {
    ref.read(profileManagementProviderProvider.notifier).toggleProfileActive(profile);
  }
  
  void _openEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileEditorSheet(profile: profile)),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.dialogDeleteProfileTitle),
        content: Text(context.l10n.dialogDeleteProfileContent(profile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.btnCancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(profileManagementProviderProvider.notifier).deleteProfile(profile.id!);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            child: Text(context.l10n.btnDelete),
          )
        ],
      )
    );
  }
}

class _CommonOptionsMenu extends StatelessWidget {
  final VoidCallback onDelete;
  const _CommonOptionsMenu({required this.onDelete});
  
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: context.l10n.tooltipMoreOptions,
      onSelected: (value) {
        if (value == 'delete') onDelete();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: context.colorScheme.error, size: 20),
              SizedBox(width: 8),
              Text(context.l10n.btnDelete, style: TextStyle(color: context.colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;
  const _StatusIcon({required this.isActive, required this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isActive ? Icons.check_circle : Icons.circle_outlined,
        color: isActive ? context.vrcColors.success : context.colorScheme.onSurfaceVariant,
      ),
      onPressed: onPressed,
      tooltip: isActive ? context.l10n.tooltipDeactivate : context.l10n.tooltipActivate,
    );
  }
}

class _CreateProfileDialog extends StatefulWidget {
  final Function(String) onConfirm;
  const _CreateProfileDialog({required this.onConfirm});
  
  @override
  State<_CreateProfileDialog> createState() => _CreateProfileDialogState();
}

class _CreateProfileDialogState extends State<_CreateProfileDialog> {
  final _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.dialogNewProfileTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: context.l10n.dialogNewProfileLabel),
        onSubmitted: (val) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.btnCancel)),
        ElevatedButton(onPressed: _submit, child: Text(context.l10n.btnCreate)),
      ],
    );
  }
  
  void _submit() {
    if (_controller.text.isEmpty) return;
    
    widget.onConfirm(_controller.text);
    Navigator.pop(context);
  }
}

class _RoleAutomationListContent extends ConsumerWidget {
  const _RoleAutomationListContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(roleAutomationListProvider);

    return listAsync.when(
      data: (automations) {
        if (automations.isEmpty) {
          return Center(
            child: Text(context.l10n.noAutomationsConfigured, style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
          );
        }
        return ListView.separated(
          itemCount: automations.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 40),
          itemBuilder: (context, i) => _RoleAutomationTile(automation: automations[i]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(context.l10n.stateError(err.toString()))),
    );
  }
}

class _RoleAutomationTile extends ConsumerWidget {
  final RoleAutomation automation;
  const _RoleAutomationTile({required this.automation});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = automation.trigger == AutomationTrigger.newFriend
        ? context.l10n.triggerOnNewFriend
        : context.l10n.triggerHasTag(VrcTag.allTags.firstWhereOrNull((t) => t.id == automation.targetValue)?.name ?? automation.targetValue!);
    
    return ListTile(
      dense: true,
      leading: Icon(
        automation.trigger == AutomationTrigger.newFriend ? Icons.person_add : Icons.tag,
        color: context.colorScheme.primary,
        size: 20,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(
        context.l10n.automationAssigns(automation.roles.map((r) => r.name).join(', ')),
        style: const TextStyle(fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => RoleAutomationEditorSheet(automation: automation)
              ));
            },
          ),
          _CommonOptionsMenu(
            onDelete: () => _showDeleteConfirmation(context, ref),
          )
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.dialogDeleteAutomationTitle),
        content: Text(context.l10n.dialogDeleteAutomationContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.btnCancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(roleAutomationListProvider.notifier).delete(automation.id!);
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