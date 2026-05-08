import 'package:app_serviceflow/app/core/services/DatabaseHelper.dart';
import 'package:app_serviceflow/app/modules/auth/UserModel.dart';
import 'package:sqflite/sqflite.dart';

/// ---------------------------------------------------------------------------
/// UserLocalDataSource
/// ---------------------------------------------------------------------------
/// Responsável por gerenciar todas as operações de persistência local
/// relacionadas ao usuário.
///
/// Essa classe atua diretamente na camada de banco de dados SQLite,
/// sem conter regras de negócio.
///
/// Responsabilidades:
/// - Inserir usuários
/// - Buscar usuários
/// - Validar login local (email + senha)
/// - Remover usuários
///
/// Essa camada é consumida pelo Repository de Auth/User.
/// ---------------------------------------------------------------------------
class UserLocalDataSource {
  /// Instância do helper do SQLite
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ---------------------------------------------------------
  // ------------------
  // READ - Buscar todos os usuários
  // ---------------------------------------------------------------------------
  /// Retorna todos os usuários cadastrados no banco local.
  Future<List<UserModel>> getAll() async {
    final db = await _dbHelper.database;

    // SELECT * FROM users
    final result = await db.query('users');

    // Converte cada registro em UserModel
    return result.map(UserModel.fromMap).toList();
  }

  // ---------------------------------------------------------------------------
  // CREATE - Inserir usuário
  // ---------------------------------------------------------------------------
  /// Insere um novo usuário no banco local.
  ///
  /// Estratégia:
  /// - Usa ConflictAlgorithm.replace para substituir caso já exista o ID
  Future<void> insert(UserModel user) async {
    final db = await _dbHelper.database;

    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------------------------------------------------------------------
  // READ - Buscar por email
  // ---------------------------------------------------------------------------
  /// Busca um usuário pelo email.
  ///
  /// Retorna:
  /// - UserModel se encontrado
  /// - null se não existir
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

  // ---------------------------------------------------------------------------
  // AUTH - Login local (email + senha)
  // ---------------------------------------------------------------------------
  /// Valida credenciais do usuário localmente.
  ///
  /// IMPORTANTE:
  /// - Este método NÃO é seguro para produção (senha em texto puro)
  /// - Ideal para modo offline ou protótipo
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

  // ---------------------------------------------------------------------------
  // DELETE - Remover usuário
  // ---------------------------------------------------------------------------
  /// Remove um usuário pelo ID.
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;

    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
