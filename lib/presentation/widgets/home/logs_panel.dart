import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/automation_log.dart';
import 'package:vrcma/presentation/state/logs_provider.dart';
import 'package:intl/intl.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_avatar.dart';

class LogsPanel extends ConsumerWidget {
  const LogsPanel({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(automationLogsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Padding(
         padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
             const SizedBox(height: 12),
             TextField(
               decoration: InputDecoration(
                 hintText: context.l10n.logsSearchHint,
                 prefixIcon: const Icon(Icons.search, size: 20),
                 isDense: true,
                 contentPadding: const EdgeInsets.symmetric(vertical: 12),
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8)
                 ),
               ),
               onChanged: (val) {
                 ref.read(logSearchQueryProvider.notifier).updateQuery(val);
               },
             )
           ],
         ),
       ),
        Expanded(
          child: logsAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return Center(
                  child: Text(context.l10n.logsEmpty, style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: logs.length,
                itemBuilder: (context, index) => _LogTile(log: logs[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(context.l10n.stateError(error.toString())),
          ),
        )
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  final AutomationLog log;
  const _LogTile({required this.log});
  
  String _getRelativeTime(BuildContext context, DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 1) return context.l10n.timeJustNow;
    if (duration.inMinutes < 60) return context.l10n.timeMinutesAgo(duration.inMinutes);
    if (duration.inHours < 24) return context.l10n.timeHoursAgo(duration.inHours);
    if (duration.inDays < 7) return context.l10n.timeDaysAgo(duration.inDays);

    final localization = Localizations.localeOf(context).toString();
    return DateFormat.yMd(localization).format(dateTime);
  }
  
  @override
  Widget build(BuildContext context) {
    final isAccepted = log.action == 'ACCEPTED';
    final isInvite = log.invitationType == 'INVITE';
    
    final typeColor = isInvite ? context.vrcColors.invite : context.vrcColors.request;
    
   return Container(
     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
     decoration: BoxDecoration(
       color: context.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
       borderRadius: BorderRadius.circular(12),
     ),
     child: ListTile(
       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
       leading: VrcAvatar(
         imageUrl: log.senderAvatarUrl,
         displayName: log.senderName,
         radius: 22,
       ),
       title: Row(
         children: [
           Expanded(
             child: Text(
               log.senderName,
               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
               overflow: TextOverflow.ellipsis,
             ),
           ),
           _ActionStatus(isAccepted: isAccepted),
         ],
       ),
       
       subtitle: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const SizedBox(height: 6),
           Row(
             children: [
               _TypeBadge(
                 text: isInvite ? context.l10n.tabInvite : context.l10n.tabRequest,
                 color: typeColor
               ),
               const SizedBox(height: 8),
               Expanded(
                 child: Text(
                   log.appliedRule,
                   style: TextStyle(color: context.colorScheme.onSurfaceVariant, fontSize: 12),
                   overflow: TextOverflow.ellipsis,
                 ),
               ),
             ],
           ),
           const SizedBox(height: 4),
           Text(
             _getRelativeTime(context, log.timestamp),
             style: TextStyle(fontSize: 10, color: context.colorScheme.onSurface.withValues(alpha: 0.5)),
           ),
         ],
       ),
     ),
   );
  }
}

class _ActionStatus extends StatelessWidget {
  final bool isAccepted;
  const _ActionStatus({required this.isAccepted});
  
  @override
  Widget build(BuildContext context) {
    final color = isAccepted ? context.vrcColors.success : context.vrcColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        isAccepted ? context.l10n.actionAccepted : context.l10n.actionRejected,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 9
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _TypeBadge({required this.text, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 8, fontWeight: FontWeight.w900),
      ),
    );
  }
}