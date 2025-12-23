import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String _dbName = "finance_1c.db";
  static const int _dbVersion = 1;

  static const String _tableName = "transactions";

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
    );
  }

  static Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT,
        comment TEXT,
        isIncome INTEGER
      )
    ''');
  }


  static Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(_tableName, row);
  }

  static Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    // SELECT * FROM transactions ORDER BY id DESC
    return await db.query(_tableName, orderBy: "id DESC");
  }

  static Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}