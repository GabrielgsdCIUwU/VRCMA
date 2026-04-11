import 'package:sqflite/sqflite.dart';
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

    return maps.map((m) => _mapToEntity(m)).toList();
  }

  @override
  Future<int> saveMessage(CustomMessage message) async {
    final data = {
      if (message.id != null) 'id': message.id,
      'content': message.content,
      'type': message.type.name,
      'slot_index': message.slotIndex,
      'last_updated': message.lastUpdated.toIso8601String(),
    };

    return await _db.insert(
      'custom_messages',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  @override
  Future<void> updateSlot(int messageId, int? slotIndex) async {
    await _db.transaction((txn) async {
      if (slotIndex != null) {
        await txn.update(
          'custom_messages',
          {'slot_index': null},
          where: 'slot_index = ?',
          whereArgs: [slotIndex]
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

  CustomMessage _mapToEntity(Map<String, dynamic> map) {
    return CustomMessage(
      id: map['id'] as int,
      content: map['content'] as String,
      type: VrcMessageType.fromString(map['type'] as String),
      slotIndex: map['slot_index'] as int?,
      lastUpdated: DateTime.parse(map['last_updated'] as String),
    );
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

    return messageMap.map((m) => _mapToEntity(m)).toList();
  }
  
  @override
  Future<List<CustomMessage>> getAllMessages() async {
    final maps = await _db.query('custom_messages', orderBy: 'last_updated DESC');
    return maps.map((m) => _mapToEntity(m)).toList();
  }
}