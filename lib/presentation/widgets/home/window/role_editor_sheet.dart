import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:collection/collection.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';
import 'package:vrcma/presentation/state/role_management_provider.dart';

class RoleEditorSheet extends ConsumerStatefulWidget {
  final Role role;
  const RoleEditorSheet({super.key, required this.role});
  
  @override
  ConsumerState<RoleEditorSheet> createState() => _RoleEditorSheetState();
}

class _RoleEditorSheetState extends ConsumerState<RoleEditorSheet> {
  late Set<String> _tempUserIds = {};
  late Set<String> _initialUserIds = {};
  late TextEditingController _nameController;
  late String _initialName;
  String _searchQuery = "";
  bool _isLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _initialName = widget.role.name;
    _nameController = TextEditingController(text: widget.role.name);
    
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    final repo = await ref.read(localSocialRepositoryProvider.future);
    final ids = await repo.getUserIdsByRole(widget.role.id);
    setState(() {
      _initialUserIds = Set.from(ids);
      _tempUserIds = Set.from(ids);
      _isLoaded = true;
    });
  }
  
  bool get _hasChanges {
    final nameChanged = _nameController.text != _initialName;
    final usersChanged = !const SetEquality().equals(_tempUserIds, _initialUserIds);
    return nameChanged || usersChanged;
  }
  
  Future<void> _saveAndExit() async {
    try {
      await ref.read(roleManagementProvider.notifier).saveRoleChanges(
          roleId: widget.role.id,
          newName: _nameController.text,
          newUserIds: _tempUserIds
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showErrorDialog(e.toString());
    }
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Name already in use"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ok"),
          )
        ],
      )
    );
  }
  
  Future<bool> _showExitConfirmation() async {
    if (!_hasChanges) return true;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unsaved Changes"),
        content: const Text("You have made changes to this role. Do you want to save them before leaving?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text("Discard", style: TextStyle(color: context.colorScheme.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text("Save Changes"),
          )
        ],
      ),
    );
    
    if (result == 'discard') return true;
    _saveAndExit();
    return false;
  }
  
  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsListProvider);
    
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Role"),
          actions: [
            IconButton(
              icon: Icon(Icons.save, color: _hasChanges ? context.vrcColors.success : null),
              onPressed: _hasChanges ? _saveAndExit : null,
            ),
          ],
        ),
        body: !_isLoaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
            children: [
              _buildHeaderField(),
              const Divider(),
              _buildSearchField(),
              Expanded(child: _buildFriendsList(friendsAsync)),
            ],
          ),
      ),
    );
  }
  
  Widget _buildHeaderField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _nameController,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          labelText: "Role Name",
          prefixIcon: Icon(Icons.label_important_outline),
        ),
      ),
    );
  }
  
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: const InputDecoration(
          hintText: "Search friends...",
          prefixIcon: Icon(Icons.search),
          isDense: true,
        ),
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
      ),
    );
  }
  
  Widget _buildFriendsList(AsyncValue<List<dynamic>> friendsAsync) {
    return friendsAsync.when(
      data: (friends) {
        final filtered = friends.where((f) => f.displayName.toLowerCase().contains(_searchQuery)).toList();
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final friend = filtered[i];
            final isAdded = _tempUserIds.contains(friend.id);
            return CheckboxListTile(
              title: Text(friend.displayName),
              secondary: const Icon(Icons.person_outline),
              value: isAdded,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _tempUserIds.add(friend.id);
                  } else {
                    _tempUserIds.remove(friend.id);
                  }
                });
              },
            );
          }
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
    );
  }
}