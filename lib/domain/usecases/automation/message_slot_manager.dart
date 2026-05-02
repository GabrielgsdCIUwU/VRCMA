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
  
  Future<int> prepareSlotForMessage(String userId, CustomMessage message) async {
    if (message.isActive && message.slotIndex != null) {
      return message.slotIndex!;
    }
    
    final slotToUse = await _determineNextAvailableSlot(message.type);
    
    try {
      await automationRepository.updateVrcMessageSlot(
        userId: userId,
        slot: slotToUse,
        content: message.content,
        type: message.type,
        messageType: message.type.name,
      );
      
      await messageRepository.updateSlot(message.id!, slotToUse, message.type);
      
      return slotToUse;
    } catch (e) {
      debugPrint("Error preparing slot for message: $e");
      return 0;
    }
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