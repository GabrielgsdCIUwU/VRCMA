import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vrcma/data/repositories/log_repository_imp.dart';

void main() {
  late Database db;
  late LogRepositoryImp repository;
  
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  
  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE vrc_users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL UNIQUE,
                display_name TEXT NOT NULL,
                avatar_url TEXT,
                last_updated TEXT NOT NULL
              )
            ''');
            await db.execute('''
              CREATE TABLE logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT NOT NULL,
                user_local_id INTEGER NOT NULL,
                invitation_type TEXT NOT NULL,
                action TEXT NOT NULL,
                applied_rule TEXT,
                FOREIGN KEY (user_local_id) REFERENCES vrc_users (id) ON DELETE CASCADE
              )
            ''');
          },
        ));
    repository = LogRepositoryImp(db);
  });
  
  tearDown(() async {
    await db.close();
  });
  
  group('LogRepositoryImp Tests', () {
    test('saveLog should insert a new user and log correctly', () async {
      await repository.saveLog(
        vrcUserId: 'usr_123',
        displayName: 'TestUser',
        avatarUrl: 'http://image.png',
        invitationType: 'INVITE',
        action: 'ACCEPTED',
        appliedRule: 'VIP Rule',
      );
      
      final users = await db.query('vrc_users');
      expect(users.length, 1);
      expect(users.first['user_id'], 'usr_123');
      
      final logs = await db.query('logs');
      expect(logs.length, 1);
      expect(logs.first['action'], 'ACCEPTED');
      expect(logs.first['user_local_id'], users.first['id']);
    });
    
    test('saveLog should update existing user (ON CONFLICT DO UPDATE) and add a second log', () async {
      await repository.saveLog(
        vrcUserId: 'usr_123',
        displayName: 'OldName',
        avatarUrl: 'http://old.png',
        invitationType: 'INVITE',
        action: 'REJECTED',
        appliedRule: 'Blocked Rule',
      );
      await repository.saveLog(
        vrcUserId: 'usr_123',
        displayName: 'NewName',
        avatarUrl: 'http://new.png',
        invitationType: 'REQUEST',
        action: 'ACCEPTED',
        appliedRule: 'Admin Rule',
      );
      
      final users = await db.query('vrc_users');
      expect(users.length, 1, reason: 'Should not create a duplicate user');
      expect(users.first['display_name'], 'NewName', reason: 'Should update the display name');
      
      final logs = await db.query('logs');
      expect(logs.length, 2, reason: 'Should have two separate logs');
    });
    
    test('getLogs should retrieve logs sorted by timestamp DESC and map entities correctly', () async {
      await repository.saveLog(
        vrcUserId: 'usr_1',
        displayName: 'User1',
        avatarUrl: '',
        invitationType: 'INVITE',
        action: 'REJECTED',
        appliedRule: 'Rule1'
      );
      await Future.delayed(const Duration(milliseconds: 100));
      await repository.saveLog(
          vrcUserId: 'usr_2',
          displayName: 'User2',
          avatarUrl: '',
          invitationType: 'REQUEST',
          action: 'ACCEPTED',
          appliedRule: 'Rule2'
      );
      
      final logs = await repository.getLogs();
      
      expect(logs.length, 2);
      expect(logs[0].senderName, 'User2');
      expect(logs[0].action, 'ACCEPTED');
      expect(logs[1].senderName, 'User1');
    });
    
    test('getLogs should filter by search query (display_name or applied_rule)', () async {
      await repository.saveLog(
          vrcUserId: 'usr_1',
          displayName: 'Gabrielgsd',
          avatarUrl: '',
          invitationType: 'INVITE',
          action: 'ACCEPTED',
          appliedRule: 'Close Friends'
      );
      await repository.saveLog(
          vrcUserId: 'usr_2',
          displayName: 'Talk is cheap, send patches.',
          avatarUrl: '',
          invitationType: 'INVITE',
          action: 'REJECTED',
          appliedRule: 'No'
      );
      
      final searchByName = await repository.getLogs(search: 'Gab');
      expect(searchByName.length, 1);
      expect(searchByName.first.senderName, 'Gabrielgsd');
      
      final searchByRule = await repository.getLogs(search: 'No');
      expect(searchByRule.length, 1);
      expect(searchByRule.first.senderName, 'Talk is cheap, send patches.');
    });
  });
}