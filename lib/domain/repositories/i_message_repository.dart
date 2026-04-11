import 'package:vrcma/domain/entities/automation/vrc_message.dart';

abstract class IMessageRepository {
  Future<List<CustomMessage>> getMessagesByType(VrcMessageType type);
  Future<int> saveMessage(CustomMessage message);
  Future<void> deleteMessage(int id);
  Future<void> updateSlot(int messageId, int? slotIndex);
  Future<List<CustomMessage>> getActiveSlots(VrcMessageType type);
  Future<List<CustomMessage>> getAllMessages();
}