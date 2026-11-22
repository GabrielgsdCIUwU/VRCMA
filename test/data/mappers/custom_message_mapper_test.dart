import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/data/mappers/custom_message_mapper.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

void main() {
  group('CustomMessageMapper', () {
    final mapper = CustomMessageMapper();
    final date = DateTime(2026, 1, 1, 12);

    test('fromDatabaseMap should parse SQL row to Domain Entity correctly', () {
      final row = {
        'id': 5,
        'content': 'Hello from DB',
        'type': 'invite',
        'slot_index': 2,
        'last_updated': date.toIso8601String(),
      };

      final result = mapper.fromDatabaseMap(row);

      expect(result.id, 5);
      expect(result.content, 'Hello from DB');
      expect(result.slotIndex, 2);
      expect(result.lastUpdated, date);
    });

    test('toDatabaseMap should serialize Domain Entity to SQL map correctly', () {
      final entity = CustomMessage(
        id: 10,
        content: 'Saving to DB',
        type: VrcMessageType.requestResponse,
        slotIndex: null,
        lastUpdated: date,
      );

      final result = mapper.toDatabaseMap(entity);

      expect(result['id'], 10);
      expect(result['content'], 'Saving to DB');
      expect(result['type'], 'requestResponse');
      expect(result['slot_index'], isNull);
      expect(result['last_updated'], date.toIso8601String());
    });
  });
}