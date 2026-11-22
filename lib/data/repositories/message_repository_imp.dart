import 'package:sqflite/sqflite.dart';
import 'package:vrcma/data/mappers/custom_message_mapper.dart';
import 'package:vrcma/domain/repositories/i_message_repository.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

class MessageRepositoryImp implements IMessageRepository {
  final Database _db;
  MessageRepositoryImp(this._db);

  @override
  Future<List<CustomMessage>> getMessagesByType(VrcMessageType type) async {
    final maps = await _db.query(
      'custom_messages',
      where: 'type = ?',
      whereArgs: [type.value],
      orderBy: 'last_updated DESC',
    );

    return maps.map((m) => CustomMessageMapper().fromDatabaseMap(m)).toList();
  }

  @override
  Future<int> saveMessage(CustomMessage message) async {
    final data = CustomMessageMapper().toDatabaseMap(message);
    return await _db.insert(
      'custom_messages',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  @override
  Future<void> updateSlot(int messageId, int? slotIndex, VrcMessageType type) async {
    await _db.transaction((txn) async {
      if (slotIndex != null) {
        await txn.update(
          'custom_messages',
          {'slot_index': null},
          where: 'slot_index = ? AND type = ?',
          whereArgs: [slotIndex, type.name]
        );
      }

      await txn.update(
        'custom_messages',
        {'slot_index': slotIndex, 'last_updated': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [messageId]
      );
    });
  }

  @override
  Future<void> deleteMessage(int id) async {
    await _db.delete(
      'custom_messages',
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  @override
  Future<List<CustomMessage>> getActiveSlots(VrcMessageType type) async {
    final messageMap = await _db.query(
      'custom_messages',
      where: 'type = ? AND slot_index IS NOT NULL',
      whereArgs: [type.value],
      orderBy: 'slot_index ASC'
    );

    return messageMap.map((m) => CustomMessageMapper().fromDatabaseMap(m)).toList();
  }
  
  @override
  Future<List<CustomMessage>> getAllMessages() async {
    final maps = await _db.query('custom_messages', orderBy: 'last_updated DESC');
    return maps.map((m) => CustomMessageMapper().fromDatabaseMap(m)).toList();
  }
}