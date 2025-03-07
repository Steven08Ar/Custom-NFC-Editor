import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'locks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE locks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT UNIQUE,
            name TEXT,
            encryptionKey TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertLock(String uuid, String name, String encryptionKey) async {
    final db = await instance.database;
    return await db.insert('locks', {
      'uuid': uuid,
      'name': name,
      'encryptionKey': encryptionKey
    });
  }

  Future<Map<String, dynamic>?> getLockByUUID(String uuid) async {
    final db = await instance.database;
    final result = await db.query('locks', where: 'uuid = ?', whereArgs: [uuid]);
    return result.isNotEmpty ? result.first : null;
  }
}