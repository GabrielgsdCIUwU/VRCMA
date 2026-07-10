import 'package:flutter_test/flutter_test.dart';
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
      
      final expectedTables = [
        'app_configurations',
        'roles',
        'vrc_users',
        'custom_messages',
        'profiles',
        'logs',
        'friend_roles',
        'profile_rules',
        'role_automations',
        'automation_assigned_roles',
        'status_profiles',
        'status_rules',
      ];
      for (var table in expectedTables) {
        final result = await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [table]
        );
        expect(result.isNotEmpty, true, reason: 'Table $table should exist');
      }
    });
    
    test('Initial seeded configurations and roloes should be correctly populated', () async {
      final dbService = DatabaseService();
      final database = await dbService.database;
      
      final configResults = await database.query('app_configurations');
      final configKeys = configResults.map((c) => c['config_key']).toList();
      expect(configKeys, containsAll(['selected_locale_code', 'bg_automation_enabled', 'app_theme_mode']));

      final roleResults = await database.query('roles');
      final roleNames = roleResults.map((r) => r['name']).toList();
      expect(roleNames, containsAll(['VIP', 'Admin', 'Blocked']));
    });
  });
}