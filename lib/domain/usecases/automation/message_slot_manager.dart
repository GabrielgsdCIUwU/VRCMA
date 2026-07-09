import 'package:flutter/cupertino.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_message_repository.dart';

class MessageSlotManager {
  final IMessageRepository messageRepository;
  final IAutomationRepository automationRepository;
  
  MessageSlotManager({
    required this.messageRepository,
    required this.automationRepository,
  });
  
  Future<int?> prepareSlotForMessage(String userId, CustomMessage message) async {
    if (message.isActive && message.slotIndex != null) {
      return message.slotIndex!;
    }
    
    final slotToUse = await _determineNextAvailableSlot(message.type);
    
      final result = await automationRepository.updateVrcMessageSlot(
        userId: userId,
        slot: slotToUse,
        content: message.content,
        type: message.type,
        messageType: message.type.name,
      );
      
      return await result.fold(
          (failure) {
            debugPrint("Error preparing slot for message: ${failure.message}");
            return null;
          },
          (_) async {
            await messageRepository.updateSlot(message.id!, slotToUse, message.type);
            return slotToUse;
          }
      );
  }
  
  Future<int> _determineNextAvailableSlot(VrcMessageType inviteType) async {
    final activeMessages = await messageRepository.getActiveSlots(inviteType);
    
    for (int i = 0; i < 12; i++) {
      if (!activeMessages.any((m) => m.slotIndex == i)) return i;
    }
    
    if (activeMessages.isNotEmpty) {
      activeMessages.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
      return activeMessages.first.slotIndex!;
    }
    return 0;
  }
}