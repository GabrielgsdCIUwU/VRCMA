import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/presentation/state/message_management_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/slot_card.dart';

class MessagesPanel extends ConsumerWidget {
  const MessagesPanel({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messageManagementProvider);
    final isWide = MediaQuery.of(context).size.width > 900;
    
    return messagesAsync.when(
      data: (allMessages) => DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              color: Colors.black26,
              child: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: "INVITE"),
                  Tab(text: "RESPONSE"),
                  Tab(text: "REQUEST"),
                  Tab(text: "REQ. RESPONSE"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: VrcMessageType.values.map((type) {
                  final filteredMessages = allMessages.where((m) => m.type == type).toList();
                  return _CategoryWorkspace(type: type, messages: filteredMessages);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text("Error: $error")),
    );
  }
}

class _CategoryWorkspace extends StatelessWidget {
  final VrcMessageType type;
  final List<CustomMessage> messages;
  const _CategoryWorkspace({required this.type, required this.messages});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black12,
          child: _SlotMonitorSection(messages: messages),
        ),
        
        const Divider(height: 1),
        
        Expanded(
          child: _LibrarySection(
            messages: messages,
            type: type,
            isScrollable: true,
          ),
        ),
      ],
    );
  }
}

class _SlotMonitorSection extends StatelessWidget {
  final List<CustomMessage> messages;
  const _SlotMonitorSection({required this.messages});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: "VRChat Live Slots", icon: Icons.sync_alt),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 90,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, i) {
              final msg = messages.firstWhereOrNull((m) => m.slotIndex == i);
              return SlotCard(index: i, message: msg);
            },
          ),
        ],
      ),
    );
  }
}

class _LibrarySection extends ConsumerWidget {
  final List<CustomMessage> messages;
  final VrcMessageType type;
  final bool isScrollable;
  const _LibrarySection({required this.messages, required this.type, this.isScrollable = true});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ListView.separated(
      shrinkWrap: !isScrollable,
      physics: isScrollable ? null : const NeverScrollableScrollPhysics(),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final msg = messages[i];
        return ListTile(
          title: Text(msg.content, style: const TextStyle(fontSize: 14)),
          subtitle: Text(msg.type.name, style: const TextStyle(fontSize: 10, color: Colors.deepPurpleAccent)),
          trailing: msg.isActive
            ? Badge(label: Text("Slot ${msg.slotIndex}"))
            : IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => ref.read(messageManagementProvider.notifier).deleteMessage(msg.id!),
          ),
        );
      },
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: _SectionHeader(
              title: "Message Library",
              icon: Icons.library_books,
              action: IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.deepPurpleAccent),
                onPressed: () => _showAddDialog(context, ref),
                tooltip: "Add message to ${type.name}",
              ),
          ),
        ),
        isScrollable ? Expanded(child: list) : list,
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("New ${type.name.toUpperCase()} Message"),
          content: TextField(
            controller: controller,
            maxLength: 64,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Type your message here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(messageManagementProvider.notifier).createMessage(controller.text, type);
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? action;
  const _SectionHeader({required this.title, required this.icon, this.action});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.grey
          ),
        ),
        ?action,
      ],
    );
  }
}
