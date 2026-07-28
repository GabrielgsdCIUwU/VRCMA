import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_exception.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/calendar_event_platform.dart';
import 'package:vrcma/domain/entities/calendar/enums/creation_strategy.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/social/vrc_group.dart';
import 'package:vrcma/presentation/extensions/date_time_extensions.dart';
import 'package:vrcma/presentation/extensions/enum_extensions.dart';
import 'package:vrcma/presentation/services/snackbar_service.dart';
import 'package:vrcma/presentation/state/calendar_automation_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/common/show_generic_search_sheet.dart';

class CalendarAutomationEditorSheet extends ConsumerStatefulWidget {
  final CalendarAutomationRule? rule;
  const CalendarAutomationEditorSheet({super.key, this.rule});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarAutomationEditorSheetState();
}

class _CalendarAutomationEditorSheetState extends ConsumerState<CalendarAutomationEditorSheet> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final initialRule = ref.read(calendarAutomationEditorProvider(widget.rule));
    _nameController = TextEditingController(text: initialRule.name);
    _titleController = TextEditingController(text: initialRule.titleTemplate);
    _descriptionController = TextEditingController(text: initialRule.descriptionTemplate ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveAndExit() {
    final notifier = ref.read(calendarAutomationEditorProvider(widget.rule).notifier);
    if (notifier.isValid) {
      notifier.saveAndClose();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.calToastSaved)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarAutomationEditorProvider(widget.rule));
    final notifier = ref.read(calendarAutomationEditorProvider(widget.rule).notifier);

    return PopScope(
      canPop: !notifier.hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await _showDiscardConfirmation();
        if (discard && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.rule == null ? context.l10n.calEditorTitleNew : context.l10n.calEditorTitleEdit),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: Text(context.l10n.btnSave),
                style: FilledButton.styleFrom(
                  backgroundColor: notifier.isValid && notifier.hasChanges ? context.vrcColors.success : null,
                ),
                onPressed: notifier.isValid && notifier.hasChanges ? _saveAndExit : null,
              ),
            ),
          ],
        ),
        body: ResponsiveLayout(
          mobile: _buildFormContentMobile(state, notifier),
          desktop: _buildFormContentDesktop(state, notifier),
        ),
      ),
    );
  }

  Widget _buildFormContentMobile(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftPane(state, notifier),
          const SizedBox(height: 16),
          _LiveTemplatePreview(state: state),
          const Divider(height: 32),
          _buildRightPane(state, notifier),
        ],
      ),
    );
  }

  Widget _buildFormContentDesktop(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
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
                _buildLeftPane(state, notifier),
                const SizedBox(height: 24),
                _LiveTemplatePreview(state: state),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildRightPane(state, notifier),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftPane(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    final bool isIncrementalEnabled = state.incrementalConfig.isEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context.l10n.sectionGeneralSettings),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: context.l10n.calFieldLabelName,
            prefixIcon: const Icon(Icons.drive_file_rename_outline),
          ),
          onChanged: notifier.updateName,
        ),
        const SizedBox(height: 16),
        _buildGroupSelector(state, notifier),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: context.l10n.calFieldLabelTitle,
            hintText: context.l10n.calFieldHintTitle,
            prefixIcon: const Icon(Icons.title),
          ),
          onChanged: notifier.updateTitleTemplate,
        ),
        if (isIncrementalEnabled) ...[
          const SizedBox(height: 6),
          _buildInsertPlaceholderChip(_titleController, notifier.updateTitleTemplate),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.l10n.calFieldLabelDesc,
            prefixIcon: const Icon(Icons.description_outlined),
          ),
          onChanged: (val) => notifier.updateDescriptionTemplate(val.isEmpty ? null : val),
        ),
        if (isIncrementalEnabled) ...[
          const SizedBox(height: 6),
          _buildInsertPlaceholderChip(_descriptionController, (val) => notifier.updateDescriptionTemplate(val.isEmpty ? null : val)),
        ],
      ],
    );
  }

  Widget _buildGroupSelector(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    final permittedGroupsAsync = ref.watch(userGroupsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.calFieldLabelGroupId, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        permittedGroupsAsync.when(
          data: (groups) {
            final selectedGroup = groups.firstWhereOrNull((g) => g.id == state.groupId);

            return InkWell(
              onTap: () => _showGroupSelectionDialog(groups, notifier),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                  color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                child: Row(
                  children: [
                    Icon(Icons.group_outlined, color: context.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedGroup != null
                            ? "${selectedGroup.name} (${selectedGroup.shortCode})"
                            : (state.groupId.isNotEmpty ? state.groupId : context.l10n.calGroupSelectHint),
                        style: TextStyle(
                          color: selectedGroup != null || state.groupId.isNotEmpty
                              ? context.colorScheme.onSurface
                              : context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: context.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (err, _) => Text(context.l10n.stateError(err.toString())),
        ),
      ],
    );
  }

  void _showGroupSelectionDialog(List<VrcGroup> groups, CalendarAutomationEditor notifier) {
    if (groups.isEmpty) {
      ref.read(snackbarServiceProvider).show(context.l10n.calGroupNoPerms);
      return;
    }

    showGenericSearchSheet<VrcGroup>(
      context: context,
      items: groups,
      searchHint: context.l10n.calGroupSelectHint,
      searchableText: (group) => "${group.name} ${group.shortCode} ${group.id}",
      itemBuilder: (group) => ListTile(
        leading: Icon(Icons.group, color: context.colorScheme.primary),
        title: Text(group.name),
        subtitle: Text(group.shortCode, style: const TextStyle(fontSize: 12)),
      ),
      onSelected: (group) => _handleGroupSelection(group, notifier),
    );
  }
  
  Future<void> _handleGroupSelection(VrcGroup? group, CalendarAutomationEditor notifier) async {
    if (group == null) return;
    
    Navigator.pop(context);

    ref.read(snackbarServiceProvider).show(context.l10n.calGroupValidating);
    
    final hasPermission = await notifier.validateAndSetGroup(group.id);
    
    if (!mounted) return;
    
    if (!hasPermission) {
      ref.read(snackbarServiceProvider).show(context.l10n.calGroupPermissionDenied);
    }
    
  }

  Widget _buildInsertPlaceholderChip(TextEditingController controller, ValueChanged<String> onChanged) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ActionChip(
        avatar: const Icon(Icons.add, size: 14),
        label: const Text("{{incremental}}", style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
        onPressed: () {
          final text = controller.text;
          final selection = controller.selection;
          const tag = "{{incremental}}";

          if (selection.isValid && selection.start >= 0) {
            final newText = text.replaceRange(selection.start, selection.end, tag);
            controller.text = newText;
            controller.selection = TextSelection.collapsed(offset: selection.start + tag.length);
          } else {
            controller.text = text + tag;
          }
          onChanged(controller.text);
        },
      ),
    );
  }

  Widget _buildRightPane(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context.l10n.calSectionSchedule),
        const SizedBox(height: 16),
        _buildSchedulerInteractiveCard(state, notifier),
        const SizedBox(height: 24),
        _buildSectionHeader(context.l10n.calSectionRecurrence),
        const SizedBox(height: 16),
        _buildRecurrenceSelectorCard(state, notifier),
        const SizedBox(height: 24),
        _buildSectionHeader(context.l10n.calSectionStrategy),
        const SizedBox(height: 16),
        _buildStrategyCard(state, notifier),
        const SizedBox(height: 24),
        _buildSectionHeader(context.l10n.calSectionIncremental),
        const SizedBox(height: 16),
        _buildIncrementalConfigCard(state, notifier),
        const SizedBox(height: 24),
        _buildSectionHeader(
          context.l10n.calSectionExceptions,
          trailing: TextButton.icon(
            onPressed: () async {
              final initialDate = DateTime.now();
              final maxDate = initialDate.add(const Duration(days: 365));

              final dateRange = await showDateRangePicker(
                context: context,
                firstDate: initialDate,
                lastDate: maxDate,
                builder: (context, child) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
                      child: child,
                    ),
                  );
                },
              );

              if (dateRange != null) {
                notifier.addException(CalendarException(
                  exceptionDate: dateRange.start,
                  exceptionEndDate: dateRange.end != dateRange.start ? dateRange.end : null,
                  isCancelled: true,
                ));
              }
            },
            icon: const Icon(Icons.add, size: 16),
            label: Text(context.l10n.calExceptionAdd),
          ),
        ),
        const SizedBox(height: 16),
        _buildExceptionsCard(state, notifier),
        const SizedBox(height: 24),
        _buildSectionHeader(context.l10n.calSectionTolerances),
        const SizedBox(height: 16),
        _buildTolerancesCard(state, notifier),
        const SizedBox(height: 24),
        _buildSectionHeader(context.l10n.calSectionVrcMetadata),
        const SizedBox(height: 16),
        _buildVrcMetadataCard(state, notifier),
      ],
    );
  }

  Widget _buildIncrementalConfigCard(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    final config = state.incrementalConfig;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.calFieldLabelIncrementalEnable, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(context.l10n.calFieldLabelIncrementalDesc, style: const TextStyle(fontSize: 11)),
              value: config.isEnabled,
              onChanged: (val) {
                notifier.updateIncrementalConfig(IncrementalConfig(
                  isEnabled: val,
                  startValue: config.startValue,
                  stepValue: config.stepValue,
                  currentValue: config.currentValue,
                ));
              },
            ),
            if (config.isEnabled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: config.startValue.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.calFieldLabelIncrementalStart,
                        isDense: true,
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val) ?? 1;
                        notifier.updateIncrementalConfig(IncrementalConfig(
                          isEnabled: true,
                          startValue: parsed,
                          stepValue: config.stepValue,
                          currentValue: parsed,
                        ));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: config.stepValue.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.calFieldLabelIncrementalStep,
                        isDense: true,
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val) ?? 1;
                        notifier.updateIncrementalConfig(IncrementalConfig(
                          isEnabled: true,
                          startValue: config.startValue,
                          stepValue: parsed,
                          currentValue: config.currentValue,
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTolerancesCard(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.calFieldLabelOverflow, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(context.l10n.calFieldLabelOverflowDesc, style: const TextStyle(fontSize: 11)),
              value: state.usesInstanceOverflow,
              onChanged: (_) => notifier.toggleInstanceOverflow(),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: state.hostEarlyJoinMinutes?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l10n.calFieldLabelHostEarlyShort,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      notifier.updateTolerances(
                        hostMinutes: int.tryParse(val),
                        guestMinutes: state.guestEarlyJoinMinutes,
                        closeMinutes: state.closeInstanceAfterEndMinutes,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: state.guestEarlyJoinMinutes?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l10n.calFieldLabelGuestEarlyShort,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      notifier.updateTolerances(
                        hostMinutes: state.hostEarlyJoinMinutes,
                        guestMinutes: int.tryParse(val),
                        closeMinutes: state.closeInstanceAfterEndMinutes,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: state.closeInstanceAfterEndMinutes?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l10n.calFieldLabelCloseDelayShort,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      notifier.updateTolerances(
                        hostMinutes: state.hostEarlyJoinMinutes,
                        guestMinutes: state.guestEarlyJoinMinutes,
                        closeMinutes: int.tryParse(val),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildExplanationRow(
                Icons.vpn_key_outlined,
                context.l10n.calToleranceHostTitle,
                context.l10n.calToleranceHostDesc
            ),
            const SizedBox(height: 6),
            _buildExplanationRow(
                Icons.people_outline,
                context.l10n.calToleranceMemberTitle,
                context.l10n.calToleranceMemberDesc
            ),
            const SizedBox(height: 6),
            _buildExplanationRow(
                Icons.hourglass_empty_outlined,
                context.l10n.calToleranceCloseTitle,
                context.l10n.calToleranceCloseDesc
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationRow(IconData icon, String title, String explanation) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
              children: [
                TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: explanation, style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: context.colorScheme.primary
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildSchedulerInteractiveCard(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    final endTime = _calculateEndTime(state.schedule.startTimeOfDay, state.schedule.durationMinutes);
    final formattedEndTime = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 365));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: Text(context.l10n.calFieldLabelTime),
            subtitle: Text(state.schedule.startTimeOfDay, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _selectTime(state, notifier, isStartTime: true),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(context.l10n.calFieldLabelStartDate),
            subtitle: Text(
              state.schedule.startDate != null
                  ? DateFormat.yMd(locale).format(state.schedule.startDate!)
                  : context.l10n.calOptionalDate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.edit_calendar_outlined, size: 20),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.schedule.startDate ?? now,
                firstDate: now.subtract(const Duration(days: 1)),
                lastDate: maxDate,
              );
              if (date != null) notifier.updateStartDate(date);
            },
            onLongPress: () => notifier.updateStartDate(null),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.event_busy_outlined),
            title: Text(context.l10n.calFieldLabelEndDate),
            subtitle: Text(
              state.schedule.endDate != null
                  ? DateFormat.yMd(locale).format(state.schedule.endDate!)
                  : context.l10n.calOptionalDate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.edit_calendar_outlined, size: 20),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.schedule.endDate ?? (state.schedule.startDate ?? now),
                firstDate: state.schedule.startDate ?? now.subtract(const Duration(days: 1)),
                lastDate: maxDate,
              );
              if (date != null) notifier.updateEndDate(date);
            },
            onLongPress: () => notifier.updateEndDate(null),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.stop_circle_outlined),
            title: Text(context.l10n.calFieldLabelEndTime),
            subtitle: Text(formattedEndTime, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _selectTime(state, notifier, isStartTime: false),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(context.l10n.calFieldLabelDuration),
            subtitle: Text(_formatDuration(context, state.schedule.durationMinutes), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyCard(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<CreationStrategy>(
              initialValue: state.strategy,
              decoration: InputDecoration(
                labelText: context.l10n.calFieldLabelStrategy,
                prefixIcon: const Icon(Icons.auto_awesome_motion),
              ),
              items: CreationStrategy.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.toLocalizedString(context)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) notifier.updateStrategy(val);
              },
            ),
            if (state.strategy == CreationStrategy.batch) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: state.maxVisibleFutureEvents.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.calFieldLabelMaxEvents,
                  prefixIcon: const Icon(Icons.format_list_numbered),
                  isDense: true,
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val) ?? 1;
                  notifier.updateMaxVisibleFutureEvents(parsed.clamp(1, 10));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceSelectorCard(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<RecurrenceType>(
              initialValue: state.recurrence.type,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.repeat)),
              items: RecurrenceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toLocalizedString(context)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  notifier.updateRecurrence(RecurrencePattern(
                    type: val,
                    daysOfWeek: val == RecurrenceType.weekly ? [5] : const [],
                    daysOfMonth: val == RecurrenceType.monthly ? [1] : const [],
                  ));
                }
              },
            ),
            if (state.recurrence.type == RecurrenceType.weekly) ...[
              const SizedBox(height: 16),
              _buildDaysOfWeekSelector(state, notifier),
            ] else if (state.recurrence.type == RecurrenceType.monthly) ...[
              const SizedBox(height: 16),
              _buildDaysOfMonthSelector(state, notifier),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDaysOfMonthSelector(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.calDaysOfMonth, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(31, (index) {
            final dayNumber = index + 1;
            final isSelected = state.recurrence.daysOfMonth.contains(dayNumber);
            return GestureDetector(
              onTap: () {
                final List<int> updatedDays = List.from(state.recurrence.daysOfMonth);
                if (isSelected) {
                  if (updatedDays.length > 1) updatedDays.remove(dayNumber);
                } else {
                  updatedDays.add(dayNumber);
                }
                notifier.updateRecurrence(RecurrencePattern(
                  type: state.recurrence.type,
                  daysOfWeek: state.recurrence.daysOfWeek,
                  daysOfMonth: updatedDays,
                ));
              },
              child: CircleAvatar(
                radius: 14,
                backgroundColor: isSelected ? context.colorScheme.primary : context.colorScheme.surfaceContainerHighest,
                child: Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildExceptionsCard(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    if (state.exceptions.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              context.l10n.calExceptionsEmpty,
              style: TextStyle(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    final locale = Localizations.localeOf(context).languageCode;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.exceptions.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final exception = state.exceptions[index];
          final dateStr = DateFormat.yMd(locale).format(exception.exceptionDate);

          final endDateStr = exception.exceptionEndDate != null
              ? context.l10n.calExceptionUntil(DateFormat.yMd(locale).format(exception.exceptionEndDate!))
              : "";

          return ListTile(
            leading: Icon(Icons.event_busy, color: context.colorScheme.error),
            title: Text(context.l10n.calExceptionCancel),
            subtitle: Text("$dateStr$endDateStr"),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => notifier.removeException(exception),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaysOfWeekSelector(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final isSelected = state.recurrence.daysOfWeek.contains(dayNumber);
        final localizedDayLabel = dayNumber.toLocalizedWeekdayName(context);

        return GestureDetector(
          onTap: () {
            final List<int> updatedDays = List.from(state.recurrence.daysOfWeek);
            if (isSelected) {
              if (updatedDays.length > 1) updatedDays.remove(dayNumber);
            } else {
              updatedDays.add(dayNumber);
            }
            notifier.updateRecurrence(RecurrencePattern(
              type: state.recurrence.type,
              daysOfWeek: updatedDays,
            ));
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: isSelected ? context.colorScheme.primary : context.colorScheme.surfaceContainerHighest,
            child: Text(
              localizedDayLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVrcMetadataCard(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    final accessIcon = state.accessType == GroupEventAccessType.public
        ? Icons.lock_open_outlined
        : Icons.lock_outlined;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<GroupEventCategory>(
            initialValue: state.category,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
            items: GroupEventCategory.values.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat.toLocalizedString(context)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) notifier.updateCategory(val); 
            },
          ),
          const Divider(height: 1),
          DropdownButtonFormField<GroupEventAccessType>(
            key: ValueKey("access_type_${state.accessType.name}"),
            initialValue: state.accessType,
            decoration: InputDecoration(
              prefixIcon: Icon(accessIcon, color: context.colorScheme.primary),
              helperText: state.accessType == GroupEventAccessType.public
                  ? context.l10n.calAccessPublicDesc
                  : context.l10n.calAccessGroupDesc,
            ),
            items: GroupEventAccessType.values.map((access) {
              return DropdownMenuItem(
                value: access,
                child: Text(access.toLocalizedString(context)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) notifier.updateAccessType(val);
            },
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.calFieldLabelPlatform.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.calPlatformDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: context.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: CalendarEventPlatform.values.map((platform) {
                    final isSelected = state.platforms.contains(platform);
                    return ChoiceChip(
                      label: Text(platform.name.toUpperCase(), style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      onSelected: (_) => notifier.togglePlatform(platform),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(CalendarAutomationRule state, CalendarAutomationEditor notifier, {required bool isStartTime}) async {
    final TimeOfDay initialTime;

    if (isStartTime) {
      final rawTime = state.schedule.startTimeOfDay.split(':');
      final hour = int.tryParse(rawTime[0]) ?? 20;
      final minute = int.tryParse(rawTime[1]) ?? 0;
      initialTime = TimeOfDay(hour: hour, minute: minute);
    } else {
      initialTime = _calculateEndTime(state.schedule.startTimeOfDay, state.schedule.durationMinutes);
    }

    final selected = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selected != null) {
      if (isStartTime) {
        final formatted = '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
        notifier.updateTime(formatted);
      } else {
        final newDuration = _calculateDuration(state.schedule.startTimeOfDay, selected);
        notifier.updateDuration(newDuration);
      }
    }
  }

  String _formatDuration(BuildContext context, int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return context.l10n.calDurationHoursMinutes(hours, minutes);
    }
    return context.l10n.calDurationMinutesOnly(minutes);
  }

  TimeOfDay _calculateEndTime(String startTimeStr, int durationMinutes) {
    final parts = startTimeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 20;
    final minute = int.tryParse(parts[1]) ?? 0;
    
    final startDateTime = DateTime(2024, 1, 1, hour, minute);
    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
    
    return TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);
  }

  int _calculateDuration(String startTimeStr, TimeOfDay endTime) {
    final parts = startTimeStr.split(':');
    final startHour = int.tryParse(parts[0]) ?? 20;
    final startMinute = int.tryParse(parts[1]) ?? 0;
    
    final startDateTime = DateTime(2024, 1, 1, startHour, startMinute);
    var endDateTime = DateTime(2024, 1, 1, endTime.hour, endTime.minute);
    
    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }
    
    return endDateTime.difference(startDateTime).inMinutes;
  }

  Future<bool> _showDiscardConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.dialogUnsavedTitle),
        content: Text(context.l10n.dialogUnsavedContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.btnDiscard, style: TextStyle(color: context.colorScheme.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.btnSaveChanges),
          ),
        ],
      )
    );
    return result ?? false;
  }
}

class _LiveTemplatePreview extends StatelessWidget {
  final CalendarAutomationRule state;

  const _LiveTemplatePreview({required this.state});

  @override
  Widget build(BuildContext context) {
    final bool isIncrementalActive = state.incrementalConfig.isEnabled;
    final String stepValueStr = isIncrementalActive
        ? state.incrementalConfig.currentValue.toString()
        : '{{incremental}}';

    final String previewTitle = state.titleTemplate.isEmpty
        ? context.l10n.calNoTitleTemplate
        : state.titleTemplate.replaceAll('{{incremental}}', stepValueStr);

    final String previewDesc = state.descriptionTemplate == null || state.descriptionTemplate!.isEmpty
        ? context.l10n.calNoDescriptionTemplate
        : state.descriptionTemplate!.replaceAll('{{incremental}}', stepValueStr);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.calLiveCardPreview.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: context.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colorScheme.secondary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        state.category.toLocalizedString(context).toUpperCase(),
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.secondary
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: state.accessType == GroupEventAccessType.public
                            ? context.vrcColors.success.withValues(alpha: 0.1)
                            : context.vrcColors.statusBusy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        state.accessType.toLocalizedString(context).toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: state.accessType == GroupEventAccessType.public
                              ? context.vrcColors.success
                              : context.vrcColors.statusBusy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  previewTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  previewDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: context.colorScheme.outline),
                    const SizedBox(width: 6),
                    Text(
                      "${state.schedule.startTimeOfDay} • ${state.recurrence.type.toLocalizedString(context)}",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colorScheme.outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}