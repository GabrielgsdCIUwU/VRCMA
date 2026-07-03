import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/usecase_provider.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';
import 'package:vrcma/presentation/state/role_automation_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/common/showGenericSearchSheet.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_tag_extension.dart';

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
          title: Text(automation == null ? context.l10n.newAutomationTitle : context.l10n.editAutomationTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: Text(context.l10n.btnSave),
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
          width: 380,
          color: Colors.transparent,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _TriggerConfigSection(state: state, notifier: notifier),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _RolesConfigSection(state: state, notifier: notifier, ref: ref),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, RoleAutomation state, RoleAutomationEditor notifier, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TriggerConfigSection(state: state, notifier: notifier),
        const Divider(height: 32),
        _RolesConfigSection(state: state, notifier: notifier, ref: ref),
      ],
    );
  }
}

class _TriggerConfigSection extends StatelessWidget {
  final RoleAutomation state;
  final RoleAutomationEditor notifier;

  const _TriggerConfigSection({required this.state, required this.notifier});
  
  @override
  Widget build(BuildContext context) {
    final friendlyTagName = VrcTag.allTags
        .firstWhereOrNull((t) => t.id == state.targetValue)?.name ?? state.targetValue;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.sectionCondition.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        )),
        const SizedBox(height: 16),
        
        _SelectableCard(
          title: context.l10n.triggerNewFriendTitle,
          subtitle: context.l10n.triggerNewFriendDesc,
          icon: Icons.person_add_alt_1,
          isSelected: state.trigger == AutomationTrigger.newFriend,
          onTap: () => notifier.updateTrigger(AutomationTrigger.newFriend),
        ),
        const SizedBox(height: 8),
        _SelectableCard(
          title: context.l10n.triggerHasTagTitle,
          subtitle: context.l10n.triggerNewFriendDesc,
          icon: Icons.local_offer_outlined,
          isSelected: state.trigger == AutomationTrigger.hasTag,
          onTap: () => notifier.updateTrigger(AutomationTrigger.hasTag),
        ),
        
        if (state.trigger == AutomationTrigger.hasTag)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(context.l10n.targetTagHeader.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
              )),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _showTagSelectionDialog(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer.withValues(alpha: 0.15),
                    border: Border.all(color: context.colorScheme.primary.withValues(alpha: 0.5), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tag, size: 32, color: context.colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                state.targetValue == null ? context.l10n.tagRequired : context.l10n.tagSelected,
                                style: TextStyle(
                                    color: context.colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            Text(
                                friendlyTagName ?? context.l10n.tagSelectPlaceholder,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.colorScheme.onSurface
                                )
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.colorScheme.primary)
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showTagSelectionDialog(BuildContext context) {
    showGenericSearchSheet<VrcTag>(
      context: context,
      items: VrcTag.allTags,
      searchHint: context.l10n.searchTagsVrcHint,
      searchableText: (tag) => "${tag.name} ${tag.id} ${tag.description}",
      itemBuilder: (tag) => ListTile(
        leading: tag.category.getIcon(context),
        title: Text(tag.name),
        subtitle: Text(tag.description, style: const TextStyle(fontSize: 12)),
        trailing: Text(tag.category.name, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
      onSelected: (tag) {
        if (tag != null) {
          notifier.setTargetValue(tag.id);
          Navigator.pop(context);
        }
      }
    );
  }
}

class _RolesConfigSection extends StatelessWidget {
  final RoleAutomation state;
  final RoleAutomationEditor notifier;
  final WidgetRef ref;
  
  const _RolesConfigSection({required this.state, required this.notifier, required this.ref});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.sectionAssignRoles, style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            )),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.l10n.btnAddRole),
              onPressed: () => _showRoleSelectionDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        if (state.roles.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: context.colorScheme.error.withValues(alpha: 0.5), style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: context.colorScheme.error.withValues(alpha: 0.1)
            ),
            child: Column(
              children: [
                Icon(Icons.warning_amber_rounded, color: context.colorScheme.error, size: 32),
                const SizedBox(height: 8),
                Text(context.l10n.noRolesSelectedWarning, style: TextStyle(color: context.colorScheme.error)),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.roles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final role = state.roles[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: context.colorScheme.outlineVariant),
                ),
                tileColor: context.colorScheme.surfaceContainerHighest,
                leading: Icon(Icons.label_outline, color: context.colorScheme.primary, size: 28),
                title: Text(role.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: context.colorScheme.error),
                  onPressed: () => notifier.removeRole(role),
                  tooltip: context.l10n.tooltipRemoveRule,
                ),
              );
            },
          ),
      ],
    );
  }

  void _showRoleSelectionDialog(BuildContext context) async {
    final roles = await ref.read(allAvailableRolesProvider.future);

    if (!context.mounted) return;

    final availableRoles = roles.where((r) => !state.roles.contains(r)).toList();

    showGenericSearchSheet<Role>(
      context: context,
      items: availableRoles,
      searchHint: context.l10n.searchLocalRolesHint,
      searchableText: (role) => role.name,
      itemBuilder: (role) => ListTile(
        leading: Icon(Icons.label, color: Theme.of(context).colorScheme.primary),
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

class _SelectableCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.colorScheme.primary : context.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? context.colorScheme.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurface
                  )),
                  Text(subtitle, style: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.onSurfaceVariant
                  )),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: context.colorScheme.primary)
            else
              Icon(Icons.circle_outlined, color: context.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}