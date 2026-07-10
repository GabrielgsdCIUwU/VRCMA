import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vrcma/data/repositories/message_repository_imp.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

void main() {
  late Database db;
  late MessageRepositoryImp repository;
  
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  
  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE custom_messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            type TEXT NOT NULL,
            slot_index INTEGER,
            last_updated TEXT NOT NULL
          )
        ''');
      }
    ));
    repository = MessageRepositoryImp(db);
  });
  
  tearDown(() async {
    await db.close();
  });
  
  group('MessageRepositoryImp', () {
    final tMessage = CustomMessage(
      content: 'Hello World',
      type: VrcMessageType.invite,
      lastUpdated: DateTime.now(),
    );
    
    test('Should save and retrieve a message correctly', () async {
      final id = await repository.saveMessage(tMessage);
      final messages = await repository.getAllMessages();
      
      expect(id, isA<int>());
      expect(messages.length, 1);
      expect(messages.first.content, 'Hello World');
      expect(messages.first.type, VrcMessageType.invite);
    });
    
    test('updateSlot should unset existing slot and assign to the new one', () async {
      final id1 = await repository.saveMessage(CustomMessage(
        content: 'Old Slot 0', type: VrcMessageType.invite, slotIndex: 0, lastUpdated: DateTime.now(),
      ));
      final id2 = await repository.saveMessage(CustomMessage(
        content: 'I want Slot 0', type: VrcMessageType.invite, slotIndex: null, lastUpdated: DateTime.now(),
      ));

      await repository.updateSlot(id2, 0, VrcMessageType.invite);
      
      final slots = await repository.getActiveSlots(VrcMessageType.invite);
      final all = await repository.getAllMessages();
      
      expect(slots.length, 1);
      expect(slots.first.id, id2);
      
      final oldMessage = all.firstWhere((m) => m.id == id1);
      expect(oldMessage.slotIndex, isNull);
    });
    
    test('Should delete message correctly', () async {
      final id = await repository.saveMessage(tMessage);
      
      await repository.deleteMessage(id);
      final messages = await repository.getAllMessages();
      
      expect(messages.isEmpty, true);
    });
  });
}