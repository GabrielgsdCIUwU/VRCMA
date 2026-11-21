import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/error/domain_exception.dart';
import 'package:vrcma/presentation/extensions/enum_extensions.dart';
import 'package:vrcma/presentation/extensions/error_extensions.dart';
import 'package:vrcma/presentation/services/snackbar_service.dart';
import 'package:vrcma/presentation/state/calendar_automation_provider.dart';
import 'package:vrcma/presentation/state/calendar_scheduler_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/adaptive_context_menu_wrapper.dart';
import 'package:vrcma/presentation/widgets/home/common/adaptive_dialogs.dart';
import 'package:vrcma/presentation/widgets/home/dashboard_panel.dart';
import 'package:vrcma/presentation/widgets/home/window/calendar_automation_editor_sheet.dart';

/// Displays configured calendar automation rules and provides manual sync controls.
class CalendarAutomationPanel extends ConsumerWidget {
  const CalendarAutomationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(calendarAutomationListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CalendarActionToolbar(),
        const SizedBox(height: 12),
        rulesAsync.when(
          data: (rules) => _RulesContent(rules: rules),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) =>
              Center(child: Text(context.l10n.stateError(err.toString()))),
        ),
      ],
    );
  }
}

class _CalendarActionToolbar extends ConsumerWidget {
  const _CalendarActionToolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(calendarSchedulerProvider);

    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.calSubheader,
            style: TextStyle(
              fontSize: 12,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.tonalIcon(
          onPressed: isSyncing
              ? null
              : () => ref.read(calendarSchedulerProvider.notifier).evaluateNow(),
          icon: isSyncing
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.sync, size: 18),
          label: Text(context.l10n.calBtnSyncNow),
        ),
      ],
    );
  }
}

class _RulesContent extends StatelessWidget {
  final List<CalendarAutomationRule> rules;

  const _RulesContent({required this.rules});

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return const _EmptyRulesState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rules.length + 1,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 148,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        if (index == rules.length) return const _AddRuleCard();
        return _RuleGridItem(rule: rules[index]);
      },
    );
  }
}

class _RuleGridItem extends ConsumerWidget {
  final CalendarAutomationRule rule;

  const _RuleGridItem({required this.rule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveContextMenuWrapper<DashboardContextAction>(
      menuItems: _buildMenuItems(context),
      onSelected: (action) => _handleAction(context, ref, action),
      child: _RuleCard(
        rule: rule,
        onToggle: () => _toggleRule(context, ref),
        onEdit: () => _openEditor(context),
      ),
    );
  }

  List<PopupMenuEntry<DashboardContextAction>> _buildMenuItems(
      BuildContext context,
      ) {
    return [
      PopupMenuItem(
        value: DashboardContextAction.toggle,
        child: Text(
          rule.isActive
              ? context.l10n.contextMenuDeactivate
              : context.l10n.contextMenuActivate,
        ),
      ),
      PopupMenuItem(
        value: DashboardContextAction.edit,
        child: Text(context.l10n.contextMenuEdit),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: DashboardContextAction.delete,
        child: Text(
          context.l10n.btnDelete,
          style: TextStyle(color: context.colorScheme.error),
        ),
      ),
    ];
  }

  Future<void> _handleAction(
      BuildContext context,
      WidgetRef ref,
      DashboardContextAction action,
      ) async {
    switch (action) {
      case DashboardContextAction.toggle:
        await _toggleRule(context, ref);
      case DashboardContextAction.edit:
        _openEditor(context);
      case DashboardContextAction.delete:
        await _confirmDelete(context, ref);
    }
  }

  Future<void> _toggleRule(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(calendarAutomationListProvider.notifier).toggleActive(rule);
    } on DomainException catch (error) {
      if (context.mounted) {
        ref.read(snackbarServiceProvider).show(error.toLocalizedString(context));
      }
    }
  }

  void _openEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarAutomationEditorSheet(rule: rule),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await AdaptiveDialogs.showDeleteConfirmation(
      context: context,
      title: context.l10n.calConfirmDeleteTitle,
      content: context.l10n.calConfirmDeleteContent,
    );

    if (confirmed && rule.id != null) {
      await ref.read(calendarAutomationListProvider.notifier).delete(rule.id!);
    }
  }
}

class _RuleCard extends StatelessWidget {
  final CalendarAutomationRule rule;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _RuleCard({
    required this.rule,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = context.vrcColors.success.withValues(alpha: 0.08);
    final activeBorder = context.vrcColors.success.withValues(alpha: 0.4);
    final counterSuffix = rule.incrementalConfig.isEnabled
        ? ' • #${rule.incrementalConfig.currentValue}'
        : '';

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: rule.isActive
              ? activeBg
              : context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rule.isActive
                ? activeBorder
                : context.colorScheme.outlineVariant,
            width: rule.isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RuleCardHeader(isActive: rule.isActive, onEdit: onEdit),
            const Spacer(),
            Text(
              rule.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              '${rule.schedule.startTime.formatted} (${rule.recurrence.type.toLocalizedString(context)})$counterSuffix',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleCardHeader extends StatelessWidget {
  final bool isActive;
  final VoidCallback onEdit;

  const _RuleCardHeader({required this.isActive, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.radio_button_off,
          color: isActive
              ? context.vrcColors.success
              : context.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.tune_outlined, size: 18),
          onPressed: onEdit,
          visualDensity: VisualDensity.compact,
          tooltip: context.l10n.tooltipEdit,
        ),
      ],
    );
  }
}

class _AddRuleCard extends StatelessWidget {
  const _AddRuleCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openNewEditor(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: context.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.btnCreate.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRulesState extends StatelessWidget {
  const _EmptyRulesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 32,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.calMsgEmptyRules,
            style: TextStyle(color: context.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _openNewEditor(context),
            child: Text(context.l10n.calBtnCreate),
          ),
        ],
      ),
    );
  }
}

void _openNewEditor(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CalendarAutomationEditorSheet()),
  );
}