import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/presentation/extensions/enum_extensions.dart';
import 'package:vrcma/presentation/state/calendar_automation_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/localization_helpers.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';

class CalendarAutomationEditorSheet extends ConsumerStatefulWidget {
  final CalendarAutomationRule? rule;
  const CalendarAutomationEditorSheet({super.key, this.rule});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarAutomationEditorSheetState();
}

class _CalendarAutomationEditorSheetState extends ConsumerState<CalendarAutomationEditorSheet> {
  late TextEditingController _nameController;
  late TextEditingController _groupIdController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final initialRule = ref.read(calendarAutomationEditorProvider(widget.rule));
    _nameController = TextEditingController(text: initialRule.name);
    _groupIdController = TextEditingController(text: initialRule.groupId);
    _titleController = TextEditingController(text: initialRule.titleTemplate);
    _descriptionController = TextEditingController(text: initialRule.descriptionTemplate ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupIdController.dispose();
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
          mobile: _buildFormContent(state, notifier),
          desktop: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildLeftPane(state, notifier),
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
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftPane(state, notifier),
          const Divider(height: 32),
          _buildRightPane(state, notifier),
        ],
      ),
    );
  }

  Widget _buildLeftPane(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
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
        TextField(
          controller: _groupIdController,
          decoration: InputDecoration(
            labelText: context.l10n.calFieldLabelGroupId,
            prefixIcon: const Icon(Icons.group_outlined),
          ),
          onChanged: notifier.updateGroupId,
        ),
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
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.l10n.calFieldLabelDesc,
            prefixIcon: const Icon(Icons.description_outlined),
          ),
          onChanged: (val) => notifier.updateDescriptionTemplate(val.isEmpty ? null : val),
        )
      ],
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
        _buildSectionHeader(context.l10n.calSectionVrcMetadata),
        const SizedBox(height: 16),
        _buildVrcMetadataCard(state, notifier),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: context.colorScheme.primary
      ),
    );
  }

  Widget _buildSchedulerInteractiveCard(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    final endTime = _calculateEndTime(state.schedule.startTimeOfDay, state.schedule.durationMinutes);
    final formattedEndTime = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

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

  Widget _buildRecurrenceSelectorCard(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
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
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDaysOfWeekSelector(CalendarAutomationRule state, CalendarAutomationEditor notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final isSelected = state.recurrence.daysOfWeek.contains(dayNumber);
        final localizedDayLabel = LocalizationHelpers.getLocalizedWeekdayName(context, dayNumber);

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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
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
            initialValue: state.accessType,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_open)),
            items: GroupEventAccessType.values.map((access) {
              return DropdownMenuItem(
                value: access,
                child: Text(access.toLocalizedString(context)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) notifier.updateAccessType(val);
            },
          )
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
  String _formatDuration(BuildContext context, int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return context.l10n.calDurationHoursMinutes(hours, remainingMinutes);
    } else if (hours > 0) {
      return context.l10n.timeHoursAgo(hours).replaceAll(RegExp(r'[^0-9a-zA-Z\s]'), '');
    }
    return context.l10n.calDurationMinutesOnly(remainingMinutes);
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