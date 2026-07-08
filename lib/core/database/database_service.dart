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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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

    await db.execute('''
      CREATE TABLE role_automations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trigger_type TEXT NOT NULL,
        target_value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE automation_assigned_roles (
        automation_id INTEGER NOT NULL,
        role_id INTEGER NOT NULL,
        PRIMARY KEY (automation_id, role_id),
        FOREIGN KEY (automation_id) REFERENCES role_automations (id) ON DELETE CASCADE,
        FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE status_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        is_active INTEGER DEFAULT 0,
        fallback_status TEXT NOT NULL,
        fallback_template TEXT,
        last_applied_status TEXT,
        last_applied_message TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE status_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        target_status TEXT NOT NULL,
        message_template TEXT,
        condition_type TEXT NOT NULL,
        operator TEXT NOT NULL,
        condition_value TEXT,
        FOREIGN KEY (profile_id) REFERENCES status_profiles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_logs_user_local_id ON logs (user_local_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_friend_roles_vrc_user_id ON friend_roles (vrc_user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_friend_roles_role_id ON friend_roles (role_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_profile_rules_profile_id ON profile_rules (profile_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_profile_rules_role_id ON profile_rules (role_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_automation_assigned_roles_automation_id ON automation_assigned_roles (automation_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_status_rules_profile_priority ON status_rules (profile_id, priority)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_status_profiles_active ON status_profiles (is_active)');
  }
  
  Future<void> _createDummyData(Database db, int version) async {
    final now = DateTime.now().toIso8601String();
    
    final vipId = await db.insert('roles', {'name': 'VIP'});
    final adminId = await db.insert('roles', {'name': 'Admin'});
    final blockedId = await db.insert('roles', {'name': 'Blocked'});
    
    final vipRequestInviteId = await db.insert('custom_messages', {
      'content': 'Come on in! You are always welcome :D',
      'type': 'invite',
      'last_updated': now,
    });
    final vipInviteId = await db.insert('custom_messages', {
      'content': 'Thanks for the invite! Joining right now :D',
      'type': 'request',
      'last_updated': now,
    });

    final blockedRejectInviteId = await db.insert('custom_messages', {
      'content': 'I am currently in Do Not Disturb mode!',
      'type': 'response',
      'last_updated': now,
    });
    final blockedRejectRequestId = await db.insert('custom_messages', {
      'content': 'I am currently in Do Not Disturb mode!',
      'type': 'requestResponse',
      'last_updated': now,
    });

    final profileId = await db.insert('profiles', {
      'name': 'Streamer / Safe Mode Example',
      'is_active': 0,
      'is_language_filter_enabled': 0
    });


    await db.insert('profile_rules', {
      'profile_id': profileId,
      'role_id': blockedId,
      'priority': 0,
      'action': 'REJECT',
      'invite_message_id': blockedRejectInviteId,
      'request_message_id': blockedRejectRequestId,
    });

    await db.insert('profile_rules', {
      'profile_id': profileId,
      'role_id': adminId,
      'priority': 1,
      'action': 'ACCEPT',
    });

    await db.insert('profile_rules', {
      'profile_id': profileId,
      'role_id': vipId,
      'priority': 2,
      'action': 'ACCEPT',
      'invite_message_id': vipInviteId, 
      'request_message_id': vipRequestInviteId,
    });
  }
}