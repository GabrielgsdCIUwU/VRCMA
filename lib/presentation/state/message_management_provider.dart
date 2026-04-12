import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/automation_provider.dart';

part 'message_management_provider.g.dart';

@riverpod
class MessageManagement extends _$MessageManagement {
  @override
  FutureOr<List<CustomMessage>> build() async {
    final repo = await ref.watch(messageRepositoryProvider.future);
    return repo.getAllMessages();
  }
  
  Future<void> createMessage(String content, VrcMessageType type) async {
    final repo = await ref.read(messageRepositoryProvider.future);
    final newMessage = CustomMessage(
      content: content,
      type: type,
      lastUpdated: DateTime.now()
    );
    await repo.saveMessage(newMessage);
    ref.invalidateSelf();
  }
  
  Future<void> deleteMessage(int id) async {
    final repo = await ref.read(messageRepositoryProvider.future);
    await repo.deleteMessage(id);
    ref.invalidateSelf();
  }
  
  Future<void> assignToVrcSlot(CustomMessage message, int slotIndex) async {
    final repo = await ref.read(messageRepositoryProvider.future);
    final auth = await ref.read(authStateProvider.future);
    final vrcRepo = await ref.read(automationRepositoryProvider.future);
    
    if (auth == null) return;
    
    await repo.updateSlot(message.id!, slotIndex);
    
    try {
      await vrcRepo.updateVrcMessageSlot(
        userId: auth.id,
        content: message.content,
        slot: slotIndex,
        type: message.type,
        messageType: message.type.name
      );
    } catch (e) {
      rethrow;
    } finally {
      ref.invalidateSelf();
    }
  }
  
  Future<void> unassignSlot(int messageId) async {
    final repo = await ref.read(messageRepositoryProvider.future);
    await repo.updateSlot(messageId, null);
    ref.invalidateSelf();
  }
  
  Future<void> syncFromVrc() async {
    state = const AsyncLoading();
    
    final auth = await ref.read(authStateProvider.future);
    if (auth == null) return;
    
    final vrcRepo = await ref.read(automationRepositoryProvider.future);
    final localRepo = await ref.read(messageRepositoryProvider.future);
    
    try {
      for (var type in VrcMessageType.values) {
        final List<VrcRemoteMessage> remoteMessages = await vrcRepo.getRemoteVrcMessages(auth.id, type);
        final allLocalMessages = await localRepo.getMessagesByType(type);
        
        for (var remote in remoteMessages) {
          final existing = allLocalMessages.firstWhereOrNull((m) => m.content == remote.content);
          
          if (existing != null) {
            await localRepo.updateSlot(existing.id!, remote.slot);
          } else if (remote.content.isNotEmpty) {
            await localRepo.saveMessage(CustomMessage(
              content: remote.content,
              type: remote.type,
              slotIndex: remote.slot,
              lastUpdated: remote.lastUpdated
            ));
          }
        }
      }
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncValue.error("Error syncing: $e", StackTrace.current);
    }
  }
}