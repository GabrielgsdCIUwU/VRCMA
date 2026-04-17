import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/usecases/messages/sync_messages_use_case.dart';
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
    
    final timeSinceUpdate = DateTime.now().difference(message.lastUpdated);
    if (message.isActive && timeSinceUpdate.inMinutes < 60) {
      final remaining = 60 - timeSinceUpdate.inMinutes;
      state = AsyncValue.error(RateLimitFailure(remaining), StackTrace.current);
      return;
    }
    
   state = const AsyncLoading();
    final result = await vrcRepo.updateVrcMessageSlot(
      userId: auth.id,
      content: message.content,
      slot: slotIndex,
      type: message.type,
      messageType: message.type.name
    );
    
    result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (_) async {
          await repo.updateSlot(message.id!, slotIndex, message.type);
          ref.invalidateSelf();
        }
    );
  }
  
  Future<void> unassignSlot(int messageId, VrcMessageType type) async {
    final repo = await ref.read(messageRepositoryProvider.future);
    await repo.updateSlot(messageId, null, type);
    ref.invalidateSelf();
  }
  
  Future<void> syncFromVrc() async {
    state = const AsyncLoading();
    
    final auth = await ref.read(authStateProvider.future);
    if (auth == null) return;
    
    final vrcRepo = await ref.read(automationRepositoryProvider.future);
    final localRepo = await ref.read(messageRepositoryProvider.future);
    
    final useCase = SyncMessagesUseCase(vrcRepo, localRepo);
    final result = await useCase.execute(auth.id);
    
    result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => ref.invalidateSelf(),
    );
  }
}