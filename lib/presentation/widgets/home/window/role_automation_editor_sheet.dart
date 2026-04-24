import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';
import 'package:vrcma/presentation/state/role_automation_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/common/showGenericSearchSheet.dart';

class RoleAutomationEditorSheet extends ConsumerWidget {
  final RoleAutomation? automation;
  const RoleAutomationEditorSheet({super.key, this.automation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roleAutomationEditorProvider(automation));
    final notifier = ref.read(roleAutomationEditorProvider(automation).notifier);

    return PopScope(
      canPop: !notifier.hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(automation == null ? "New Automation" : "Edit Automation"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                style: FilledButton.styleFrom(
                  backgroundColor: notifier.isValid && notifier.hasChanges ? context.vrcColors.success : null,
                  foregroundColor: context.colorScheme.onPrimary,
                ),
                onPressed: notifier.isValid && notifier.hasChanges ? () {
                  notifier.saveAndClose();
                  Navigator.pop(context);
                } : null,
              ),
            ),
          ],
        ),
        body: ResponsiveLayout(
          mobile: _buildMobileLayout(context, state, notifier, ref),
          desktop: _buildDesktopLayout(context, state, notifier, ref),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, RoleAutomation state, RoleAutomationEditor notifier, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 320,
          color: context.colorScheme.surfaceContainer,
          padding: const EdgeInsets.all(24),
          child: _buildTriggerConfig(context, state, notifier),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildRolesConfig(context, state, notifier, ref),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, RoleAutomation state, RoleAutomationEditor notifier, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTriggerConfig(context, state, notifier),
        const Divider(height: 32),
        _buildRolesConfig(context, state, notifier, ref),
      ],
    );
  }

  Widget _buildTriggerConfig(BuildContext context, RoleAutomation state, RoleAutomationEditor notifier) {
    final friendlyTagName = VrcTag.allTags.firstWhereOrNull((t) => t.id == state.targetValue)?.name ?? state.targetValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TRIGGER CONDITION", style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2
        )),
        const SizedBox(height: 16),
        DropdownButtonFormField<AutomationTrigger>(
          decoration: const InputDecoration(labelText: "When to trigger"),
          initialValue: state.trigger,
          items: const [
            DropdownMenuItem(value: AutomationTrigger.newFriend, child: Text("On New Friend Added")),
            DropdownMenuItem(value: AutomationTrigger.hasTag, child: Text("If User Has Specific Tag")),
          ],
          onChanged: (val) => val != null ? notifier.updateTrigger(val) : null,
        ),
        if (state.trigger == AutomationTrigger.hasTag) ...[
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Target Tag"),
            subtitle: Text(friendlyTagName ?? "Select a tag..."),
            trailing: const Icon(Icons.search),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: context.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8)
            ),
            onTap: () => _showTagSelectionDialog(context, notifier),
          ),
        ],
      ],
    );
  }

  Widget _buildRolesConfig(BuildContext context, RoleAutomation state, RoleAutomationEditor notifier, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("ASSIGN ROLES", style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            )),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Role"),
              onPressed: () => _showRoleSelectionDialog(context, state, notifier, ref),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.roles.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text("No roles selected. You must assign at least one role.", style: TextStyle(color: context.colorScheme.error)),
            ),
          )
        else
          Wrap(
            spacing: 8, runSpacing: 8,
            children: state.roles.map((role) => Chip(
              label: Text(role.name),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => notifier.removeRole(role),
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              side: BorderSide(color: context.colorScheme.outlineVariant),
            )).toList(),
          ),
      ],
    );
  }

  void _showTagSelectionDialog(BuildContext context, RoleAutomationEditor notifier) {
    showGenericSearchSheet<VrcTag>(
      context: context,
      items: VrcTag.allTags,
      searchHint: "Search VRChat tags...",
      searchableText: (tag) => "${tag.name} ${tag.id} ${tag.description}",
      itemBuilder: (tag) => ListTile(
        leading: const Icon(Icons.tag),
        title: Text(tag.name),
        subtitle: Text(tag.description, style: const TextStyle(fontSize: 12)),
      ),
      onSelected: (tag) {
        if (tag != null) {
          notifier.setTargetValue(tag.id);
          Navigator.pop(context);
        }
      }
    );
  }

  void _showRoleSelectionDialog(BuildContext context, RoleAutomation state, RoleAutomationEditor notifier, WidgetRef ref) async {
    final roles = await ref.read(allAvailableRolesProvider.future);

    if (!context.mounted) return;

    final availableRoles = roles.where((r) => !state.roles.contains(r)).toList();

    showGenericSearchSheet<Role>(
      context: context,
      items: availableRoles,
      searchHint: "Search roles to assign...",
      searchableText: (role) => role.name,
      itemBuilder: (role) => ListTile(
        leading: Icon(Icons.label, color: context.colorScheme.primary),
        title: Text(role.name),
      ),
      onSelected: (role) {
        if (role != null) {
          notifier.addRole(role);
          Navigator.pop(context);
        }
      }
    );
  }
}