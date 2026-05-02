import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';
import 'package:vrcma/presentation/state/message_management_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/common/showGenericSearchSheet.dart';
import 'package:vrcma/presentation/state/profile_editor_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_tag_extension.dart';

class ProfileEditorSheet extends ConsumerStatefulWidget {
  final FilterProfile profile;
  const ProfileEditorSheet({super.key, required this.profile});
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileEditorSheetState();
}

class _ProfileEditorSheetState extends ConsumerState<ProfileEditorSheet> {
  late TextEditingController _nameController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  void _saveAndExit() {
    ref.read(profileEditorProvider(widget.profile).notifier).save();
    Navigator.of(context).pop();
  }
  
  Future<bool> _showExitConfirmation() async {
    final hasChanges = ref.read(profileEditorProvider(widget.profile).notifier).hasChanges;
    if (hasChanges) return true;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unsaved Changes"),
        content: const Text("You have made changes to this profile. Do you want to save them before leaving?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text("Discard", style: TextStyle(color: context.colorScheme.error)),
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
    final currentProfile = ref.watch(profileEditorProvider(widget.profile));
    final hasChanges = ref.watch(profileEditorProvider(widget.profile).notifier).hasChanges;
    
    return PopScope(
      canPop: !hasChanges,
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
                  backgroundColor: hasChanges ? context.vrcColors.success : null,
                  foregroundColor: hasChanges ? context.colorScheme.onPrimary : context.colorScheme.onSurfaceVariant,
                ),
                onPressed: hasChanges ? _saveAndExit : null,
              ),
            ),
          ],
        ),
        body: _buildResponsiveBody(currentProfile),
      ),
    );
  }
  
  Widget _buildResponsiveBody(FilterProfile currentProfile) {
    final allRolesAsync = ref.watch(allAvailableRolesProvider);
    final allMessagesAsync = ref.watch(messageManagementProvider);
    
    return ResponsiveLayout(
        mobile: _buildMobileLayout(currentProfile, allRolesAsync, allMessagesAsync),
        desktop: _buildDesktopLayout(currentProfile, allRolesAsync, allMessagesAsync),
    );
  }
  
  Widget _buildDesktopLayout(FilterProfile currentProfile, AsyncValue<List<Role>> allRolesAsync, AsyncValue<List<CustomMessage>> allMessagesAsync) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 320,
          color: context.colorScheme.surfaceContainer,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("PROFILE SETTINGS", style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold
              )),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 40),
              Text("ACTIONS", style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _buildAddRuleButton(currentProfile, allRolesAsync),
              ),
              const Spacer(),
              Icon(Icons.info_outline, color: context.colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(height: 8),
              Text("Higher priority rules (at the top) are evaluated first.",
                style: TextStyle(color: context.colorScheme.onSurfaceVariant, fontSize: 12),
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
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold
                    )),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: context.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                      child: Text("${currentProfile.rules.length}", style: TextStyle(fontSize: 12, color: context.colorScheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        Expanded(child: _buildRulesList(currentProfile, allMessagesAsync)),
                        Divider(height: 1, color: context.colorScheme.outlineVariant),
                        _buildFallbackTagsSection(currentProfile),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
  
  Widget _buildMobileLayout(FilterProfile currentProfile, AsyncValue<List<Role>> allRolesAsync, AsyncValue<List<CustomMessage>> allMessagesAsync) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildNameField(),
        ),
        const Divider(height: 1),
        const ListTile(
          title: Text("Priority rules"),
          subtitle: Text("The higher-level rules are evaluated first"),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(child: _buildRulesList(currentProfile, allMessagesAsync)),
              Divider(height: 1, color: context.colorScheme.outlineVariant),
              _buildFallbackTagsSection(currentProfile),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: _buildAddRuleButton(currentProfile, allRolesAsync),
          ),
        ),
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
      onChanged: (val) => ref.read(profileEditorProvider(widget.profile).notifier).updateName(val),
    );
  }
  
  
  Widget _buildMessagesSection(int ruleIndex, ProfileRule rule, List<CustomMessage> allMessages) {
    return ResponsiveLayout(
      breakpoint: 600,
      desktop: Row(
        children: [
          Expanded(child: _buildMessageContextSelector(ruleIndex, rule, allMessages, RuleMessageContext.inviteResponse)),
          const SizedBox(width: 16),
          Expanded(child: _buildMessageContextSelector(ruleIndex, rule, allMessages, RuleMessageContext.requestResponse)),
        ],
      ),
      mobile: Column(
        children: [
          _buildMessageContextSelector(ruleIndex, rule, allMessages, RuleMessageContext.inviteResponse),
          const SizedBox(height: 12),
          _buildMessageContextSelector(ruleIndex, rule, allMessages, RuleMessageContext.requestResponse),
        ],
      ),
    );
  }
  
  Widget _buildMessageContextSelector(int ruleIndex, ProfileRule rule, List<CustomMessage> allMessages, RuleMessageContext contextType) {
    final targetType = contextType.getExpectedMessageType(rule.action);
    final isInvite = contextType == RuleMessageContext.inviteResponse;
    
    final title = isInvite ? "ON INVITE RECEIVED" : "ON REQUEST TO JOIN";
    final iconData = _getTypeIcon(targetType);
    final color = _getTypeColor(targetType);
    
    final currentMessage = isInvite ? rule.inviteResponseMessage : rule.requestResponseMessage;
    final hasMessage = currentMessage != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(iconData, size: 14, color: color),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurfaceVariant,
                letterSpacing: 0.5
            )),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showSearchableMessageSelector(context, ruleIndex, rule, allMessages, contextType),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: hasMessage ? color.withValues(alpha: 0.5) : context.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
              color: hasMessage ? color.withValues(alpha: 0.05) : context.colorScheme.onSurface.withValues(alpha: 0.02),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasMessage ? currentMessage.content : "Default VRChat Message",
                    style: TextStyle(
                      fontSize: 13,
                      color: hasMessage ? context.colorScheme.onSurface : context.colorScheme.onSurfaceVariant,
                      fontStyle: hasMessage ? FontStyle.normal : FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.edit_note, size: 18, color: hasMessage ? color : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5))
              ],
            ),
          ),
        )
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
        return context.vrcColors.invite;
      case VrcMessageType.response:
        return context.vrcColors.response;
      case VrcMessageType.request:
        return context.vrcColors.request;
      case VrcMessageType.requestResponse:
        return context.vrcColors.requestResponse;
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
  
  void _showSearchableMessageSelector(BuildContext context, int ruleIndex, ProfileRule rule, List<CustomMessage> allMessages, RuleMessageContext contextType) {
    final targetType = contextType.getExpectedMessageType(rule.action);
    
    final filteredMessages = allMessages.where((m) => m.type == targetType).toList();
    
    final isInvite = contextType == RuleMessageContext.inviteResponse;
    final sheetTitle = "Select ${_getTypeLabel(targetType)}";
    final currentMessageId = isInvite ? rule.inviteResponseMessage?.id : rule.requestResponseMessage?.id;
    
    showGenericSearchSheet<CustomMessage>(
      context: context,
      items: filteredMessages,
      searchHint: "Search $sheetTitle...",
      searchableText: (CustomMessage message) => message.content,
      headerOption: ListTile(
        leading: Icon(Icons.block, color: context.colorScheme.onSurfaceVariant),
        title: const Text("None / Default VRChat Message"),
        subtitle: const Text("Use the game's default notification text"),
        selected: currentMessageId == null,
        onTap: () {
          ref.read(profileEditorProvider(widget.profile).notifier).updateRuleMessage(ruleIndex, null, contextType);
          Navigator.pop(context);
        },
      ),
      itemBuilder: (CustomMessage msg) {
        return ListTile(
          leading: Icon(
              _getTypeIcon(targetType), 
              color: _getTypeColor(targetType),
              size: 20
          ),
          title: Text(msg.content),
          trailing: currentMessageId == msg.id ? Icon(Icons.check_circle, color: context.vrcColors.success) : null,
        );
      },
      onSelected: (CustomMessage? selectedMsg) {
        ref.read(profileEditorProvider(widget.profile).notifier).updateRuleMessage(ruleIndex, selectedMsg, contextType);
        Navigator.pop(context);
      }
    );
  }
  
  Widget _buildRulesList(FilterProfile currentProfile, AsyncValue<List<CustomMessage>> allMessagesAsync) {
    if (currentProfile.rules.isEmpty) {
      return Center(
        child: Text("No rules added yet.\nClick 'Add role rule' to start.",
          textAlign: TextAlign.center,
          style: TextStyle(color: context.colorScheme.onSurfaceVariant),
        ),
      );
    }
    
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      itemCount: currentProfile.rules.length,
      onReorder: (oldIndex, newIndex) {
       ref.read(profileEditorProvider(widget.profile).notifier).reorderRules(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final rule = currentProfile.rules[index];
        return _buildRuleCard(index, rule, allMessagesAsync);
      },
    );
  }
  
  Widget _buildRuleCard(int index, ProfileRule rule, AsyncValue<List<CustomMessage>> allMessagesAsync) {
    return Card(
      key: ValueKey("rule_${rule.role.id}"),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: context.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.drag_handle, color: context.colorScheme.onSurfaceVariant),
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
                          ? context.vrcColors.success.withValues(alpha: 0.1)
                          : context.colorScheme.error.withValues(alpha: 0.1),
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
                              color: action == RuleAction.accept ? context.vrcColors.success : context.colorScheme.error,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                       if (val != null) {
                         ref.read(profileEditorProvider(widget.profile).notifier)
                             .updateRuleAction(index, val);
                       }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_sweep_outlined, color: context.colorScheme.error, size: 20),
                    onPressed: () => ref.read(profileEditorProvider(widget.profile).notifier).removeRule(index),
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
                  Divider(height: 1, color: context.colorScheme.outlineVariant),
                  const SizedBox(height: 12),
                  allMessagesAsync.when(
                    data: (messages) => _buildMessagesSection(index, rule, messages),
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
  
  Widget _buildAddRuleButton(FilterProfile currentProfile, AsyncValue<List<Role>> allRolesAsync) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text("Add role rule"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8)),
      ),
      onPressed: () {
        allRolesAsync.whenData((roles) {
          _showRoleSelectionDialog(currentProfile, roles);
        });
      },
    );
  }
  
  void _showRoleSelectionDialog(FilterProfile currentProfile, List<Role> roles) {
    final existingRoleIds =currentProfile.rules.map((r) => r.role.id).toSet();
    final availableRoles = roles.where((r) => !existingRoleIds.contains(r.id)).toList();
    
    showGenericSearchSheet<Role>(
      context: context,
      items: availableRoles,
      searchHint: "Search roles...",
      searchableText: (Role role) => role.name,
      itemBuilder: (Role role) => ListTile(
        leading: Icon(Icons.label_outline, color: context.colorScheme.primary),
        title: Text(role.name),
      ),
      onSelected: (Role? role) {
        if (role != null) {
         ref.read(profileEditorProvider(widget.profile).notifier).addRule(role);
          Navigator.pop(context);
        }
      }
    );
  }
  
  Widget _buildFallbackTagsSection(FilterProfile currentProfile) {
    final isEnabled = currentProfile.fallbackTagsAction != FallbackTagAction.disabled;
    
    return Container(
      padding: const EdgeInsets.all(24),
      color: context.colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("FALLBACK TAGS", style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.2,
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold
                  )),
                  const SizedBox(height: 4),
                  Text("Evaluated if no role matches", style: TextStyle(fontSize: 12, color: context.colorScheme.onSurfaceVariant)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: currentProfile.fallbackTagsAction == FallbackTagAction.accept
                      ? context.vrcColors.success.withValues(alpha: 0.1)
                      : currentProfile.fallbackTagsAction == FallbackTagAction.reject
                        ? context.colorScheme.error.withValues(alpha: 0.1)
                        : context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<FallbackTagAction>(
                  value: currentProfile.fallbackTagsAction,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  items: [
                    DropdownMenuItem(value: FallbackTagAction.disabled, child: Text("DISABLED", style: TextStyle(fontSize: 13, color: context.colorScheme.onSurfaceVariant))),
                    DropdownMenuItem(value: FallbackTagAction.accept, child: Text("ACCEPT", style: TextStyle(fontSize: 13, color: context.vrcColors.success))),
                    DropdownMenuItem(value: FallbackTagAction.reject, child: Text("REJECT", style: TextStyle(fontSize: 13, color: context.colorScheme.error))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(profileEditorProvider(widget.profile).notifier).updateFallbackTagsAction(val);
                    }
                  },
                ),
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...currentProfile.fallbackTags.map((tag) {
                  return Chip(
                    label: Text(tag.name, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => ref.read(profileEditorProvider(widget.profile).notifier).removeFallbackTag(tag),
                    backgroundColor: context.colorScheme.surfaceContainerHighest,
                    side: BorderSide(color: context.colorScheme.outlineVariant),
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: const Text("Add Tag"),
                  backgroundColor: context.colorScheme.primary.withValues(alpha: 0.2),
                  side: BorderSide(color: context.colorScheme.primary),
                  onPressed: () => _showTagSelectionDialog(currentProfile),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  void _showTagSelectionDialog(FilterProfile currentProfile) {
    final availableTags = VrcTag.allTags.where((tag) => !currentProfile.fallbackTags.contains(tag)).toList();
    
    showGenericSearchSheet<VrcTag>(
      context: context,
      items: availableTags,
      searchHint: "Search tags or languages...",
      searchableText: (VrcTag tag) => "${tag.name} ${tag.description} ${tag.id}",
      itemBuilder: (VrcTag tag) {
        return ListTile(
          leading: tag.category.getIcon(context),
          title: Text(tag.name),
          subtitle: Text(tag.description, style: const TextStyle(fontSize: 12)),
          trailing: Text(tag.category.name.toUpperCase(), style: TextStyle(fontSize: 9, color: context.colorScheme.onSurfaceVariant)),
        );
      },
      onSelected: (VrcTag? tag) {
        if (tag != null) {
          ref.read(profileEditorProvider(widget.profile).notifier).addFallbackTag(tag);
          Navigator.pop(context);
        }
      }
    );
  }
}
