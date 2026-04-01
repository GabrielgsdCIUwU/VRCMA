import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/presentation/state/profile_management_provider.dart';
import 'package:vrcma/presentation/widgets/home/window/profile_editor_sheet.dart';

class AutomationSettingsPanel extends ConsumerWidget {
  const AutomationSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   return Column(
     children: [
       _PanelHeader(
         onAddRequested: () => _showCreateProfileDialog(context, ref),
       ),
       const Divider(height: 1),
       const Expanded(child: _ProfileListContent())
     ],
   );
  }
  
  void _showCreateProfileDialog(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (context) => _CreateProfileDialog(
          onConfirm: (name) => ref.read(profileManagementProviderProvider.notifier).addProfile(name),
        ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final VoidCallback onAddRequested;
  const _PanelHeader({required this.onAddRequested});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Profiles", style: Theme.of(context).textTheme.titleLarge),
          Tooltip(
            message: "Create new profile",
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAddRequested,
            ),
          )
        ],
      ),
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
          color: isActive ? Colors.green.shade200 : null,
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text("Delete", style: TextStyle(color: Colors.red)),
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
        color: isActive ? Colors.green : Colors.grey,
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