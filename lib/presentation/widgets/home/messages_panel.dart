import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/presentation/state/message_management_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/slot_card.dart';
import 'package:vrcma/presentation/widgets/home/common/vrc_message_type_extension.dart';

class MessagesPanel extends ConsumerWidget {
  const MessagesPanel({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messageManagementProvider);
    
    return messagesAsync.when(
      data: (allMessages) => DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              color: context.colorScheme.surfaceContainerHigh,
              child: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: context.l10n.tabInvite),
                  Tab(text: context.l10n.tabResponse),
                  Tab(text: context.l10n.tabRequest),
                  Tab(text: context.l10n.tabReqResponse),
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
      error: (error, _) => Center(child: Text(context.l10n.stateError(error.toString()))),
    );
  }
}

class _CategoryWorkspace extends StatefulWidget {
  final VrcMessageType type;
  final List<CustomMessage> messages;

  const _CategoryWorkspace({required this.type, required this.messages});

  @override
  State<StatefulWidget> createState() => _CategoryWorkspaceState();
}

class _CategoryWorkspaceState extends State<_CategoryWorkspace> {
  bool isSlotsExpanded = true;
  bool isLibraryExpanded = true;
  
  bool isUnassignedExpanded = true;
  bool isAssignedExpanded = true;
  
  VrcMessageType get type => widget.type;
  
  List<CustomMessage> get assignedMessages {
    final activeMessages = widget.messages.where((m) => m.isActive).toList();
    activeMessages.sort((a, b) => a.slotIndex!.compareTo(b.slotIndex!));
    return activeMessages;
  }
  
  List<CustomMessage> get unassignedMessages {
    final inactiveMessages = widget.messages.where((m) => !m.isActive).toList();
    inactiveMessages.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return inactiveMessages;
  }
  
  @override
  Widget build(BuildContext context) {
    final assigned = assignedMessages;
    final unassigned = unassignedMessages;
    
    return Container(
      color: context.colorScheme.surfaceContainer,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: _SlotMonitorHeader(
                isExpanded: isSlotsExpanded,
                onToggle: () => setState(() => isSlotsExpanded = !isSlotsExpanded),
              ),
            ),
          ),
          if (isSlotsExpanded)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisExtent: 80,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final msg = widget.messages.firstWhereOrNull((m) => m.slotIndex == i);
                    return SlotCard(index: i+1, message: msg);
                  },
                childCount: 12,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverToBoxAdapter(child: Divider(height: 1)),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: _LibraryHeader(
                type: type,
                isExpanded: isLibraryExpanded,
                onToggle: () => setState(() => isLibraryExpanded = !isLibraryExpanded),
              ),
            ),
          ),
          
          if (isLibraryExpanded) ...[
            if (widget.messages.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text(context.l10n.libraryEmpty, style: TextStyle(color: context.colorScheme.onSurfaceVariant))),
              ),
            )
          else ...[
              if (unassigned.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: CollapsibleHeader.secondary(
                    title: context.l10n.unassignedMessagesHeader, 
                    count: unassigned.length,
                    isExpanded: isUnassignedExpanded,
                    onToggle: () => setState(() => isUnassignedExpanded = !isUnassignedExpanded),
                  ),
                ),
                if (isUnassignedExpanded)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) => _LibraryTile(msg: unassigned[i]),
                      childCount: unassigned.length,
                    ),
                  ),
              ],
              
              if (assigned.isNotEmpty && unassigned.isNotEmpty)
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

              if (assigned.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: CollapsibleHeader.secondary(
                    title: context.l10n.assignedMessagesHeader,
                    count: assigned.length,
                    isExpanded: isAssignedExpanded,
                    onToggle: () => setState(() => isAssignedExpanded = !isAssignedExpanded),
                  ),
                ),
                if (isAssignedExpanded)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                            (context, i) => _LibraryTile(msg: assigned[i]),
                        childCount: assigned.length
                    ),
                  ),
              ],
            ],
          ],
          
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

enum HeaderLevel {primary, secondary }

class CollapsibleHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final HeaderLevel level;
  final IconData? icon;
  final Widget? trailing;
  
  const CollapsibleHeader({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.level,
    this.icon,
    this.trailing,
  });
  
  factory CollapsibleHeader.primary({
   required String title,
   required IconData icon,
   required bool isExpanded,
   required VoidCallback onToggle,
   Widget? action, 
  }) {
    return CollapsibleHeader(
      level: HeaderLevel.primary,
      title: title,
      icon: icon,
      isExpanded: isExpanded,
      onToggle: onToggle,
      trailing: action,
    );
  }

  factory CollapsibleHeader.secondary({
    required String title,
    required int count,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return CollapsibleHeader(
      level: HeaderLevel.secondary,
      title: title,
      isExpanded: isExpanded,
      onToggle: onToggle,
      trailing: _CountBadge(count: count),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = level == HeaderLevel.primary;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: isPrimary
            ? const EdgeInsets.symmetric(vertical: 4)
            : const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_down
                  : (isPrimary ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right),
              size: isPrimary ? 20 : 16,
              color: isPrimary ? context.colorScheme.onSurfaceVariant : context.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 4),
            if (isPrimary && icon != null) ...[
              Icon(icon, size: 18, color: context.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: isPrimary ? 14 : 11,
                  color: isPrimary ? context.colorScheme.onSurfaceVariant : context.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(fontSize: 10, color: context.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _SlotMonitorHeader extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  
  const _SlotMonitorHeader({required this.isExpanded, required this.onToggle});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CollapsibleHeader.primary(
      title: context.l10n.liveSlotsHeader,
      icon: Icons.sync_alt,
      isExpanded: isExpanded,
      onToggle: onToggle,
      action: IconButton(
        icon: Icon(Icons.refresh, size: 20, color: context.colorScheme.primary),
        onPressed: () => ref.read(messageManagementProvider.notifier).syncFromVrc(),
        tooltip: context.l10n.tooltipSyncFromVrc,
      ),
    );
  }
}

class _LibraryHeader extends ConsumerWidget {
  final VrcMessageType type;
  final bool isExpanded;
  final VoidCallback onToggle;
  
  const _LibraryHeader({required this.type, required this.isExpanded, required this.onToggle});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CollapsibleHeader.primary(
      title: context.l10n.messageLibraryHeader,
      icon: Icons.library_books,
      isExpanded: isExpanded,
      onToggle: onToggle,
      action: IconButton(
        icon: Icon(Icons.add_circle_outline, size: 20, color: context.colorScheme.primary),
        onPressed: () => _showAddDialog(context, ref, type),
        tooltip: context.l10n.tooltipAddMessage,
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, VrcMessageType type) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.add_comment_outlined, size: 20),
            const SizedBox(width: 10),
            Text(context.l10n.dialogNewMessageTitle(type.toLocalizedString(context))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.dialogNewMessageDesc,
              style: TextStyle(fontSize: 12, color: context.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLength: 64,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: context.l10n.inputMessageHint,
                labelText: context.l10n.inputMessageLabel,
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.short_text),
                counterStyle: TextStyle(color: context.colorScheme.primary),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  _handleCreate(context, ref, controller.text.trim(), type);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.btnCancel, style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
          ),
          FilledButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _handleCreate(context, ref, controller.text.trim(), type);
              }
            },
            child: Text(context.l10n.btnCreateMessage),
          ),
        ],
      ),
    );
  }

  void _handleCreate(BuildContext context, WidgetRef ref, String text, VrcMessageType type) {
    ref.read(messageManagementProvider.notifier).createMessage(text, type);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.toastMessageAdded(type.toLocalizedString(context))),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _LibraryTile extends ConsumerWidget {
  final CustomMessage msg;
  const _LibraryTile({required this.msg});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => _showSlotPicker(context, ref, msg),
      title: Text(
        msg.content,
        style: const TextStyle(fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        msg.type.toLocalizedString(context).toUpperCase(),
        style: TextStyle(fontSize: 9, color: context.colorScheme.primary, letterSpacing: 1),
      ),
      trailing: msg.isActive
        ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.vrcColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(context.l10n.messageSlotLabel(msg.slotIndex! + 1), style: TextStyle(
            color: context.vrcColors.success,
            fontSize: 10,
            fontWeight: FontWeight.bold
          )),
      )
          : IconButton(
        icon: Icon(Icons.delete_outline, size: 18, color: context.colorScheme.error),
        onPressed: () => ref.read(messageManagementProvider.notifier).deleteMessage(msg.id!),
      ),
    );
  }
}

void _showSlotPicker(BuildContext context, WidgetRef ref, CustomMessage message) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SlotPickerContent(message: message, ref: ref),
  );
}

class SlotPickerContent extends StatelessWidget {
  final CustomMessage message;
  final WidgetRef ref;
  
  const SlotPickerContent({
    super.key,
    required this.message,
    required this.ref,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(message: message),
          const SizedBox(height: 16),
          _SlotGrid(message: message, ref: ref),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CustomMessage message;

  const _Header({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.slotPickerTitle(message.content),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.slotPickerCategory(message.type.toLocalizedString(context)),
          style: TextStyle(color: context.colorScheme.primary, fontSize: 10),
        ),
      ],
    );
  }
}

class _SlotGrid extends StatelessWidget {
  final CustomMessage message;
  final WidgetRef ref;

  const _SlotGrid({
    required this.message,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: 12,
      itemBuilder: (context, i) {
        return _SlotItem(
          index: i,
          isSelected: message.slotIndex == i,
          onTap: () => _onSlotTap(context, i),
        );
      },
    );
  }

  Future<void> _onSlotTap(BuildContext context, int index) async {
    try {
      Navigator.pop(context);
      await ref.read(messageManagementProvider.notifier).assignToVrcSlot(message, index);
    } catch (e) {
      _showErrorSnackBar(context, e.toString());
    }
  }
}

class _SlotItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _SlotItem({
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.outlineVariant,
          ),
        ),
        child: Center(
          child: Text(
            "${index + 1}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: context.colorScheme.error,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
