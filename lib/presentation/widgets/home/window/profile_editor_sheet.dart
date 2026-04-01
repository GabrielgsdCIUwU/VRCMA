import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/presentation/state/profile_management_provider.dart';
import 'package:collection/collection.dart';

class ProfileEditorSheet extends ConsumerStatefulWidget {
  final FilterProfile profile;
  const ProfileEditorSheet({super.key, required this.profile});
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileEditorSheetState();
}

class _ProfileEditorSheetState extends ConsumerState<ProfileEditorSheet> {
  late List<ProfileRule> _tempRules;
  late TextEditingController _nameController;
  
  late List<ProfileRule> _initialRules;
  late String _initialName;
  
  @override
  void initState() {
    super.initState();
    
    _initialRules = List.from(widget.profile.rules);
    _initialName = widget.profile.name;
    
    _tempRules = List.from(widget.profile.rules)
      ..sort((a, b) => a.priority.compareTo(b.priority));
    _nameController = TextEditingController(text: widget.profile.name);
  }
  
  bool get _hasChanges {
    final nameChanged = _nameController.text != _initialName;
    final rulesChanged = !const ListEquality().equals(_tempRules, _initialRules);
    return nameChanged || rulesChanged;
  }
  
  void _saveAndExit() {
    final updatedProfile = FilterProfile(
      id: widget.profile.id,
      name: _nameController.text,
      isActive: widget.profile.isActive,
      rules: _tempRules,
      defaultRole: widget.profile.defaultRole
    );
    ref.read(profileManagementProviderProvider.notifier).updateProfile(updatedProfile);
    Navigator.of(context).pop();
  }
  
  Future<bool> _showExitConfirmation() async {
    if (!_hasChanges) return true;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unsaved Changes"),
        content: const Text("You have made changes to this profile. Do you want to save them before leaving?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text("Discard", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
    
    if (result == 'discard') return true;
    _saveAndExit();
    return false;
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await _showExitConfirmation();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile"),
          actions: [
            IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveAndExit
            ),
          ],
        ),
        body: _buildEditorBody(),
      ),
    );
  }
  
  Widget _buildEditorBody() {
    final allRolesAsync = ref.watch(allAvailableRolesProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Profile Name"),
          ),
        ),
        const Divider(),
        const ListTile(
          title: Text("Priority rules"),
          subtitle: Text("The higher-level riles are evaluated first"),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _tempRules.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -=1;
                final item = _tempRules.removeAt(oldIndex);
                _tempRules.insert(newIndex, item);
                for (int i = 0; i < _tempRules.length; i++) {
                  _tempRules[i] = _tempRules[i].copyWith(priority: i);
                }
              });
            },
            itemBuilder: (context, index) {
              final rule = _tempRules[index];
              return ListTile(
                key: ValueKey("rule_${rule.role.id}"),
                leading: const Icon(Icons.drag_handle),
                title: Text(rule.role.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<RuleAction>(
                      value: rule.action,
                      items: RuleAction.values.map((action) {
                        return DropdownMenuItem(
                          value: action,
                          child: Text(action.name.toUpperCase(),
                              style: TextStyle(color: action == RuleAction.accept ? Colors.green : Colors.red)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _tempRules[index] = rule.copyWith(action: val);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _tempRules.removeAt(index)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _buildAddRuleButton(allRolesAsync),
      ],
    );
  }
  
  Widget _buildAddRuleButton(AsyncValue<List<Role>> allRolesAsync) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text("Add role rule"),
        onPressed: () {
          allRolesAsync.whenData((roles) {
            _showRoleSelectionDialog(roles);
          });
        },
      ),
    );
  }
  
  void _showRoleSelectionDialog(List<Role> roles) {
    final existingRoleIds = _tempRules.map((r) => r.role.id).toSet();
    final availableRoles = roles.where((r) => !existingRoleIds.contains(r.id)).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select a role"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableRoles.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(availableRoles[i].name),
              onTap: () {
                setState(() {
                  _tempRules.add(ProfileRule(
                    role: availableRoles[i],
                    priority: _tempRules.length,
                    action: RuleAction.accept
                  ));
                });
                Navigator.pop(context);
              },
            ),
          ),
        ),
      )
    );
  }
}