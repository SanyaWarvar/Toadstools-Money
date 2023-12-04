import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:test/Account.dart';
import 'package:test/Transaction.dart' as t;

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "TransactionDB.db";

  static Future<Database> _getDB() async {
    return openDatabase(
        join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) async => await db.execute(
            "CREATE TABLE TransactionDB(id INTEGER PRIMARY KEY, category TEXT NOT NULL, description TEXT, amount INTEGER, date TEXT NOT NULL);"),
        version: _version);
  }

  static Future<int> addTransaction(t.Transaction transaction) async {
    final db = await _getDB();
    return await db.insert("TransactionDB", transaction.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateTransaction(t.Transaction transaction) async {
    final db = await _getDB();
    return await db.update("TransactionDB", transaction.toJson(),
        where: 'id = ?',
        whereArgs: [transaction.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteTransaction(t.Transaction transaction) async {
    final db = await _getDB();
    return await db.delete(
      "TransactionDB",
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  static Future<List<t.Transaction>?> getAllTransaction() async {
    final db = await _getDB();

    final List<Map<String, dynamic>> maps = await db.query("TransactionDB");

    for (var element in maps){
      print(element);
    }

    if (maps.isEmpty) {
      return null;
    }

    return List.generate(maps.length, (index) => t.Transaction.fromJson(maps[index]));
  }
}