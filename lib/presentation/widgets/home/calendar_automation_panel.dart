import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/presentation/extensions/enum_extensions.dart';
import 'package:vrcma/presentation/state/calendar_automation_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/adaptive_context_menu_wrapper.dart';
import 'package:vrcma/presentation/widgets/home/dashboard_panel.dart';
import 'package:vrcma/presentation/widgets/home/window/calendar_automation_editor_sheet.dart';

class CalendarAutomationPanel extends ConsumerWidget {
  const CalendarAutomationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(calendarAutomationListProvider);

    return rulesAsync.when(
      data: (rules) {
        if (rules.isEmpty) {
          return _buildEmptyState(context, ref);
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rules.length + 1,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280,
            mainAxisExtent: 140,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, i) {
            if (i == rules.length) {
              return _buildAddCard(context);
            }
            final rule = rules[i];
            return AdaptiveContextMenuWrapper<DashboardContextAction>(
              menuItems: [
                PopupMenuItem(
                  value: DashboardContextAction.toggle,
                  child: Text(rule.isActive ? context.l10n.contextMenuDeactivate : context.l10n.contextMenuActivate),
                ),
                PopupMenuItem(
                  value: DashboardContextAction.edit,
                  child: Text(context.l10n.contextMenuEdit),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: DashboardContextAction.delete,
                  child: Text(context.l10n.btnDelete, style: TextStyle(color: context.colorScheme.error)),
                ),
              ],
              onSelected: (action) {
                switch (action) {
                  case DashboardContextAction.toggle:
                    ref.read(calendarAutomationListProvider.notifier).toggleActive(rule);
                    break;
                  
                  case DashboardContextAction.edit:
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarAutomationEditorSheet(rule: rule)));
                    break;
                  
                  case DashboardContextAction.delete:
                    _confirmDelete(context, ref, rule);
                    break;
                }
              },
              child: _buildRuleCard(context, ref, rule),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(context.l10n.stateError(err.toString()))),
    );
  }

  Widget _buildRuleCard(BuildContext context, WidgetRef ref, CalendarAutomationRule rule) {
    final activeBg = context.vrcColors.success.withValues(alpha: 0.08);
    final activeBorder = context.vrcColors.success.withValues(alpha: 0.4);

    return InkWell(
      onTap: () {
        ref.read(calendarAutomationListProvider.notifier).toggleActive(rule);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: rule.isActive ? activeBg : context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rule.isActive ? activeBorder : context.colorScheme.outlineVariant,
            width: rule.isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  rule.isActive ? Icons.check_circle : Icons.radio_button_off,
                  color:  rule.isActive ? context.vrcColors.success : context.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.tune_outlined, size: 18),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CalendarAutomationEditorSheet(rule: rule)),
                    );
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Spacer(),
            Text(
              rule.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              '${rule.schedule.startTimeOfDay} (${rule.recurrence.type.toLocalizedString(context)})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return InkWell(
      onTap: () => _openEditor(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colorScheme.outlineVariant,
            style: BorderStyle.solid
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, color: context.colorScheme.primary, size: 28),
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

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
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
          Icon(Icons.calendar_month_outlined, size: 32, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(context.l10n.calMsgEmptyRules, style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _openEditor(context),
            child: Text(context.l10n.calBtnCreate),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalendarAutomationEditorSheet()),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CalendarAutomationRule rule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.calConfirmDeleteTitle),
        content: Text(context.l10n.calConfirmDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.btnCancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(calendarAutomationListProvider.notifier).delete(rule.id!);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            child: Text(context.l10n.btnDelete),
          ),
        ],
      ),
    );
  }
}