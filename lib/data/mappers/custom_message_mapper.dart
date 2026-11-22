import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/mappers/i_database_mapper.dart';

class CustomMessageMapper implements IDatabaseMapper<CustomMessage> {
  @override
  CustomMessage fromDatabaseMap(Map<String, dynamic> row) {
    return CustomMessage(
      id: row['id'] as int?,
      content: row['content'] as String,
      type: VrcMessageType.fromString(row['type'] as String),
      slotIndex: row['slot_index'] as int?,
      lastUpdated: DateTime.parse(row['last_updated'] as String),
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(CustomMessage message) {
    return {
      if (message.id != null) 'id': message.id,
      'content': message.content,
      'type': message.type.name,
      'slot_index': message.slotIndex,
      'last_updated': message.lastUpdated.toIso8601String(),
    };
  }
}