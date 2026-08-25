import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';
import 'package:vrcma/presentation/extensions/date_time_extensions.dart';
import 'package:vrcma/presentation/extensions/entity_extensions.dart';
import 'package:vrcma/presentation/extensions/enum_extensions.dart';
import 'package:vrcma/presentation/state/logs_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_avatar.dart';

/// Enables drag-to-scroll for both touch and desktop pointer devices.
class _DragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class LogsPanel extends ConsumerWidget {
  const LogsPanel({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ResponsiveLayout(
      mobile: _MobileLogsView(),
      desktop: _DesktopLogsView(),
    );
  }
}

class _MobileLogsView extends ConsumerStatefulWidget {
  const _MobileLogsView();

  @override
  ConsumerState<_MobileLogsView> createState() => _MobileLogsViewState();
}

class _MobileLogsViewState extends ConsumerState<_MobileLogsView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(logSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(appLogsProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LogsHeader(onClear: () => _showClearConfirmation(context, ref)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _LogsSearchBar(
              controller: _searchController,
              onChanged: (val) => ref.read(logSearchQueryProvider.notifier).updateQuery(val),
              onClear: () {
                _searchController.clear();
                ref.read(logSearchQueryProvider.notifier).updateQuery('');
              },
            ),
          ),
          const SizedBox(height: 10),
          const _EdgeToEdgeCategoryChips(),
          const SizedBox(height: 8),
          const _EdgeToEdgeSeverityChips(),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Expanded(
            child: _LogsListContent(logsAsync: logsAsync),
          ),
        ],
      ),
    );
  }
}

class _DesktopLogsView extends ConsumerStatefulWidget {
  const _DesktopLogsView();

  @override
  ConsumerState<_DesktopLogsView> createState() => _DesktopLogsViewState();
}

class _DesktopLogsViewState extends ConsumerState<_DesktopLogsView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(logSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(appLogsProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LogsHeader(onClear: () => _showClearConfirmation(context, ref)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LogsSearchBar(
                  controller: _searchController,
                  onChanged: (val) => ref.read(logSearchQueryProvider.notifier).updateQuery(val),
                  onClear: () {
                    _searchController.clear();
                    ref.read(logSearchQueryProvider.notifier).updateQuery('');
                  },
                ),
                const SizedBox(height: 12),
                const _DesktopCategoryChipsWrap(),
                const SizedBox(height: 8),
                const _DesktopSeverityChipsWrap(),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _LogsListContent(logsAsync: logsAsync),
          ),
        ],
      ),
    );
  }
}

class _LogsHeader extends StatelessWidget {
  final VoidCallback onClear;

  const _LogsHeader({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              context.l10n.logsHeader.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, color: context.colorScheme.error),
            tooltip: context.l10n.logsClearTooltip,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

class _LogsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _LogsSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: context.l10n.logsSearchHint,
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: onClear,
            )
                : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: onChanged,
        );
      },
    );
  }
}

class _EdgeToEdgeCategoryChips extends ConsumerWidget {
  const _EdgeToEdgeCategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategory = ref.watch(logCategoryFilterProvider);

    return SizedBox(
      height: 38,
      child: ScrollConfiguration(
        behavior: _DragScrollBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: LogCategory.values.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ChoiceChip(
                visualDensity: VisualDensity.compact,
                label: Text(context.l10n.logCategoryAll),
                selected: activeCategory == null,
                onSelected: (_) => ref.read(logCategoryFilterProvider.notifier).setCategory(null),
              );
            }
            final cat = LogCategory.values[index - 1];
            return ChoiceChip(
              visualDensity: VisualDensity.compact,
              label: Text(cat.toLocalizedString(context)),
              selected: activeCategory == cat,
              onSelected: (_) => ref.read(logCategoryFilterProvider.notifier).setCategory(cat),
            );
          },
        ),
      ),
    );
  }
}

class _EdgeToEdgeSeverityChips extends ConsumerWidget {
  const _EdgeToEdgeSeverityChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSeverity = ref.watch(logSeverityFilterProvider);

    return SizedBox(
      height: 38,
      child: ScrollConfiguration(
        behavior: _DragScrollBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: LogSeverity.values.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ChoiceChip(
                visualDensity: VisualDensity.compact,
                label: Text(context.l10n.logSeverityAll),
                selected: activeSeverity == null,
                onSelected: (_) => ref.read(logSeverityFilterProvider.notifier).setSeverity(null),
              );
            }
            final sev = LogSeverity.values[index - 1];
            final color = _getSeverityColor(context, sev);
            return ChoiceChip(
              visualDensity: VisualDensity.compact,
              label: Text(
                sev.toLocalizedString(context).toUpperCase(),
                style: TextStyle(color: activeSeverity == sev ? color : null),
              ),
              selected: activeSeverity == sev,
              onSelected: (_) => ref.read(logSeverityFilterProvider.notifier).setSeverity(sev),
            );
          },
        ),
      ),
    );
  }
}

class _DesktopCategoryChipsWrap extends ConsumerWidget {
  const _DesktopCategoryChipsWrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategory = ref.watch(logCategoryFilterProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          visualDensity: VisualDensity.compact,
          label: Text(context.l10n.logCategoryAll),
          selected: activeCategory == null,
          onSelected: (_) => ref.read(logCategoryFilterProvider.notifier).setCategory(null),
        ),
        ...LogCategory.values.map((cat) {
          return ChoiceChip(
            visualDensity: VisualDensity.compact,
            label: Text(cat.toLocalizedString(context)),
            selected: activeCategory == cat,
            onSelected: (_) => ref.read(logCategoryFilterProvider.notifier).setCategory(cat),
          );
        }),
      ],
    );
  }
}

class _DesktopSeverityChipsWrap extends ConsumerWidget {
  const _DesktopSeverityChipsWrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSeverity = ref.watch(logSeverityFilterProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          visualDensity: VisualDensity.compact,
          label: Text(context.l10n.logSeverityAll),
          selected: activeSeverity == null,
          onSelected: (_) => ref.read(logSeverityFilterProvider.notifier).setSeverity(null),
        ),
        ...LogSeverity.values.map((sev) {
          final color = _getSeverityColor(context, sev);
          return ChoiceChip(
            visualDensity: VisualDensity.compact,
            label: Text(
              sev.toLocalizedString(context).toUpperCase(),
              style: TextStyle(color: activeSeverity == sev ? color : null),
            ),
            selected: activeSeverity == sev,
            onSelected: (_) => ref.read(logSeverityFilterProvider.notifier).setSeverity(sev),
          );
        }),
      ],
    );
  }
}

class _LogsListContent extends StatelessWidget {
  final AsyncValue<List<AppLog>> logsAsync;

  const _LogsListContent({required this.logsAsync});

  @override
  Widget build(BuildContext context) {
    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                context.l10n.logsEmpty,
                style: TextStyle(color: context.colorScheme.onSurfaceVariant),
              ),
            ),
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: logs.length,
          itemBuilder: (context, index) => _LogItemCard(log: logs[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(context.l10n.stateError(error.toString())),
      ),
    );
  }
}

class _LogItemCard extends StatelessWidget {
  final AppLog log;
  const _LogItemCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: context.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        visualDensity: VisualDensity.compact,
        leading: _buildLeadingAvatar(context),
        title: Row(
          children: [
            Expanded(
              child: Text(
                log.getLocalizedMessage(context),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            _SeverityIndicatorBadge(severity: log.severity),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              _CategoryBadge(category: log.category),
              const SizedBox(width: 8),
              Text(
                log.timestamp.toRelativeString(context),
                style: TextStyle(
                  fontSize: 10,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _LogMetadataDetailsView(log: log),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingAvatar(BuildContext context) {
    final meta = log.metadata;
    if (meta is InvitationLogMetadata && meta.senderAvatarUrl.isNotEmpty) {
      return VrcAvatar(
        imageUrl: meta.senderAvatarUrl,
        displayName: meta.senderName,
        radius: 18,
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: log.category.getColor(context).withValues(alpha: 0.1),
      child: log.category.getIcon(context, size: 18),
    );
  }
}

class _LogMetadataDetailsView extends StatelessWidget {
  final AppLog log;
  const _LogMetadataDetailsView({required this.log});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final meta = log.metadata;

    final List<Widget> detailRows = switch (meta) {
      CalendarLogMetadata() => [
        _DetailRow(label: l10n.logDetailRule, value: meta.ruleName),
        if (meta.eventTitle != null && meta.eventTitle!.isNotEmpty)
          _DetailRow(label: l10n.logDetailEventTitle, value: meta.eventTitle!),
        if (meta.groupId != null && meta.groupId!.isNotEmpty)
          _DetailRow(label: l10n.logDetailGroup, value: meta.groupId!, isMonospace: true),
        if (meta.occurrenceUtc != null)
          _DetailRow(
            label: l10n.logDetailScheduledFor,
            value: DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                .add_jm()
                .format(meta.occurrenceUtc!.toLocal()),
          ),
        if (meta.eventId != null && meta.eventId!.isNotEmpty)
          _DetailRow(label: l10n.logDetailEventId, value: meta.eventId!, isMonospace: true),
      ],

      StatusLogMetadata() => [
        if (meta.profileName != null && meta.profileName!.isNotEmpty)
          _DetailRow(label: l10n.logDetailStatusProfile, value: meta.profileName!),
        _DetailRow(label: l10n.logDetailStatus, value: context.getLocalizedStatus(meta.status.name)),
        if (meta.description.isNotEmpty)
          _DetailRow(label: l10n.logDetailStatusMessage, value: meta.description),
      ],

      InvitationLogMetadata() => [
        if (meta.profileName.isNotEmpty)
          _DetailRow(label: l10n.logDetailProfile, value: meta.profileName),
        _DetailRow(label: l10n.logDetailSender, value: "${meta.senderName} (${meta.senderId})"),
        _DetailRow(
          label: l10n.logDetailMatchedRole,
          value: meta.matchedRoleName ?? l10n.logNoRuleMatched,
        ),
      ],

      SocialLogMetadata() => [
        _DetailRow(label: l10n.logDetailTargetUser, value: "${meta.targetUserName} (${meta.targetUserId})"),
        if (meta.assignedRoleNames.isNotEmpty)
          _DetailRow(label: l10n.sectionRoles, value: meta.assignedRoleNames.join(', ')),
        _DetailRow(
          label: l10n.logDetailTrigger,
          value: switch (meta.trigger) {
            SocialAssignmentTrigger.newFriend => l10n.logSocialTriggerNewFriend,
            SocialAssignmentTrigger.tagMatch => l10n.logSocialTriggerTagMatch,
          },
        ),
      ],

      AuthLogMetadata() => [
        _DetailRow(label: l10n.logDetailTargetUser, value: "${meta.displayName} (${meta.userId})"),
        _DetailRow(label: l10n.logDetailAuthEvent, value: meta.event.toLocalizedString(context)),
      ],

      SystemLogMetadata() => meta.data.entries
          .map((e) => _DetailRow(label: e.key, value: e.value.toString()))
          .toList(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: detailRows,
          ),
        ),
        if (log.details != null && log.details!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.logDetailTechnicalDetails.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.error,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: context.colorScheme.error.withValues(alpha: 0.3)),
            ),
            child: SelectableText(
              log.details!,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMonospace;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: isMonospace ? 'monospace' : null,
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityIndicatorBadge extends StatelessWidget {
  final LogSeverity severity;
  const _SeverityIndicatorBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(context, severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        severity.toLocalizedString(context).toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 8),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final LogCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.toLocalizedString(context).toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Color _getSeverityColor(BuildContext context, LogSeverity severity) {
  switch (severity) {
    case LogSeverity.info:
      return context.vrcColors.success;
    case LogSeverity.warning:
      return context.vrcColors.request;
    case LogSeverity.error:
      return context.vrcColors.error;
  }
}

void _showClearConfirmation(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.logsClearConfirmTitle),
      content: Text(context.l10n.logsClearConfirmContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.btnCancel),
        ),
        TextButton(
          onPressed: () {
            ref.read(appLogsProvider.notifier).clearLogs();
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
          child: Text(context.l10n.btnDelete),
        ),
      ],
    ),
  );
}