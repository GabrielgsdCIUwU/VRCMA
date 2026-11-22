import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_message_repository.dart';

class SyncMessagesUseCase {
  final IAutomationRepository _remoteRepo;
  final IMessageRepository _localRepo;
  
  SyncMessagesUseCase(this._remoteRepo, this._localRepo);
  
  Future<Either<Failure, void>> execute(String userId) async {
    try {
      for (var type in VrcMessageType.values) {
        final remoteMessages = await _remoteRepo.getRemoteVrcMessages(userId, type);
        final allLocalMessages = await _localRepo.getMessagesByType(type);
        
        for (var remote in remoteMessages) {
          final existing = allLocalMessages.firstWhereOrNull((m) => m.content == remote.content);
          
          if (existing != null) {
            await _localRepo.updateSlot(existing.id!, remote.slot, type);
          } else if (remote.content.isNotEmpty) {
            await _localRepo.saveMessage(CustomMessage(
              content: remote.content,
              type: remote.type,
              slotIndex: remote.slot,
              lastUpdated: remote.lastUpdated
            ));
          }
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure("Error syncing messages: $e"));
    }
  }
}