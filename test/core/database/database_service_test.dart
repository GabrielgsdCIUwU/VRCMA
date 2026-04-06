import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vrcma/core/database/database_service.dart';

void main() {
  late Database db;
  
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath);
  });
  
  tearDown(() async {
    await db.close();
  });
  
  group('DatabaseService Schema Tests', () {
    test('Database should create all required tables', () async {
      final dbService = DatabaseService();
      final database = await dbService.database;
      
      final tables = [
        'roles',
        'vrc_users',
        'profiles',
        'logs',
        'friend_roles',
        'profile_rules'
      ];
      
      for (var table in tables) {
        final result = await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [table]
        );
        expect(result.isNotEmpty, true, reason: 'Table $table should exist');
      }
    });
    
    test('Initial dummy data should be inserted (VIP, Admin, Blocked)', () async {
      final dbService = DatabaseService();
      final database = await dbService.database;
      
      final result = await database.query('roles');
      final roleNames = result.map((r) => r['name']).toList();
      
      expect(roleNames, containsAll(['VIP', 'Admin', 'Blocked']));
    });
  });
}