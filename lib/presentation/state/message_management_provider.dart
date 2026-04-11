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
    return repo.getMessagesByType(VrcMessageType.invite);
  }
  
  Future<void> changeType(VrcMessageType type) async {
    state = const AsyncLoading();
    final repo = await ref.read(messageRepositoryProvider.future);
    state = await AsyncValue.guard(() => repo.getMessagesByType(type));
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
}