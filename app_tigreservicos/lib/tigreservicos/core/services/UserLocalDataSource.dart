import 'package:sqflite/sqflite.dart';

import 'DatabaseHelper.dart';
import '../../modules/auth/UserModel.dart';

/// ---------------------------------------------------------------------------
/// UserLocalDataSource
/// ---------------------------------------------------------------------------
/// Responsável por gerenciar todas as operações de persistência local
/// relacionadas ao usuário.
/// ---------------------------------------------------------------------------
class UserLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<UserModel>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('users');
    return result.map(UserModel.fromMap).toList();
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
    return UserModel.fromMap(result.first);
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
    return UserModel.fromMap(result.first);
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
