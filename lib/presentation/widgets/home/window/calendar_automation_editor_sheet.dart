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
import 'package:vrcma/domain/entities/calendar/enums/planned_occurrence_status.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/calendar/planned_occurrence.dart';
import 'package:vrcma/domain/entities/social/vrc_group.dart';
import 'package:vrcma/domain/error/domain_exception.dart';
import 'package:vrcma/domain/services/calendar/event_title_resolver.dart';
import 'package:vrcma/presentation/extensions/date_time_extensions.dart';
import 'package:vrcma/presentation/extensions/enum_extensions.dart';
import 'package:vrcma/presentation/extensions/error_extensions.dart';
import 'package:vrcma/presentation/services/snackbar_service.dart';
import 'package:vrcma/presentation/state/calendar_automation_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/adaptive_dialogs.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/common/show_generic_search_sheet.dart';

/// Full-screen editor for creating or modifying a [CalendarAutomationRule].
class CalendarAutomationEditorSheet extends ConsumerStatefulWidget {
  final CalendarAutomationRule? rule;

  const CalendarAutomationEditorSheet({super.key, this.rule});

  @override
  ConsumerState<CalendarAutomationEditorSheet> createState() =>
      _CalendarAutomationEditorSheetState();
}

class _CalendarAutomationEditorSheetState
    extends ConsumerState<CalendarAutomationEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(calendarAutomationEditorProvider(widget.rule));
    _nameController = TextEditingController(text: initial.name);
    _titleController = TextEditingController(text: initial.titleTemplate);
    _descriptionController =
        TextEditingController(text: initial.descriptionTemplate ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveAndExit() async {
    final notifier =
    ref.read(calendarAutomationEditorProvider(widget.rule).notifier);
    if (!notifier.isValid) return;

    try {
      await notifier.saveAndClose();
      if (!mounted) return;
      ref.read(snackbarServiceProvider).show(context.l10n.calToastSaved);
      Navigator.pop(context);
    } on DomainException catch (error) {
      if (mounted) {
        ref.read(snackbarServiceProvider).show(error.toLocalizedString(context));
      }
    }
  }

  Future<void> _handleExitPrompt(BuildContext context) async {
    final action = await AdaptiveDialogs.showUnsavedChangesDialog(context);
    if (!context.mounted || action == null) return;

    switch (action) {
      case UnsavedChangesAction.discard:
        Navigator.of(context).pop();
      case UnsavedChangesAction.save:
        await _saveAndExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarAutomationEditorProvider(widget.rule));
    final notifier =
    ref.read(calendarAutomationEditorProvider(widget.rule).notifier);
    final canSave = notifier.isValid && notifier.hasChanges;

    return PopScope(
      canPop: !notifier.hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExitPrompt(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.rule == null
                ? context.l10n.calEditorTitleNew
                : context.l10n.calEditorTitleEdit,
          ),
          actions: [
            _SaveActionButton(canSave: canSave, onPressed: _saveAndExit),
          ],
        ),
        body: ResponsiveLayout(
          mobile: _MobileEditorBody(
            state: state,
            notifier: notifier,
            nameController: _nameController,
            titleController: _titleController,
            descriptionController: _descriptionController,
          ),
          desktop: _DesktopEditorBody(
            state: state,
            notifier: notifier,
            nameController: _nameController,
            titleController: _titleController,
            descriptionController: _descriptionController,
          ),
        ),
      ),
    );
  }
}

class _SaveActionButton extends StatelessWidget {
  final bool canSave;
  final VoidCallback onPressed;

  const _SaveActionButton({required this.canSave, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilledButton.icon(
        icon: const Icon(Icons.save_outlined),
        label: Text(context.l10n.btnSave),
        style: FilledButton.styleFrom(
          backgroundColor: canSave ? context.vrcColors.success : null,
        ),
        onPressed: canSave ? onPressed : null,
      ),
    );
  }
}

class _MobileEditorBody extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const _MobileEditorBody({
    required this.state,
    required this.notifier,
    required this.nameController,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GeneralSettingsPane(
            state: state,
            notifier: notifier,
            nameController: nameController,
            titleController: titleController,
            descriptionController: descriptionController,
          ),
          const SizedBox(height: 16),
          _LiveTemplatePreview(state: state),
          const SizedBox(height: 16),
          _UpcomingSchedulePreviewCard(state: state),
          const Divider(height: 32),
          _SchedulingConfigPane(state: state, notifier: notifier),
        ],
      ),
    );
  }
}

class _DesktopEditorBody extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const _DesktopEditorBody({
    required this.state,
    required this.notifier,
    required this.nameController,
    required this.titleController,
    required this.descriptionController,
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
                _GeneralSettingsPane(
                  state: state,
                  notifier: notifier,
                  nameController: nameController,
                  titleController: titleController,
                  descriptionController: descriptionController,
                ),
                const SizedBox(height: 24),
                _LiveTemplatePreview(state: state),
                const SizedBox(height: 24),
                _UpcomingSchedulePreviewCard(state: state),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _SchedulingConfigPane(state: state, notifier: notifier),
          ),
        ),
      ],
    );
  }
}

class _GeneralSettingsPane extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const _GeneralSettingsPane({
    required this.state,
    required this.notifier,
    required this.nameController,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final isIncrementalEnabled = state.incrementalConfig.isEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EditorSectionHeader(title: context.l10n.sectionGeneralSettings),
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: context.l10n.calFieldLabelName,
            prefixIcon: const Icon(Icons.drive_file_rename_outline),
          ),
          onChanged: notifier.updateName,
        ),
        const SizedBox(height: 16),
        _GroupSelectorField(state: state, notifier: notifier),
        const SizedBox(height: 16),
        TextField(
          controller: titleController,
          maxLength: 64,
          decoration: InputDecoration(
            labelText: context.l10n.calFieldLabelTitle,
            hintText: context.l10n.calFieldHintTitle,
            prefixIcon: const Icon(Icons.title),
          ),
          onChanged: notifier.updateTitleTemplate,
        ),
        if (isIncrementalEnabled) ...[
          const SizedBox(height: 6),
          _InsertIncrementalChip(
            controller: titleController,
            onChanged: notifier.updateTitleTemplate,
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.l10n.calFieldLabelDesc,
            helperText: context.l10n.calDescFallbackNotice,
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.description_outlined),
          ),
          onChanged: (val) =>
              notifier.updateDescriptionTemplate(val.isEmpty ? null : val),
        ),
        if (isIncrementalEnabled) ...[
          const SizedBox(height: 6),
          _InsertIncrementalChip(
            controller: descriptionController,
            onChanged: (val) =>
                notifier.updateDescriptionTemplate(val.isEmpty ? null : val),
          ),
        ],
      ],
    );
  }
}

class _GroupSelectorField extends ConsumerWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _GroupSelectorField({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(userGroupsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.calFieldLabelGroupId,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        groupsAsync.when(
          data: (groups) => _buildSelectorBox(context, ref, groups),
          loading: () => const LinearProgressIndicator(),
          error: (err, _) => Text(context.l10n.stateError(err.toString())),
        ),
      ],
    );
  }

  Widget _buildSelectorBox(
      BuildContext context,
      WidgetRef ref,
      List<VrcGroup> groups,
      ) {
    final selected = groups.firstWhereOrNull((g) => g.id == state.groupId);
    final label = selected != null
        ? '${selected.name} (${selected.shortCode})'
        : (state.groupId.isNotEmpty
        ? state.groupId
        : context.l10n.calGroupSelectHint);
    final hasValue = selected != null || state.groupId.isNotEmpty;

    return InkWell(
      onTap: () => _openGroupPicker(context, ref, groups),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          color:
          context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            Icon(Icons.group_outlined, color: context.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: hasValue
                      ? context.colorScheme.onSurface
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down,
                color: context.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _openGroupPicker(
      BuildContext context,
      WidgetRef ref,
      List<VrcGroup> groups,
      ) {
    if (groups.isEmpty) {
      ref.read(snackbarServiceProvider).show(context.l10n.calGroupNoPerms);
      return;
    }

    showGenericSearchSheet<VrcGroup>(
      context: context,
      items: groups,
      searchHint: context.l10n.calGroupSelectHint,
      searchableText: (group) =>
      '${group.name} ${group.shortCode} ${group.id}',
      itemBuilder: (group) => ListTile(
        leading: Icon(Icons.group, color: context.colorScheme.primary),
        title: Text(group.name),
        subtitle: Text(group.shortCode, style: const TextStyle(fontSize: 12)),
      ),
      onSelected: (group) => _validateAndSelect(context, ref, group),
    );
  }

  Future<void> _validateAndSelect(
      BuildContext context,
      WidgetRef ref,
      VrcGroup? group,
      ) async {
    if (group == null) return;

    ref.read(snackbarServiceProvider).show(context.l10n.calGroupValidating);
    final hasPermission = await notifier.validateAndSetGroup(group.id);
    if (!context.mounted) return;

    if (!hasPermission) {
      ref.read(snackbarServiceProvider).show(context.l10n.calGroupPermissionDenied);
      return;
    }

    Navigator.pop(context);
  }
}

class _InsertIncrementalChip extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _InsertIncrementalChip({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ActionChip(
        avatar: const Icon(Icons.add, size: 14),
        label: const Text(
          '{{incremental}}',
          style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
        ),
        onPressed: _insertPlaceholder,
      ),
    );
  }

  void _insertPlaceholder() {
    const tag = '{{incremental}}';
    final text = controller.text;
    final selection = controller.selection;

    if (selection.isValid && selection.start >= 0) {
      controller.text = text.replaceRange(selection.start, selection.end, tag);
      controller.selection =
          TextSelection.collapsed(offset: selection.start + tag.length);
    } else {
      controller.text = text + tag;
    }
    onChanged(controller.text);
  }
}

class _SchedulingConfigPane extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _SchedulingConfigPane({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EditorSectionHeader(title: context.l10n.calSectionSchedule),
        const SizedBox(height: 16),
        _ScheduleCard(state: state, notifier: notifier),
        const SizedBox(height: 24),
        _EditorSectionHeader(title: context.l10n.calSectionRecurrence),
        const SizedBox(height: 16),
        _RecurrenceCard(state: state, notifier: notifier),
        const SizedBox(height: 24),
        _EditorSectionHeader(title: context.l10n.calSectionStrategy),
        const SizedBox(height: 16),
        _StrategyCard(state: state, notifier: notifier),
        const SizedBox(height: 24),
        _EditorSectionHeader(title: context.l10n.calSectionIncremental),
        const SizedBox(height: 16),
        _IncrementalConfigCard(state: state, notifier: notifier),
        const SizedBox(height: 24),
        _EditorSectionHeader(
          title: context.l10n.calSectionExceptions,
          trailing: _AddExceptionButton(notifier: notifier),
        ),
        const SizedBox(height: 16),
        _ExceptionsCard(state: state, notifier: notifier),
        const SizedBox(height: 24),
        _EditorSectionHeader(title: context.l10n.calSectionTolerances),
        const SizedBox(height: 16),
        _TolerancesCard(state: state, notifier: notifier),
        const SizedBox(height: 24),
        _EditorSectionHeader(title: context.l10n.calSectionVrcMetadata),
        const SizedBox(height: 16),
        _VrcMetadataCard(state: state, notifier: notifier),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _ScheduleCard({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final startTime = state.schedule.startTime;
    final endTime = startTime.addMinutes(state.schedule.durationMinutes);
    final locale = Localizations.localeOf(context).languageCode;

    return Card(
      elevation: 0,
      shape: _cardBorder(context),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: Text(context.l10n.calFieldLabelTime),
            subtitle: Text(
              startTime.formatted,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _pickTime(context, isStartTime: true),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(context.l10n.calFieldLabelStartDate),
            subtitle: Text(
              _formatDate(context, state.schedule.startDate, locale),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.edit_calendar_outlined, size: 20),
            onTap: () => _pickStartDate(context),
            onLongPress: () => notifier.updateStartDate(null),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.event_busy_outlined),
            title: Text(context.l10n.calFieldLabelEndDate),
            subtitle: Text(
              _formatDate(context, state.schedule.endDate, locale),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.edit_calendar_outlined, size: 20),
            onTap: () => _pickEndDate(context),
            onLongPress: () => notifier.updateEndDate(null),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.stop_circle_outlined),
            title: Text(context.l10n.calFieldLabelEndTime),
            subtitle: Text(
              endTime.formatted,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _pickTime(context, isStartTime: false),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(context.l10n.calFieldLabelDuration),
            subtitle: Text(
              _formatDuration(context, state.schedule.durationMinutes),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.public_outlined),
            title: Text(context.l10n.calFieldLabelTimezone),
            subtitle: Text(
              state.schedule.timezoneIana,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime? date, String locale) {
    if (date == null) return context.l10n.calOptionalDate;
    return DateFormat.yMd(locale).format(date);
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.schedule.startDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) notifier.updateStartDate(picked);
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final now = DateTime.now();
    final minDate = state.schedule.startDate ?? now.subtract(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: state.schedule.endDate ?? minDate,
      firstDate: minDate,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) notifier.updateEndDate(picked);
  }

  Future<void> _pickTime(
      BuildContext context, {
        required bool isStartTime,
      }) async {
    final start = state.schedule.startTime;
    final initial = isStartTime
        ? TimeOfDay(hour: start.hour, minute: start.minute)
        : _toTimeOfDay(start.addMinutes(state.schedule.durationMinutes));

    final selected = await showTimePicker(context: context, initialTime: initial);
    if (selected == null) return;

    final chosen = TimeOfDayValue(hour: selected.hour, minute: selected.minute);
    if (isStartTime) {
      notifier.updateTime(chosen);
      return;
    }

    final newDuration = start.minutesDifference(chosen);
    notifier.updateDuration(newDuration > 0 ? newDuration : 60);
  }

  TimeOfDay _toTimeOfDay(TimeOfDayValue value) {
    return TimeOfDay(hour: value.hour, minute: value.minute);
  }

  String _formatDuration(BuildContext context, int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return context.l10n.calDurationHoursMinutes(hours, minutes);
    }
    return context.l10n.calDurationMinutesOnly(minutes);
  }
}

class _StrategyCard extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _StrategyCard({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: _cardBorder(context),
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
              items: CreationStrategy.values
                  .map(
                    (strategy) => DropdownMenuItem(
                  value: strategy,
                  child: Text(strategy.toLocalizedString(context)),
                ),
              )
                  .toList(),
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
                  final parsed = int.tryParse(val);
                  if (parsed != null) notifier.updateMaxVisibleFutureEvents(parsed);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecurrenceCard extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _RecurrenceCard({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: _cardBorder(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<RecurrenceType>(
              initialValue: state.recurrence.type,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.repeat)),
              items: RecurrenceType.values
                  .map(
                    (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toLocalizedString(context)),
                ),
              )
                  .toList(),
              onChanged: _onRecurrenceTypeChanged,
            ),
            if (state.recurrence.type == RecurrenceType.weekly) ...[
              const SizedBox(height: 16),
              _DaysOfWeekSelector(state: state, notifier: notifier),
            ],
            if (state.recurrence.type == RecurrenceType.monthly) ...[
              const SizedBox(height: 16),
              _DaysOfMonthSelector(state: state, notifier: notifier),
            ],
          ],
        ),
      ),
    );
  }

  void _onRecurrenceTypeChanged(RecurrenceType? type) {
    if (type == null) return;
    notifier.updateRecurrence(
      RecurrencePattern(
        type: type,
        daysOfWeek: type == RecurrenceType.weekly ? const [DateTime.friday] : const [],
        daysOfMonth: type == RecurrenceType.monthly ? const [1] : const [],
      ),
    );
  }
}

class _DaysOfWeekSelector extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _DaysOfWeekSelector({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final isSelected = state.recurrence.daysOfWeek.contains(dayNumber);
        return _WeekdayChip(
          label: dayNumber.toLocalizedWeekdayName(context),
          isSelected: isSelected,
          onTap: () => _toggleDay(dayNumber, isSelected),
        );
      }),
    );
  }

  void _toggleDay(int dayNumber, bool isSelected) {
    final updated = List<int>.from(state.recurrence.daysOfWeek);
    if (isSelected && updated.length > 1) {
      updated.remove(dayNumber);
    } else if (!isSelected) {
      updated.add(dayNumber);
    }

    notifier.updateRecurrence(
      RecurrencePattern(type: state.recurrence.type, daysOfWeek: updated),
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WeekdayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: isSelected
            ? context.colorScheme.primary
            : context.colorScheme.surfaceContainerHighest,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? context.colorScheme.onPrimary
                : context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DaysOfMonthSelector extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _DaysOfMonthSelector({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.calDaysOfMonth,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(31, (index) {
            final dayNumber = index + 1;
            final isSelected = state.recurrence.daysOfMonth.contains(dayNumber);
            return _MonthDayChip(
              dayNumber: dayNumber,
              isSelected: isSelected,
              onTap: () => _toggleDay(dayNumber, isSelected),
            );
          }),
        ),
      ],
    );
  }

  void _toggleDay(int dayNumber, bool isSelected) {
    final updated = List<int>.from(state.recurrence.daysOfMonth);
    if (isSelected && updated.length > 1) {
      updated.remove(dayNumber);
    } else if (!isSelected) {
      updated.add(dayNumber);
    }

    notifier.updateRecurrence(
      RecurrencePattern(
        type: state.recurrence.type,
        daysOfWeek: state.recurrence.daysOfWeek,
        daysOfMonth: updated,
      ),
    );
  }
}

class _MonthDayChip extends StatelessWidget {
  final int dayNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const _MonthDayChip({
    required this.dayNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: isSelected
            ? context.colorScheme.primary
            : context.colorScheme.surfaceContainerHighest,
        child: Text(
          dayNumber.toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? context.colorScheme.onPrimary
                : context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _IncrementalConfigCard extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _IncrementalConfigCard({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final config = state.incrementalConfig;

    return Card(
      elevation: 0,
      shape: _cardBorder(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                context.l10n.calFieldLabelIncrementalEnable,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                context.l10n.calFieldLabelIncrementalDesc,
                style: const TextStyle(fontSize: 11),
              ),
              value: config.isEnabled,
              onChanged: notifier.updateIncrementalEnabled,
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
                      onChanged: (val) =>
                          notifier.updateIncrementalStart(int.tryParse(val)),
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
                      onChanged: (val) =>
                          notifier.updateIncrementalStep(int.tryParse(val)),
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
}

class _AddExceptionButton extends StatelessWidget {
  final CalendarAutomationEditor notifier;

  const _AddExceptionButton({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _pickExceptionRange(context),
      icon: const Icon(Icons.add, size: 16),
      label: Text(context.l10n.calExceptionAdd),
    );
  }

  Future<void> _pickExceptionRange(BuildContext context) async {
    final now = DateTime.now();
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            child: child,
          ),
        );
      },
    );

    if (dateRange == null) return;

    final hasRange = dateRange.end != dateRange.start;
    notifier.addException(
      CalendarException(
        exceptionDate: dateRange.start,
        exceptionEndDate: hasRange ? dateRange.end : null,
        isCancelled: true,
      ),
    );
  }
}

class _ExceptionsCard extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _ExceptionsCard({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (state.exceptions.isEmpty) {
      return Card(
        elevation: 0,
        shape: _cardBorder(context),
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
      shape: _cardBorder(context),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.exceptions.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) => _ExceptionTile(
          exception: state.exceptions[index],
          locale: locale,
          onDelete: () => notifier.removeException(state.exceptions[index]),
        ),
      ),
    );
  }
}

class _ExceptionTile extends StatelessWidget {
  final CalendarException exception;
  final String locale;
  final VoidCallback onDelete;

  const _ExceptionTile({
    required this.exception,
    required this.locale,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final startStr = DateFormat.yMd(locale).format(exception.exceptionDate);
    final endStr = exception.exceptionEndDate != null
        ? context.l10n.calExceptionUntil(
      DateFormat.yMd(locale).format(exception.exceptionEndDate!),
    )
        : '';

    return ListTile(
      leading: Icon(Icons.event_busy, color: context.colorScheme.error),
      title: Text(context.l10n.calExceptionCancel),
      subtitle: Text('$startStr$endStr'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}

class _TolerancesCard extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _TolerancesCard({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: _cardBorder(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                context.l10n.calFieldLabelOverflow,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                context.l10n.calFieldLabelOverflowDesc,
                style: const TextStyle(fontSize: 11),
              ),
              value: state.usesInstanceOverflow,
              onChanged: (_) => notifier.toggleInstanceOverflow(),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _TolerancesInputRow(state: state, notifier: notifier),
            const SizedBox(height: 12),
            _ExplanationRow(
              icon: Icons.vpn_key_outlined,
              title: context.l10n.calToleranceHostTitle,
              explanation: context.l10n.calToleranceHostDesc,
            ),
            const SizedBox(height: 6),
            _ExplanationRow(
              icon: Icons.people_outline,
              title: context.l10n.calToleranceMemberTitle,
              explanation: context.l10n.calToleranceMemberDesc,
            ),
            const SizedBox(height: 6),
            _ExplanationRow(
              icon: Icons.hourglass_empty_outlined,
              title: context.l10n.calToleranceCloseTitle,
              explanation: context.l10n.calToleranceCloseDesc,
            ),
          ],
        ),
      ),
    );
  }
}

class _TolerancesInputRow extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _TolerancesInputRow({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: state.hostEarlyJoinMinutes?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.l10n.calFieldLabelHostEarlyShort,
              isDense: true,
            ),
            onChanged: (val) => notifier.updateTolerances(
              hostMinutes: int.tryParse(val),
              guestMinutes: state.guestEarlyJoinMinutes,
              closeMinutes: state.closeInstanceAfterEndMinutes,
            ),
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
            onChanged: (val) => notifier.updateTolerances(
              hostMinutes: state.hostEarlyJoinMinutes,
              guestMinutes: int.tryParse(val),
              closeMinutes: state.closeInstanceAfterEndMinutes,
            ),
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
            onChanged: (val) => notifier.updateTolerances(
              hostMinutes: state.hostEarlyJoinMinutes,
              guestMinutes: state.guestEarlyJoinMinutes,
              closeMinutes: int.tryParse(val),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExplanationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String explanation;

  const _ExplanationRow({
    required this.icon,
    required this.title,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
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
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: explanation,
                  style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VrcMetadataCard extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _VrcMetadataCard({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final accessIcon = state.accessType == GroupEventAccessType.public
        ? Icons.lock_open_outlined
        : Icons.lock_outlined;

    return Card(
      elevation: 0,
      shape: _cardBorder(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<GroupEventCategory>(
            initialValue: state.category,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: GroupEventCategory.values
                .map(
                  (cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat.toLocalizedString(context)),
              ),
            )
                .toList(),
            onChanged: (val) {
              if (val != null) notifier.updateCategory(val);
            },
          ),
          const Divider(height: 1),
          DropdownButtonFormField<GroupEventAccessType>(
            key: ValueKey('access_type_${state.accessType.name}'),
            initialValue: state.accessType,
            decoration: InputDecoration(
              prefixIcon: Icon(accessIcon, color: context.colorScheme.primary),
              helperText: state.accessType == GroupEventAccessType.public
                  ? context.l10n.calAccessPublicDesc
                  : context.l10n.calAccessGroupDesc,
            ),
            items: GroupEventAccessType.values
                .map(
                  (access) => DropdownMenuItem(
                value: access,
                child: Text(access.toLocalizedString(context)),
              ),
            )
                .toList(),
            onChanged: (val) {
              if (val != null) notifier.updateAccessType(val);
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(
              context.l10n.calFieldLabelSendNotification,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              context.l10n.calFieldLabelSendNotificationDesc,
              style: const TextStyle(fontSize: 11),
            ),
            value: state.sendNotification,
            onChanged: (_) => notifier.toggleSendNotification(),
          ),
          const Divider(height: 1),
          _PlatformsSelector(state: state, notifier: notifier),
        ],
      ),
    );
  }
}

class _PlatformsSelector extends StatelessWidget {
  final CalendarAutomationRule state;
  final CalendarAutomationEditor notifier;

  const _PlatformsSelector({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: CalendarEventPlatform.values.map((platform) {
              return ChoiceChip(
                label: Text(
                  platform.name.toUpperCase(),
                  style: const TextStyle(fontSize: 11),
                ),
                selected: state.platforms.contains(platform),
                onSelected: (_) => notifier.togglePlatform(platform),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LiveTemplatePreview extends StatelessWidget {
  final CalendarAutomationRule state;

  const _LiveTemplatePreview({required this.state});

  @override
  Widget build(BuildContext context) {
    final resolved = EventTitleResolver().resolve(state);
    final previewTitle = resolved.title.trim().isEmpty
        ? context.l10n.calNoTitleTemplate
        : resolved.title;
    final previewDesc =
    (resolved.description == null || resolved.description!.trim().isEmpty)
        ? context.l10n.calNoDescriptionTemplate
        : resolved.description!;

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
          color:
          context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                _PreviewBadgesRow(state: state),
                const SizedBox(height: 16),
                Text(
                  previewTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  previewDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 14, color: context.colorScheme.outline),
                    const SizedBox(width: 6),
                    Text(
                      '${state.schedule.startTime.formatted} • ${state.recurrence.type.toLocalizedString(context)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.outline,
                      ),
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

class _PreviewBadgesRow extends StatelessWidget {
  final CalendarAutomationRule state;

  const _PreviewBadgesRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final isPublic = state.accessType == GroupEventAccessType.public;
    final accessColor =
    isPublic ? context.vrcColors.success : context.vrcColors.statusBusy;

    return Row(
      children: [
        _TagPill(
          label: state.category.toLocalizedString(context).toUpperCase(),
          color: context.colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        _TagPill(
          label: state.accessType.toLocalizedString(context).toUpperCase(),
          color: accessColor,
        ),
      ],
    );
  }
}

class _UpcomingSchedulePreviewCard extends ConsumerWidget {
  final CalendarAutomationRule state;

  const _UpcomingSchedulePreviewCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.groupId.trim().isEmpty) return const SizedBox.shrink();

    final previewAsync = ref.watch(calendarRulePreviewProvider(state));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EditorSectionHeader(title: context.l10n.calSectionSchedulePreview),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: _cardBorder(context),
          child: previewAsync.when(
            data: (occurrences) => _PreviewList(occurrences: occurrences),
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.stateError(err.toString())),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewList extends StatelessWidget {
  final List<PlannedOccurrence> occurrences;

  const _PreviewList({required this.occurrences});

  @override
  Widget build(BuildContext context) {
    if (occurrences.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            context.l10n.calPreviewEmpty,
            style: TextStyle(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: occurrences.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) =>
          _PreviewOccurrenceTile(occurrence: occurrences[index]),
    );
  }
}

class _PreviewOccurrenceTile extends StatelessWidget {
  final PlannedOccurrence occurrence;

  const _PreviewOccurrenceTile({required this.occurrence});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final formattedDate =
    DateFormat.yMMMd(locale).add_Hm().format(occurrence.startUtc.toLocal());
    final (statusLabel, statusColor, icon) = _resolveBadgeStyle(context);

    return ListTile(
      dense: true,
      leading: Icon(icon, color: statusColor, size: 20),
      title: Text(
        formattedDate,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      trailing: _TagPill(label: statusLabel, color: statusColor),
    );
  }

  (String, Color, IconData) _resolveBadgeStyle(BuildContext context) {
    return switch (occurrence.status) {
      PlannedOccurrenceStatus.pendingPublish => (
      context.l10n.calPreviewStatusPending,
      context.vrcColors.success,
      Icons.schedule_send_outlined,
      ),
      PlannedOccurrenceStatus.alreadyPublished => (
      context.l10n.calPreviewStatusPublished,
      context.colorScheme.primary,
      Icons.cloud_done_outlined,
      ),
      PlannedOccurrenceStatus.cancelledByException => (
      context.l10n.calPreviewStatusCancelled,
      context.colorScheme.error,
      Icons.event_busy_outlined,
      ),
    };
  }
}

class _EditorSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _EditorSectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: context.colorScheme.primary,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;

  const _TagPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

RoundedRectangleBorder _cardBorder(BuildContext context) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: context.colorScheme.outlineVariant),
  );
}