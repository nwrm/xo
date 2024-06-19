import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tic_tac_toe.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE games(id INTEGER PRIMARY KEY, moves TEXT)',
        );
      },
    );
  }

  Future<void> insertGame(String moves) async {
    final db = await database;
    await db.insert(
      'games',
      {'moves': moves},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getGames() async {
    final db = await database;
    return db.query('games');
  }

  Future<List<Map<String, dynamic>>> getGamesInReverseOrder() async {
    final db = await database;
    return db.query('games', orderBy: 'id DESC');
  }

  Future<int> getTotalGameCount() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT COUNT(*) as count FROM games');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearGames() async {
    final db = await database;
    await db.execute('DELETE FROM games');
  }
}
