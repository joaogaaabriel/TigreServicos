import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._init();

  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE service_orders (
      id TEXT PRIMARY KEY,
      createdAt TEXT,
      customerId TEXT,
      customerName TEXT,
      serviceName TEXT,
      status TEXT,
      date TEXT,
      entryPhotoBase64 TEXT,
      exitPhotoBase64 TEXT,
      signatureBase64 TEXT,
      justification TEXT
    )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        token TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }
}
