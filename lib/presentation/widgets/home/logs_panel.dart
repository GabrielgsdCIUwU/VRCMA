import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/domain/entities/automation/automation_log.dart';
import 'package:vrcma/presentation/state/logs_provider.dart';
import 'package:intl/intl.dart';

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
               "AUTOMATION LOGS",
               style: Theme.of(context).textTheme.labelLarge?.copyWith(
                 letterSpacing: 1.2,
                 color: Colors.grey.shade400,
                 fontWeight: FontWeight.bold
               ),
             ),
             const SizedBox(height: 12),
             TextField(
               decoration: InputDecoration(
                 hintText: "Search by name or rule...",
                 prefixIcon: const Icon(Icons.search, size: 20),
                 isDense: true,
                 contentPadding: const EdgeInsets.symmetric(vertical: 12),
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8)
                 ),
               ),
               onChanged: (val) {
                 ref.read(automationLogsProvider.notifier).setSearch(val);
               },
             )
           ],
         ),
       ),
        Expanded(
          child: logsAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return const Center(
                  child: Text("No logs found", style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.separated(
                itemCount: logs.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 70),
                itemBuilder: (context, index) => _LogTile(log: logs[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text("Error: $error"),
          ),
        )
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  final AutomationLog log;
  const _LogTile({required this.log});
  
  @override
  Widget build(BuildContext context) {
    final isAccepted = log.action == 'ACCEPTED';
    final isInvite = log.invitationType == 'INVITE';
    
    return ListTile(
      dense: true,
      leading: _LogAvatar(url: log.senderAvatarUrl, name: log.senderName),
      title: Row(
        children: [
          Expanded(
            child: Text(
              log.senderName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _Badge(
            text: log.invitationType,
            color: isInvite ? Colors.blueGrey : Colors.deepPurple,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            "Rule: ${log.appliedRule}",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(log.timestamp),
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isAccepted ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          log.action,
          style: TextStyle(
            color: isAccepted ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _LogAvatar extends StatelessWidget {
  final String url;
  final String name;
  const _LogAvatar({required this.url, required this.name});
  
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.shade800,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
        ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white)) 
        : null,
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}