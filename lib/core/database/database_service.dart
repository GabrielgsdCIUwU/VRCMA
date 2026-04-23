import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const _dbname = 'vrcma_database.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbname);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        try {
          await _onCreate(db, version);
          await _createDummyData(db, version);
        } catch (e) {
          debugPrint("Error creating database: $e");
          rethrow;
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE vrc_users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        avatar_url TEXT,
        last_updated TEXT NOT NULL
      )
    ''' );

    await db.execute('''
      CREATE TABLE custom_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        type TEXT NOT NULL, -- 'invite', 'response', 'request', 'requestResponse'
        slot_index INTEGER, -- 0 to 11, NULL if not active in VRChat
        last_updated TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_languages TEXT,
        is_language_filter_enabled INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        user_local_id INTEGER NOT NULL,
        invitation_type TEXT NOT NULL, -- 'INVITE' or 'REQUEST'
        action TEXT NOT NULL, -- 'ACCEPT' or 'REJECT'
        applied_rule TEXT,
        FOREIGN KEY (user_local_id) REFERENCES vrc_users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE friend_roles (
        vrc_user_id INTEGER NOT NULL,
        role_id INTEGER NOT NULL,
        PRIMARY KEY (vrc_user_id, role_id),
        FOREIGN KEY (vrc_user_id) REFERENCES vrc_users (id) ON DELETE CASCADE,
        FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE profile_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        role_id INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        action TEXT NOT NULL, -- 'ACCEPT' o 'REJECT'
        fallback_group INTEGER,
        invite_message_id INTEGER,
        request_message_id INTEGER,
        FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE,
        FOREIGN KEY (invite_message_id) REFERENCES custom_messages (id) ON DELETE SET NULL,
        FOREIGN KEY (request_message_id) REFERENCES custom_messages (id) ON DELETE SET NULL
      )
    ''');
  }
  
  Future<void> _createDummyData(Database db, int version) async {
    await db.insert('roles', {'name': 'VIP'});
    await db.insert('roles', {'name': 'Admin'});
    await db.insert('roles', {'name': 'Blocked'});
  }
}