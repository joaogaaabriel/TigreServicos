import 'package:app_workmatch/model/UserModel.dart';
import 'package:sqflite/sqflite.dart';

import 'DatabaseHelper.dart';

class UserLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<dynamic>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('users');

    return result.map((e) => UserModel.fromMap?.call(e)).toList();
  }

  Future<void> insert(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> findByEmail(String email) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap?.call(result.first);
  }

  Future<UserModel?> findByEmailAndPassword(
    String email,
    String password,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap?.call(result.first);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
