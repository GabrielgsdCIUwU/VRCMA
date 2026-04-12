import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/presentation/state/message_management_provider.dart';
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
              final allMessagesAsync = ref.watch(messageManagementProvider);
              return Card(
                key: ValueKey("rule_${rule.role.id}"),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.drag_handle, color: Colors.grey),
                          ),
                        ),
                        title: Text(rule.role.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: rule.action == RuleAction.accept
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<RuleAction>(
                                value: rule.action,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.arrow_drop_down, size: 20),
                                items: RuleAction.values.map((action) {
                                  return DropdownMenuItem(
                                    value: action,
                                    child: Text(
                                        action.name.toUpperCase(),
                                        style: TextStyle(color: action == RuleAction.accept ? Colors.green : Colors.red)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _tempRules[index] = rule.copyWith(action: val);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 22),
                              onPressed: () => setState(() => _tempRules.removeAt(index)),
                              tooltip: "Remove rule",
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(52, 0, 16, 8),
                        child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Divider(height: 1),
                           const SizedBox(height: 8),
                           allMessagesAsync.when(
                             data: (messages) => _buildMessageSelector(index, rule, messages),
                             loading: () => const LinearProgressIndicator(),
                             error: (_, _) => const Text("Error loading messages"),
                           ),
                         ], 
                        )
                      )
                    ],
                  ),
                )
                
              );
            },
          ),
        ),
        _buildAddRuleButton(allRolesAsync),
      ],
    );
  }
  
  Widget _buildMessageSelector(int ruleIndex, ProfileRule rule, List<CustomMessage> allMessages) {
    final hasMessage = rule.message != null;
    return InkWell(
      onTap: () => _showSearchableMessageSelector(context, ruleIndex, rule, allMessages),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withValues(alpha: 0.02),
        ),
        child: Row(
          children: [
            Icon(
              hasMessage ? Icons.message : Icons.message_outlined,
              size: 16,
              color: hasMessage ? Colors.deepPurpleAccent : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasMessage
                  ? rule.message!.content
                  : "None / Default VRChat Message",
                style: TextStyle(
                  fontSize: 13,
                  color: hasMessage ? Colors.white : Colors.white38,
                  fontStyle: hasMessage ? FontStyle.normal : FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.search, size: 16, color: Colors.white24)
          ],
        ),
      ),
    );
  }
  
  void _showSearchableMessageSelector(BuildContext context, int ruleIndex, ProfileRule rule, List<CustomMessage> allMessages) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return _MessageSearchContent(
              allMessages: allMessages,
              initialSelectedId: rule.message?.id,
              onSelected: (selectedMsg) {
                setState(() {
                  _tempRules[ruleIndex] = rule.copyWith(message: selectedMsg);
                });
                Navigator.pop(context);
              }
            );
          },
        );
      }
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

class _MessageSearchContent extends StatefulWidget {
  final List<CustomMessage> allMessages;
  final int? initialSelectedId;
  final Function(CustomMessage?) onSelected;
  
  const _MessageSearchContent({
    required this.allMessages,
    this.initialSelectedId,
    required this.onSelected,
  });
  
  @override
  State<StatefulWidget> createState() => _MessageSearchContentState();
}

class _MessageSearchContentState extends State<_MessageSearchContent> {
  String _query = "";
  
  @override
  Widget build(BuildContext context) {
    final filtered = widget.allMessages
        .where((m) => m.content.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Search messages...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _query = ""))
                : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) => setState(() => _query = val),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.block, color: Colors.grey),
                title: const Text("None / Default VRChat Message"),
                subtitle: const Text("Use the game's default notification text"),
                selected: widget.initialSelectedId == null,
                onTap: () => widget.onSelected(null),
              ),
              const Divider(),
              ...filtered.map((msg) {
                final typeColor = _getTypeColor(msg.type);
              return ListTile(
                leading: Icon(
                _getTypeIcon(msg.type),
                color: typeColor,
                size: 20,
                ),
                title: Text(msg.content),
                subtitle: Text(_getTypeLabel(msg.type), style: const TextStyle(fontSize: 10, letterSpacing: 1)),
                trailing: widget.initialSelectedId == msg.id
                ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                    : null,
                onTap: () => widget.onSelected(msg),
                );
              }),
              if (filtered.isEmpty && _query.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text("No messages match your search")),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  IconData _getTypeIcon(VrcMessageType type) {
    switch (type) {
      case VrcMessageType.invite:
        return Icons.send_rounded;
      case VrcMessageType.response:
        return Icons.reply_rounded;
      case VrcMessageType.request:
        return Icons.hail_rounded;
      case VrcMessageType.requestResponse:
        return Icons.fact_check_rounded;
      
    }
  }
  
  Color _getTypeColor(VrcMessageType type) {
    switch (type) {
      case VrcMessageType.invite:
        return Colors.blueAccent;
      case VrcMessageType.response:
        return Colors.greenAccent;
      case VrcMessageType.request:
        return Colors.orangeAccent;
      case VrcMessageType.requestResponse:
        return Colors.purpleAccent;
    }
  }
  String _getTypeLabel(VrcMessageType type) {
    switch (type) {
      case VrcMessageType.invite: return "INVITE";
      case VrcMessageType.response: return "RESPONSE TO INVITE";
      case VrcMessageType.request: return "REQUEST TO JOIN";
      case VrcMessageType.requestResponse: return "RESPONSE TO REQUEST";
    }
  }
}