import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';
import 'package:vrcma/presentation/extensions/date_time_extensions.dart';
import 'package:vrcma/presentation/extensions/entity_extensions.dart';
import 'package:vrcma/presentation/extensions/enum_extensions.dart';
import 'package:vrcma/presentation/state/logs_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_avatar.dart';

class LogsPanel extends ConsumerWidget {
  const LogsPanel({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(appLogsProvider);
    
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          _buildFilterBar(context, ref),
          Expanded(
            child: logsAsync.when(
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
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: logs.length,
                  itemBuilder: (context, index) => _LogItemCard(log: logs[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(context.l10n.stateError(error.toString())),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.logsHeader.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.2,
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, color: context.colorScheme.error),
            tooltip: context.l10n.logsClearTooltip,
            onPressed: () => _showClearConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref) {
    final activeCategory = ref.watch(logCategoryFilterProvider);
    final activeSeverity = ref.watch(logSeverityFilterProvider);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: context.l10n.logsSearchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
              ),
              onChanged: (val) {
                ref.read(logSearchQueryProvider.notifier).updateQuery(val);
              },
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(context.l10n.logCategoryAll),
                    selected: activeCategory == null,
                    onSelected: (_) => ref.read(logCategoryFilterProvider.notifier).setCategory(null),
                  ),
                  const SizedBox(width: 8),
                  ...LogCategory.values.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat.toLocalizedString(context)),
                        selected: activeCategory == cat,
                        onSelected: (_) => ref.read(logCategoryFilterProvider.notifier).setCategory(cat),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(context.l10n.logSeverityAll),
                    selected: activeSeverity == null,
                    onSelected: (_) => ref.read(logSeverityFilterProvider.notifier).setSeverity(null),
                  ),
                  const SizedBox(width: 8),
                  ...LogSeverity.values.map((sev) {
                    final color = _getSeverityColor(context, sev);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          sev.toLocalizedString(context).toUpperCase(), 
                          style: TextStyle(color: activeSeverity == sev ? color : null)
                        ),
                        selected: activeSeverity == sev,
                        onSelected: (_) => ref.read(logSeverityFilterProvider.notifier).setSeverity(sev),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}

class _LogItemCard extends StatelessWidget {
  final AppLog log;
  const _LogItemCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ExpansionTile(
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
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5)
                ),
              ),
            ],
          ),
        ),
        children: [
          if (log.getLocalizedDetails(context) != null || log.details != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (log.getLocalizedDetails(context) != null) ...[
                      Text(
                        log.getLocalizedDetails(context)!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (log.details != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          log.details!,
                          style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                        ),
                      ),
                  ],
                ),
              ),
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

class _SeverityIndicatorBadge extends StatelessWidget {
  final LogSeverity severity;
  const _SeverityIndicatorBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (severity) {
      case LogSeverity.info:
        color = context.vrcColors.success;
        break;
      case LogSeverity.warning:
        color = context.vrcColors.request;
        break;
      case LogSeverity.error:
        color = context.vrcColors.error;
        break;
    }

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
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}