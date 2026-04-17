import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/presentation/state/message_management_provider.dart';
import 'package:vrcma/presentation/state/profile_management_provider.dart';
import 'package:collection/collection.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/common/showGenericSearchSheet.dart';

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
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                style: FilledButton.styleFrom(
                  backgroundColor: _hasChanges ? Colors.greenAccent : null,
                  foregroundColor: _hasChanges ? Colors.white : Colors.grey,
                ),
                onPressed: _hasChanges ? _saveAndExit : null,
              ),
            ),
          ],
        ),
        body: _buildResponsiveBody(),
      ),
    );
  }
  
  Widget _buildResponsiveBody() {
    final allRolesAsync = ref.watch(allAvailableRolesProvider);
    final allMessagesAsync = ref.watch(messageManagementProvider);
    
    return ResponsiveLayout(
        mobile: _buildMobileLayout(allRolesAsync, allMessagesAsync),
        desktop: _buildDesktopLayout(allRolesAsync, allMessagesAsync),
    );
  }
  
  Widget _buildDesktopLayout(AsyncValue<List<Role>> allRolesAsync, AsyncValue<List<CustomMessage>> allMessagesAsync) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 320,
          color: Colors.black12,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("PROFILE SETTINGS", style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.bold
              )),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 40),
              Text("ACTIONS", style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.bold
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _buildAddRuleButton(allRolesAsync),
              ),
              const Spacer(),
              const Icon(Icons.info_outline, color: Colors.grey, size: 20),
              const SizedBox(height: 8),
              const Text("Higher priority rules (at the top) are evaluated first.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Text("AUTOMATION RULES", style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.2,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.bold
                    )),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                      child: Text("${_tempRules.length}", style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _buildRulesList(allMessagesAsync),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
  
  Widget _buildMobileLayout(AsyncValue<List<Role>> allRolesAsync, AsyncValue<List<CustomMessage>> allMessagesAsync) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildNameField(),
        ),
        const Divider(),
        const ListTile(
          title: Text("Priority rules"),
          subtitle: Text("The higher-level rules are evaluated first"),
        ),
        Expanded(
          child: _buildRulesList(allMessagesAsync),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: _buildAddRuleButton(allRolesAsync),
          ),
        )
      ],
    );
  }
  
  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: "Profile Name",
        prefixIcon: Icon(Icons.badge_outlined),
      ),
      onChanged: (_) => setState(() {}),
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
  
  void _showSearchableMessageSelector(BuildContext context, int ruleIndex, ProfileRule rule, List<CustomMessage> allMessages) {
    showGenericSearchSheet<CustomMessage>(
      context: context,
      items: allMessages,
      searchHint: "Search messages...",
      searchableText: (CustomMessage message) => message.content,
      headerOption: ListTile(
        leading: const Icon(Icons.block, color: Colors.grey),
        title: const Text("None / Default VRChat Message"),
        subtitle: const Text("Use the game's default notification text"),
        selected: rule.message == null,
        onTap: () {
          setState(() => _tempRules[ruleIndex] = rule.copyWith(message: null));
          Navigator.pop(context);
        },
      ),
      itemBuilder: (CustomMessage msg) {
        final typeColor = _getTypeColor(msg.type);
        return ListTile(
          leading: Icon(_getTypeIcon(msg.type), color: typeColor, size: 20),
          title: Text(msg.content),
          subtitle: Text(_getTypeLabel(msg.type), style: const TextStyle(fontSize: 10, letterSpacing: 1)),
          trailing: rule.message?.id == msg.id ? const Icon(Icons.check_circle, color: Colors.greenAccent) : null,
        );
      },
      onSelected: (CustomMessage? selectedMsg) {
        setState(() => _tempRules[ruleIndex] = rule.copyWith(message: selectedMsg));
        Navigator.pop(context);
      }
    );
  }
  
  Widget _buildRulesList(AsyncValue<List<CustomMessage>> allMessagesAsync) {
    if (_tempRules.isEmpty) {
      return const Center(
        child: Text("No rules added yet.\nClick 'Add role rule' to start.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38),
        ),
      );
    }
    
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      itemCount: _tempRules.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _tempRules.removeAt(oldIndex);
          _tempRules.insert(newIndex, item);
          for (int i = 0; i < _tempRules.length; i++) {
            _tempRules[i] = _tempRules[i].copyWith(priority: i);
          }
        });
      },
      itemBuilder: (context, index) {
        final rule = _tempRules[index];
        return _buildRuleCard(index, rule, allMessagesAsync);
      },
    );
  }
  
  Widget _buildRuleCard(int index, ProfileRule rule, AsyncValue<List<CustomMessage>> allMessagesAsync) {
    return Card(
      key: ValueKey("rule_${rule.role.id}"),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10),
      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: action == RuleAction.accept ? Colors.green : Colors.redAccent
                            ),
                          ),
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
                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 20),
                    onPressed: () => setState(() => _tempRules.removeAt(index)),
                    tooltip: "Remove rule",
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(68, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Colors.white10),
                  const SizedBox(height: 12),
                  allMessagesAsync.when(
                    data: (messages) => _buildMessageSelector(index, rule, messages),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const Text("Error loading messages"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddRuleButton(AsyncValue<List<Role>> allRolesAsync) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text("Add role rule"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8)),
      ),
      onPressed: () {
        allRolesAsync.whenData((roles) {
          _showRoleSelectionDialog(roles);
        });
      },
    );
  }
  
  void _showRoleSelectionDialog(List<Role> roles) {
    final existingRoleIds = _tempRules.map((r) => r.role.id).toSet();
    final availableRoles = roles.where((r) => !existingRoleIds.contains(r.id)).toList();
    
    showGenericSearchSheet<Role>(
      context: context,
      items: availableRoles,
      searchHint: "Search roles...",
      searchableText: (Role role) => role.name,
      itemBuilder: (Role role) => ListTile(
        leading: const Icon(Icons.label_outline, color: Colors.deepPurpleAccent),
        title: Text(role.name),
      ),
      onSelected: (Role? role) {
        if (role != null) {
          setState(() {
            _tempRules.add(ProfileRule(
              role: role,
              priority: _tempRules.length,
              action: RuleAction.accept
            ));
          });
          Navigator.pop(context);
        }
      }
    );
  }
}
