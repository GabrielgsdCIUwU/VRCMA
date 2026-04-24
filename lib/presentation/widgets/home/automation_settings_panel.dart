import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/presentation/state/profile_management_provider.dart';
import 'package:vrcma/presentation/state/role_management_provider.dart';
import 'package:vrcma/presentation/widgets/home/window/profile_editor_sheet.dart';
import 'package:vrcma/presentation/widgets/home/window/role_editor_sheet.dart';

class AutomationSettingsPanel extends ConsumerWidget {
  const AutomationSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   return Column(
     children: [
       Expanded(
         flex: 1,
         child: _ConfigurationSection(
           title: "Profiles",
           onAdd: () => _showCreateProfileDialog(context, ref),
           child: const _ProfileListContent(),
         ),
       ),
       const Divider(height: 1, thickness: 1),
       
       Expanded(
         flex: 1,
         child: _ConfigurationSection(
           title: "Roles",
           onAdd: () => _showCreateRoleDialog(context, ref),
           child: const _RoleListContent(),
         ),
       ),
     ],
   );
  }
  
  
  void _showCreateProfileDialog(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (_) => _GenericAddDialog(
          title: "New Profile",
          label: "Profile name",
          onConfirm: (name) => ref.read(profileManagementProviderProvider.notifier).addProfile(name),
        ),
    );
  }
  
  void _showCreateRoleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _GenericAddDialog(
        title: "New Role",
        label: "Role name",
        onConfirm: (name) => ref.read(roleManagementProvider.notifier).createRole(name),
      )
    );
  }
}



class _ConfigurationSection extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  final Widget child;
  
  const _ConfigurationSection({
    required this.title,
    required this.onAdd,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsGeometry.fromLTRB(16, 12, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.2, color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: onAdd,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        Expanded(child: child)
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: _submit, child: const Text("Create")),
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
      error: (err, _) => Center(child: Text("Error: $err")),
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
        data: (count) => Text("$count members", style: const TextStyle(fontSize: 12)),
        loading: () => const Text("Loading...", style: TextStyle(fontSize: 12)),
        error: (err, _) => Text("Error: $err", style: const TextStyle(fontSize: 12)),
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
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (val) {
              if (val == 'delete') {
                _showDeleteRoleConfirmation(context, ref);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'delete',
                child: Text("Delete Role", style: TextStyle(color: context.colorScheme.error, fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showDeleteRoleConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Role?"),
        content: Text(
          "Are you sure you want to delete '${role.name}'? \n"
          "This will remove this role from all users and profiles.",
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ref.read(roleManagementProvider.notifier).deleteRole(role.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            child: const Text("Delete"),
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
      error: (err, _) => Center(child: Text("Error: $err")),
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
      subtitle: Text("${profile.rules.length} automation rules"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEditor(context),
            tooltip: "Edit rules",
          ),
          _ProfileOptionsMenu(
            onDelete: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      )
    );
  }
  
  void _handleToggle(WidgetRef ref) {
    if (profile.isActive) return;
    
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
        title: const Text("Delete Profile?"),
        content: Text("Are you sure you want to delete '${profile.name}'? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ref.read(profileManagementProviderProvider.notifier).deleteProfile(profile.id!);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            child: const Text("Delete"),
          )
        ],
      )
    );
  }
}

class _ProfileOptionsMenu extends StatelessWidget {
  final VoidCallback onDelete;
  const _ProfileOptionsMenu({required this.onDelete});
  
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: "More options",
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
              Text("Delete", style: TextStyle(color: context.colorScheme.error)),
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
      tooltip: isActive ? "Active" : "Set as active",
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
      title: const Text("New Profile"),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: "Profile name"),
        onSubmitted: (val) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: _submit, child: const Text("Create")),
      ],
    );
  }
  
  void _submit() {
    if (_controller.text.isEmpty) return;
    
    widget.onConfirm(_controller.text);
    Navigator.pop(context);
  }
}