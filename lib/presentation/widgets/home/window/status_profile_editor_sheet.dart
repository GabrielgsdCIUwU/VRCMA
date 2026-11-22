import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/usecase_provider.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_template_resolver.dart';
import 'package:vrcma/presentation/extensions/enum_extensions.dart';
import 'package:vrcma/presentation/extensions/text_editing_extensions.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/status_profile_editor_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/adaptive_context_menu_wrapper.dart';
import 'package:vrcma/presentation/widgets/home/common/adaptive_dialogs.dart';
import 'package:vrcma/presentation/widgets/home/common/editor_save_button.dart';
import 'package:vrcma/presentation/widgets/home/common/editor_section_header.dart';
import 'package:vrcma/presentation/widgets/home/common/editor_tag_pill.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/common/show_generic_search_sheet.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_avatar.dart';

enum _RuleContextAction { preview, edit, delete }

/// Displays labeled placeholder chips that insert template tokens at the cursor.
class StatusTemplateHelperWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const StatusTemplateHelperWidget({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final variables = _buildPlaceholders(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.statusVariablesHelperTitle,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          context.l10n.statusVariablesHelperDesc,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: variables
              .map(
                (item) => Tooltip(
              message: '${item.description} (${item.tag})',
              child: ActionChip(
                avatar: Icon(
                  item.icon,
                  size: 15,
                  color: context.colorScheme.primary,
                ),
                label: Text(
                  '${item.shortLabel} ${item.tag}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    controller.insertAtCursor(item.tag, onChanged: onChanged),
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }

  List<({String tag, String shortLabel, String description, IconData icon})>
  _buildPlaceholders(BuildContext context) {
    final l10n = context.l10n;
    return [
      (
      tag: '{{world}}',
      shortLabel: l10n.statusPlaceholderWorldShort,
      description: l10n.statusVariableWorld,
      icon: Icons.public,
      ),
      (
      tag: '{{count}}',
      shortLabel: l10n.statusPlaceholderCountShort,
      description: l10n.statusVariableCount,
      icon: Icons.people_outline,
      ),
      (
      tag: '{{battery}}',
      shortLabel: l10n.statusPlaceholderBatteryShort,
      description: l10n.statusVariableBattery,
      icon: Icons.battery_charging_full,
      ),
      (
      tag: '{{instance}}',
      shortLabel: l10n.statusPlaceholderInstanceShort,
      description: l10n.statusVariableInstance,
      icon: Icons.vpn_lock,
      ),
      (
      tag: '{{time}}',
      shortLabel: l10n.statusPlaceholderTimeShort,
      description: l10n.statusVariableTime,
      icon: Icons.access_time,
      ),
      (
      tag: '{{friends}}',
      shortLabel: l10n.statusPlaceholderFriendsShort,
      description: l10n.statusVariableFriends,
      icon: Icons.person_pin_outlined,
      ),
    ];
  }
}

/// Full-screen editor for creating or modifying a [StatusProfile].
class StatusProfileEditorSheet extends ConsumerStatefulWidget {
  final StatusProfile profile;

  const StatusProfileEditorSheet({super.key, required this.profile});

  @override
  ConsumerState<StatusProfileEditorSheet> createState() =>
      _StatusProfileEditorSheetState();
}

class _StatusProfileEditorSheetState
    extends ConsumerState<StatusProfileEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _fallbackTemplateController;

  /// Index of the rule currently previewed; null previews the fallback config.
  int? _previewRuleIndex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _fallbackTemplateController =
        TextEditingController(text: widget.profile.fallbackTemplate ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fallbackTemplateController.dispose();
    super.dispose();
  }

  void _saveAndExit() {
    ref.read(statusProfileEditorProvider(widget.profile).notifier).save();
    Navigator.of(context).pop();
  }

  Future<void> _handleExitPrompt(BuildContext context) async {
    final action = await AdaptiveDialogs.showUnsavedChangesDialog(context);
    if (!context.mounted || action == null) return;

    switch (action) {
      case UnsavedChangesAction.discard:
        Navigator.of(context).pop();
      
      case UnsavedChangesAction.save:
        _saveAndExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile =
    ref.watch(statusProfileEditorProvider(widget.profile));
    final notifier =
    ref.read(statusProfileEditorProvider(widget.profile).notifier);
    final activePreviewIndex = _clampPreviewIndex(currentProfile);
    final canSave =
        notifier.hasChanges && currentProfile.name.trim().isNotEmpty;

    return PopScope(
      canPop: !notifier.hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExitPrompt(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.editStatusProfileTitle),
          actions: [EditorSaveButton(canSave: canSave, onPressed: _saveAndExit)],
        ),
        body: ResponsiveLayout(
          mobile: _MobileStatusBody(
            profile: currentProfile,
            notifier: notifier,
            nameController: _nameController,
            fallbackTemplateController: _fallbackTemplateController,
            previewRuleIndex: activePreviewIndex,
            onPreviewIndexChanged: (i) => setState(() => _previewRuleIndex = i),
          ),
          desktop: _DesktopStatusBody(
            profile: currentProfile,
            notifier: notifier,
            nameController: _nameController,
            fallbackTemplateController: _fallbackTemplateController,
            previewRuleIndex: activePreviewIndex,
            onPreviewIndexChanged: (i) => setState(() => _previewRuleIndex = i),
          ),
        ),
      ),
    );
  }

  int? _clampPreviewIndex(StatusProfile profile) {
    if (_previewRuleIndex == null) return null;
    if (_previewRuleIndex! >= profile.rules.length) return null;
    return _previewRuleIndex;
  }
}

class _MobileStatusBody extends StatelessWidget {
  final StatusProfile profile;
  final StatusProfileEditorNotifier notifier;
  final TextEditingController nameController;
  final TextEditingController fallbackTemplateController;
  final int? previewRuleIndex;
  final ValueChanged<int?> onPreviewIndexChanged;

  const _MobileStatusBody({
    required this.profile,
    required this.notifier,
    required this.nameController,
    required this.fallbackTemplateController,
    required this.previewRuleIndex,
    required this.onPreviewIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GeneralStatusPane(
            profile: profile,
            notifier: notifier,
            nameController: nameController,
            fallbackTemplateController: fallbackTemplateController,
          ),
          const SizedBox(height: 16),
          _LiveStatusCardPreview(
            profile: profile,
            previewRuleIndex: previewRuleIndex,
            onPreviewIndexChanged: onPreviewIndexChanged,
          ),
          const Divider(height: 32),
          _ConditionsPane(
            profile: profile,
            notifier: notifier,
            onPreviewRule: onPreviewIndexChanged,
          ),
        ],
      ),
    );
  }
}

class _DesktopStatusBody extends StatelessWidget {
  final StatusProfile profile;
  final StatusProfileEditorNotifier notifier;
  final TextEditingController nameController;
  final TextEditingController fallbackTemplateController;
  final int? previewRuleIndex;
  final ValueChanged<int?> onPreviewIndexChanged;

  const _DesktopStatusBody({
    required this.profile,
    required this.notifier,
    required this.nameController,
    required this.fallbackTemplateController,
    required this.previewRuleIndex,
    required this.onPreviewIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GeneralStatusPane(
                  profile: profile,
                  notifier: notifier,
                  nameController: nameController,
                  fallbackTemplateController: fallbackTemplateController,
                ),
                const SizedBox(height: 24),
                _LiveStatusCardPreview(
                  profile: profile,
                  previewRuleIndex: previewRuleIndex,
                  onPreviewIndexChanged: onPreviewIndexChanged,
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _ConditionsPane(
              profile: profile,
              notifier: notifier,
              onPreviewRule: onPreviewIndexChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _GeneralStatusPane extends StatelessWidget {
  final StatusProfile profile;
  final StatusProfileEditorNotifier notifier;
  final TextEditingController nameController;
  final TextEditingController fallbackTemplateController;

  const _GeneralStatusPane({
    required this.profile,
    required this.notifier,
    required this.nameController,
    required this.fallbackTemplateController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(title: context.l10n.sectionGeneralSettings),
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: context.l10n.inputStatusProfileName,
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
          onChanged: notifier.updateName,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<StatusType>(
          initialValue: profile.fallbackStatus,
          decoration: InputDecoration(
            labelText: context.l10n.inputFallbackStatus,
            prefixIcon: const Icon(Icons.lens, size: 18),
          ),
          items: StatusType.values
              .map(
                (status) => DropdownMenuItem(
              value: status,
              child: Text(status.toLocalizedString(context).toUpperCase()),
            ),
          )
              .toList(),
          onChanged: (val) {
            if (val != null) notifier.updateFallbackStatus(val);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: fallbackTemplateController,
          maxLength: 42,
          decoration: InputDecoration(
            labelText: context.l10n.inputFallbackTemplate,
            hintText: context.l10n.statusMessageTemplateHint,
            prefixIcon: const Icon(Icons.short_text),
          ),
          onChanged: notifier.updateFallbackTemplate,
        ),
        const SizedBox(height: 8),
        StatusTemplateHelperWidget(
          controller: fallbackTemplateController,
          onChanged: notifier.updateFallbackTemplate,
        ),
      ],
    );
  }
}

class _LiveStatusCardPreview extends ConsumerWidget {
  static const int _maxStatusChars = 42;

  final StatusProfile profile;
  final int? previewRuleIndex;
  final ValueChanged<int?> onPreviewIndexChanged;

  const _LiveStatusCardPreview({
    required this.profile,
    required this.previewRuleIndex,
    required this.onPreviewIndexChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final sampleContext = _buildSampleContext();
    final (targetStatus, rawTemplate) = _resolveActivePreviewTarget();
    final resolvedMessage =
    StatusTemplateResolver().resolve(rawTemplate, sampleContext);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(
          title: context.l10n.calLiveCardPreview,
          color: context.colorScheme.secondary,
        ),
        const SizedBox(height: 12),
        _PreviewCardSurface(
          user: currentUser,
          status: targetStatus,
          resolvedMessage: resolvedMessage,
          maxChars: _maxStatusChars,
          profile: profile,
          previewRuleIndex: previewRuleIndex,
          onPreviewIndexChanged: onPreviewIndexChanged,
        ),
      ],
    );
  }

  StatusContext _buildSampleContext() {
    return StatusContext(
      worldName: 'The Black Cat',
      worldId: 'wrld_example_123',
      population: 14,
      instanceType: InstanceAccessType.friendsPlus,
      batteryLevel: 84,
      isCharging: false,
      timestamp: DateTime.now(),
      presentFriendNames: const ['VRRat', 'VRCat'],
    );
  }

  (StatusType, String) _resolveActivePreviewTarget() {
    if (previewRuleIndex != null && previewRuleIndex! < profile.rules.length) {
      final rule = profile.rules[previewRuleIndex!];
      return (rule.targetStatus, rule.messageTemplate ?? '');
    }
    return (profile.fallbackStatus, profile.fallbackTemplate ?? '');
  }
}

class _PreviewCardSurface extends StatelessWidget {
  final VrcUser? user;
  final StatusType status;
  final String resolvedMessage;
  final int maxChars;
  final StatusProfile profile;
  final int? previewRuleIndex;
  final ValueChanged<int?> onPreviewIndexChanged;

  const _PreviewCardSurface({
    required this.user,
    required this.status,
    required this.resolvedMessage,
    required this.maxChars,
    required this.profile,
    required this.previewRuleIndex,
    required this.onPreviewIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = resolvedMessage.isEmpty
        ? context.l10n.statusRuleNoMessage
        : resolvedMessage;

    return Card(
      elevation: 0,
      color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.colorScheme.secondary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreviewProfileRow(
              user: user,
              status: status,
              displayText: displayText,
            ),
            const Divider(height: 24),
            _PreviewMetaFooter(
              charCount: resolvedMessage.length,
              maxChars: maxChars,
            ),
            if (profile.rules.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PreviewTargetChips(
                ruleCount: profile.rules.length,
                selectedIndex: previewRuleIndex,
                onSelected: onPreviewIndexChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewProfileRow extends StatelessWidget {
  final VrcUser? user;
  final StatusType status;
  final String displayText;

  const _PreviewProfileRow({
    required this.user,
    required this.status,
    required this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'VRCMA User';
    final statusColor = context.getStatusColor(status.apiValue);

    return Row(
      children: [
        Stack(
          children: [
            VrcAvatar(
              imageUrl: user?.avatarUrl,
              displayName: displayName,
              radius: 24,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  EditorTagPill(
                    label: status.toLocalizedString(context).toUpperCase(),
                    color: statusColor,
                    showBorder: true,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                displayText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontStyle: displayText == context.l10n.statusRuleNoMessage
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewMetaFooter extends StatelessWidget {
  final int charCount;
  final int maxChars;

  const _PreviewMetaFooter({required this.charCount, required this.maxChars});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.statusPreviewSampleCaption('The Black Cat', 14, 84),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          context.l10n.statusCharCount(charCount, maxChars),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: charCount >= maxChars
                ? context.vrcColors.request
                : context.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _PreviewTargetChips extends StatelessWidget {
  final int ruleCount;
  final int? selectedIndex;
  final ValueChanged<int?> onSelected;

  const _PreviewTargetChips({
    required this.ruleCount,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ChoiceChip(
          label: Text(
            context.l10n.statusPreviewFallback,
            style: const TextStyle(fontSize: 11),
          ),
          selected: selectedIndex == null,
          visualDensity: VisualDensity.compact,
          onSelected: (_) => onSelected(null),
        ),
        for (int i = 0; i < ruleCount; i++)
          ChoiceChip(
            label: Text(
              context.l10n.statusPreviewRuleLabel(i + 1),
              style: const TextStyle(fontSize: 11),
            ),
            selected: selectedIndex == i,
            visualDensity: VisualDensity.compact,
            onSelected: (_) => onSelected(i),
          ),
      ],
    );
  }
}

class _ConditionsPane extends StatelessWidget {
  final StatusProfile profile;
  final StatusProfileEditorNotifier notifier;
  final ValueChanged<int?> onPreviewRule;

  const _ConditionsPane({
    required this.profile,
    required this.notifier,
    required this.onPreviewRule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(
          title: context.l10n.sectionAutomationConditions,
          trailing: FilledButton.tonalIcon(
            icon: const Icon(Icons.add, size: 18),
            label: Text(context.l10n.btnAddConditionRule),
            onPressed: () => _openRuleDialog(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.rulesReorderSubtitle,
          style: TextStyle(
            fontSize: 12,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        _StatusRulesList(
          profile: profile,
          notifier: notifier,
          onEditRule: (index) => _openRuleDialog(context, editIndex: index),
          onPreviewRule: onPreviewRule,
        ),
      ],
    );
  }

  Future<void> _openRuleDialog(BuildContext context, {int? editIndex}) async {
    final existingRule = editIndex != null ? profile.rules[editIndex] : null;
    final savedRule = await showDialog<StatusRule>(
      context: context,
      builder: (_) => _StatusRuleEditorDialog(
        priority: editIndex ?? profile.rules.length,
        initialRule: existingRule,
      ),
    );

    if (savedRule == null) return;
    if (editIndex != null) {
      notifier.updateRule(editIndex, savedRule);
      return;
    }
    notifier.addRule(savedRule);
  }
}

class _StatusRulesList extends StatelessWidget {
  final StatusProfile profile;
  final StatusProfileEditorNotifier notifier;
  final ValueChanged<int> onEditRule;
  final ValueChanged<int?> onPreviewRule;

  const _StatusRulesList({
    required this.profile,
    required this.notifier,
    required this.onEditRule,
    required this.onPreviewRule,
  });

  @override
  Widget build(BuildContext context) {
    if (profile.rules.isEmpty) {
      return Card(
        elevation: 0,
        shape: context.outlinedCardShape,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              context.l10n.noStatusRulesAdded,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profile.rules.length,
      onReorder: notifier.reorderRules,
      itemBuilder: (context, index) => _StatusRuleCard(
        key: ValueKey('status_rule_${profile.rules[index].hashCode}_$index'),
        index: index,
        rule: profile.rules[index],
        onEdit: () => onEditRule(index),
        onPreview: () => onPreviewRule(index),
        onDelete: () => notifier.removeRule(index),
      ),
    );
  }
}

class _StatusRuleCard extends ConsumerWidget {
  final int index;
  final StatusRule rule;
  final VoidCallback onEdit;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  const _StatusRuleCard({
    super.key,
    required this.index,
    required this.rule,
    required this.onEdit,
    required this.onPreview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(allAvailableRolesProvider).value;
    final displayValue = _resolveConditionDisplay(context, roles);
    final statusColor = context.getStatusColor(rule.targetStatus.apiValue);

    return AdaptiveContextMenuWrapper<_RuleContextAction>(
      menuItems: [
        PopupMenuItem(
          value: _RuleContextAction.preview,
          child: Text(context.l10n.calLiveCardPreview),
        ),
        PopupMenuItem(
          value: _RuleContextAction.edit,
          child: Text(context.l10n.tooltipEdit),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _RuleContextAction.delete,
          child: Text(
            context.l10n.btnDelete,
            style: TextStyle(color: context.colorScheme.error),
          ),
        ),
      ],
      onSelected: _handleContextAction,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 0,
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        shape: context.outlinedCardShape,
        child: ListTile(
          onTap: onEdit,
          leading: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
          title: Text(
            '${rule.conditionType.toLocalizedString(context)} ${rule.operator.toLocalizedString(context)} "$displayValue"',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                EditorTagPill(
                  label: rule.targetStatus.toLocalizedString(context).toUpperCase(),
                  color: statusColor,
                  showBorder: true,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (rule.messageTemplate == null ||
                        rule.messageTemplate!.isEmpty)
                        ? context.l10n.statusRuleNoMessage
                        : rule.messageTemplate!,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          trailing: _RuleCardActions(
            onPreview: onPreview,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }

  void _handleContextAction(_RuleContextAction action) {
    switch (action) {
      case _RuleContextAction.preview:
        onPreview();
      case _RuleContextAction.edit:
        onEdit();
      case _RuleContextAction.delete:
        onDelete();
    }
  }

  String _resolveConditionDisplay(BuildContext context, List<Role>? roles) {
    if (rule.conditionType == ConditionType.friendPresent && roles != null) {
      final roleId = int.tryParse(rule.conditionValue);
      final role = roles.firstWhereOrNull((r) => r.id == roleId);
      if (role != null) return role.name;
    }
    if (rule.conditionType == ConditionType.instanceType) {
      final matched = InstanceAccessType.values.firstWhereOrNull(
            (type) => type.name == rule.conditionValue,
      );
      if (matched != null) return matched.toLocalizedString(context);
    }
    return rule.conditionValue;
  }
}

class _RuleCardActions extends StatelessWidget {
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RuleCardActions({
    required this.onPreview,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 18),
          onPressed: onPreview,
          tooltip: context.l10n.calLiveCardPreview,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: onEdit,
          tooltip: context.l10n.tooltipEdit,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: Icon(
            Icons.delete_sweep_outlined,
            color: context.colorScheme.error,
            size: 20,
          ),
          onPressed: onDelete,
          tooltip: context.l10n.tooltipRemoveRule,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _StatusRuleEditorDialog extends ConsumerStatefulWidget {
  final int priority;
  final StatusRule? initialRule;

  const _StatusRuleEditorDialog({required this.priority, this.initialRule});

  @override
  ConsumerState<_StatusRuleEditorDialog> createState() =>
      _StatusRuleEditorDialogState();
}

class _StatusRuleEditorDialogState
    extends ConsumerState<_StatusRuleEditorDialog> {
  late ConditionType _conditionType;
  late RuleOperator _operator;
  late StatusType _targetStatus;
  late final TextEditingController _valueController;
  late final TextEditingController _templateController;
  String? _selectedRoleDisplayName;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRule;
    _conditionType = initial?.conditionType ?? ConditionType.population;
    _operator = initial?.operator ?? _conditionType.allowedOperators.first;
    _targetStatus = initial?.targetStatus ?? StatusType.active;
    _valueController =
        TextEditingController(text: initial?.conditionValue ?? '');
    _templateController =
        TextEditingController(text: initial?.messageTemplate ?? '');

    if (_conditionType == ConditionType.friendPresent) {
      _resolveInitialRoleName(initial?.conditionValue);
    }
  }

  Future<void> _resolveInitialRoleName(String? rawRoleId) async {
    final roleId = int.tryParse(rawRoleId ?? '');
    if (roleId == null) return;

    final roles = await ref.read(allAvailableRolesProvider.future);
    final role = roles.firstWhereOrNull((r) => r.id == roleId);
    if (mounted && role != null) {
      setState(() => _selectedRoleDisplayName = role.name);
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _templateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialRule != null;

    return AlertDialog(
      title: Text(
        isEdit
            ? context.l10n.statusRuleEditorTitleEdit
            : context.l10n.statusRuleEditorTitleNew,
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConditionDropdown(context),
              const SizedBox(height: 12),
              _buildOperatorDropdown(context),
              const SizedBox(height: 12),
              _buildComparisonField(context),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildStatusDropdown(context),
              const SizedBox(height: 12),
              TextField(
                controller: _templateController,
                maxLength: 42,
                decoration: InputDecoration(
                  labelText: context.l10n.inputStatusMessageTemplate,
                  hintText: context.l10n.statusMessageTemplateHint,
                ),
              ),
              const SizedBox(height: 8),
              StatusTemplateHelperWidget(controller: _templateController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.btnCancel),
        ),
        FilledButton(
          onPressed: _submitRule,
          child: Text(
            isEdit ? context.l10n.btnSave : context.l10n.btnCreateRule,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionDropdown(BuildContext context) {
    return DropdownButtonFormField<ConditionType>(
      initialValue: _conditionType,
      decoration: InputDecoration(
        labelText: context.l10n.inputTriggerCondition,
      ),
      items: ConditionType.values
          .map(
            (type) => DropdownMenuItem(
          value: type,
          child: Text(type.toLocalizedString(context)),
        ),
      )
          .toList(),
      onChanged: _onConditionChanged,
    );
  }

  void _onConditionChanged(ConditionType? newType) {
    if (newType == null || newType == _conditionType) return;
    setState(() {
      _conditionType = newType;
      if (!_conditionType.allowedOperators.contains(_operator)) {
        _operator = _conditionType.allowedOperators.first;
      }
      _valueController.clear();
      _selectedRoleDisplayName = null;
      if (_conditionType == ConditionType.instanceType) {
        _valueController.text = InstanceAccessType.public.name;
      }
    });
  }

  Widget _buildOperatorDropdown(BuildContext context) {
    return DropdownButtonFormField<RuleOperator>(
      key: ValueKey('op_${_conditionType.name}_${_operator.name}'),
      initialValue: _operator,
      decoration: InputDecoration(labelText: context.l10n.inputOperator),
      items: _conditionType.allowedOperators
          .map(
            (op) => DropdownMenuItem(
          value: op,
          child: Text(op.toLocalizedString(context)),
        ),
      )
          .toList(),
      onChanged: (val) {
        if (val != null) setState(() => _operator = val);
      },
    );
  }

  Widget _buildComparisonField(BuildContext context) {
    if (_conditionType == ConditionType.instanceType) {
      return _buildInstanceAccessDropdown(context);
    }
    if (_conditionType == ConditionType.friendPresent) {
      return _buildRolePickerField(context);
    }

    return TextField(
      controller: _valueController,
      decoration: InputDecoration(
        labelText: context.l10n.inputComparisonValue,
        hintText: _resolveComparisonHint(context),
      ),
    );
  }

  Widget _buildInstanceAccessDropdown(BuildContext context) {
    final accessOptions = InstanceAccessType.values
        .where((t) => t != InstanceAccessType.unknown)
        .toList();
    final current = accessOptions.firstWhereOrNull(
          (t) => t.name == _valueController.text,
    ) ??
        InstanceAccessType.public;

    return DropdownButtonFormField<InstanceAccessType>(
      initialValue: current,
      decoration: InputDecoration(
        labelText: context.l10n.inputComparisonValue,
      ),
      items: accessOptions
          .map(
            (type) => DropdownMenuItem(
          value: type,
          child: Text(type.toLocalizedString(context)),
        ),
      )
          .toList(),
      onChanged: (val) {
        if (val != null) _valueController.text = val.name;
      },
    );
  }

  Widget _buildRolePickerField(BuildContext context) {
    return InkWell(
      onTap: () => _pickFriendRole(context),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.l10n.inputComparisonValue,
          suffixIcon: const Icon(Icons.search),
        ),
        child: Text(
          _selectedRoleDisplayName ??
              (_valueController.text.isNotEmpty
                  ? _valueController.text
                  : context.l10n.searchLocalRolesHint),
          style: TextStyle(
            color: _selectedRoleDisplayName != null
                ? context.colorScheme.onSurface
                : context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return DropdownButtonFormField<StatusType>(
      initialValue: _targetStatus,
      decoration: InputDecoration(labelText: context.l10n.inputTargetStatus),
      items: StatusType.values
          .map(
            (status) => DropdownMenuItem(
          value: status,
          child: Text(status.toLocalizedString(context)),
        ),
      )
          .toList(),
      onChanged: (val) {
        if (val != null) setState(() => _targetStatus = val);
      },
    );
  }

  Future<void> _pickFriendRole(BuildContext context) async {
    final roles = await ref.read(allAvailableRolesProvider.future);
    if (!context.mounted) return;

    showGenericSearchSheet<Role>(
      context: context,
      items: roles,
      searchHint: context.l10n.searchLocalRolesHint,
      searchableText: (role) => role.name,
      itemBuilder: (role) => ListTile(
        leading: Icon(Icons.label_outline, color: context.colorScheme.primary),
        title: Text(role.name),
      ),
      onSelected: (role) {
        if (role == null) return;
        setState(() {
          _valueController.text = role.id.toString();
          _selectedRoleDisplayName = role.name;
        });
        Navigator.pop(context);
      },
    );
  }

  String _resolveComparisonHint(BuildContext context) {
    if (_conditionType == ConditionType.batteryLevel ||
        _conditionType == ConditionType.population) {
      return _operator == RuleOperator.between
          ? context.l10n.statusRuleComparisonHintRange
          : context.l10n.statusRuleComparisonHintNumber;
    }
    if (_conditionType == ConditionType.timeRange) {
      return context.l10n.statusRuleComparisonHintTimeRange;
    }
    return context.l10n.statusRuleComparisonHintWorldList;
  }

  void _submitRule() {
    final value = _valueController.text.trim();
    if (value.isEmpty) return;

    final rule = StatusRule(
      id: widget.initialRule?.id,
      priority: widget.initialRule?.priority ?? widget.priority,
      targetStatus: _targetStatus,
      messageTemplate: _templateController.text.trim(),
      conditionType: _conditionType,
      operator: _operator,
      conditionValue: value,
    );
    Navigator.pop(context, rule);
  }
}
