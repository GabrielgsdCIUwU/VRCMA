import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/presentation/state/status_profile_editor_provider.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';

class StatusProfileEditorSheet extends ConsumerStatefulWidget {
  final StatusProfile profile;
  const StatusProfileEditorSheet({super.key, required this.profile});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StatusProfileEditorSheetState();
}

class _StatusProfileEditorSheetState
    extends ConsumerState<StatusProfileEditorSheet> {
  late TextEditingController _nameController;
  late TextEditingController _fallbackTemplateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _fallbackTemplateController = TextEditingController(
      text: widget.profile.fallbackTemplate ?? "",
    );
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

  Future<bool> _showExitConfirmation() async {
    final hasChanges = ref
        .read(statusProfileEditorProvider(widget.profile).notifier)
        .hasChanges;
    if (!hasChanges) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.dialogUnsavedTitle),
        content: Text(context.l10n.dialogUnsavedContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text(
              context.l10n.btnDiscard,
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: Text(context.l10n.btnSaveChanges),
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
    final currentProfile = ref.watch(
      statusProfileEditorProvider(widget.profile),
    );
    final hasChanges = ref
        .read(statusProfileEditorProvider(widget.profile).notifier)
        .hasChanges;

    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (dipPop, result) async {
        if (dipPop) return;
        final shouldPop = await _showExitConfirmation();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.editStatusProfileTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: Text(context.l10n.btnSave),
                style: FilledButton.styleFrom(
                  backgroundColor: hasChanges
                      ? context.vrcColors.success
                      : null,
                  foregroundColor: hasChanges
                      ? context.colorScheme.onPrimary
                      : context.colorScheme.onSurfaceVariant,
                ),
                onPressed: hasChanges ? _saveAndExit : null,
              ),
            ),
          ],
        ),
        body: ResponsiveLayout(
          mobile: _buildMobileLayout(currentProfile),
          desktop: _buildDesktopLayout(currentProfile),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(StatusProfile currentProfile) {
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
              Text(
                context.l10n.sectionGeneralSettings.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.2,
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 24),
              _buildFallbackStatusSelector(currentProfile),
              const SizedBox(height: 24),
              _buildFallbackTemplateField(),
              const Spacer(),
              Icon(
                Icons.info_outline,
                color: context.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.statusPriorityRulesCaption,
                style: const TextStyle(fontSize: 11),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.sectionAutomationConditions.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.2,
                        color: context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.btnAddConditionRule),
                      onPressed: () => _showAddRuleDialog(currentProfile),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildRulesList(currentProfile)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(StatusProfile currentProfile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [_buildNameField()],
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: context.l10n.inputStatusProfileName,
        prefixIcon: const Icon(Icons.badge_outlined),
      ),
      onChanged: (val) => ref
          .read(statusProfileEditorProvider(widget.profile).notifier)
          .updateName(val),
    );
  }

  Widget _buildFallbackStatusSelector(StatusProfile currentProfile) {
    return DropdownButtonFormField<StatusType>(
      initialValue: currentProfile.fallbackStatus,
      decoration: InputDecoration(
        labelText: context.l10n.inputFallbackStatus,
        prefixIcon: const Icon(Icons.lens),
      ),
      items: StatusType.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          ref
              .read(statusProfileEditorProvider(widget.profile).notifier)
              .updateFallbackStatus(val);
        }
      },
    );
  }

  Widget _buildFallbackTemplateField() {
    return TextField(
      controller: _fallbackTemplateController,
      maxLength: 42,
      decoration: InputDecoration(
        labelText: context.l10n.inputFallbackTemplate,
        prefixIcon: const Icon(Icons.short_text),
      ),
      onChanged: (val) => ref
          .read(statusProfileEditorProvider(widget.profile).notifier)
          .updateFallbackTemplate(val),
    );
  }

  Widget _buildRulesList(StatusProfile currentProfile) {
    if (currentProfile.rules.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noStatusRulesAdded,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: currentProfile.rules.length,
      onReorderItem: (oldIndex, newIndex) {
        ref
            .read(statusProfileEditorProvider(widget.profile).notifier)
            .reorderRules(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final rule = currentProfile.rules[index];
        return _buildRuleCard(index, rule);
      },
    );
  }

  Widget _buildRuleCard(int index, StatusRule rule) {
    return Card(
      key: ValueKey("status_rule${rule.priority}_${rule.conditionType.name}"),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: context.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Text(
          "${rule.conditionType.name.toUpperCase()} ${rule.operator.name} '${rule.conditionValue}'",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _StatusBadge(status: rule.targetStatus),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rule.messageTemplate ?? context.l10n.statusRuleNoMessage,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_sweep_outlined,
            color: context.colorScheme.error,
          ),
          onPressed: () => ref
              .read(statusProfileEditorProvider(widget.profile).notifier)
              .removeRule(index),
        ),
      ),
    );
  }

  void _showAddRuleDialog(StatusProfile currentProfile) {
    ConditionType conditionType = ConditionType.population;
    RuleOperator ruleOperator = RuleOperator.greaterThan;
    StatusType targetStatus = StatusType.active;
    final valueController = TextEditingController();
    final templateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.dialogNewStatusRuleTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<ConditionType>(
                      initialValue: conditionType,
                      decoration: InputDecoration(
                        labelText: context.l10n.inputTriggerCondition,
                      ),
                      items: ConditionType.values.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            conditionType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<RuleOperator>(
                      initialValue: ruleOperator,
                      decoration: InputDecoration(
                        labelText: context.l10n.inputOperator,
                      ),
                      items: RuleOperator.values.map((o) {
                        return DropdownMenuItem(
                          value: o,
                          child: Text(o.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            ruleOperator = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: valueController,
                      decoration: InputDecoration(
                        labelText: context.l10n.inputComparisonValue,
                        hintText: context.l10n.statusRuleComparisonHint,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<StatusType>(
                      initialValue: targetStatus,
                      decoration: InputDecoration(
                        labelText: context.l10n.inputTargetStatus,
                      ),
                      items: StatusType.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            targetStatus = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: templateController,
                      maxLength: 42,
                      decoration: InputDecoration(
                        labelText: context.l10n.inputStatusMessageTemplate,
                        hintText: context.l10n.statusMessageTemplateHint,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.btnCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final value = valueController.text.trim();
                    if (value.isNotEmpty) {
                      ref
                          .read(
                            statusProfileEditorProvider(
                              widget.profile,
                            ).notifier,
                          )
                          .addRule(
                            StatusRule(
                              priority: currentProfile.rules.length,
                              targetStatus: targetStatus,
                              messageTemplate: templateController.text.trim(),
                              conditionType: conditionType,
                              operator: ruleOperator,
                              conditionValue: value,
                            ),
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(context.l10n.btnCreateRule),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StatusType status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case StatusType.active:
        color = context.vrcColors.statusOnline;
        break;
      case StatusType.joinMe:
        color = context.vrcColors.statusJoinMe;
        break;
      case StatusType.askMe:
        color = context.vrcColors.statusAskMe;
        break;
      case StatusType.busy:
        color = context.vrcColors.statusBusy;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
