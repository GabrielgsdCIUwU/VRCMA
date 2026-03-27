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
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        allowed_roles TEXT, -- Stored as comma-separated values
        target_languages TEXT,
        is_language_filter_enabled INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        action TEXT NOT NULL, -- 'ACCEPTED' or 'REJECTED'
        reason TEXT
      )
    ''');
  }
}