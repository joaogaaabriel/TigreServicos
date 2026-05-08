import 'package:app_serviceflow/app/core/services/ServiceOrder.dart';
import 'package:app_serviceflow/app/core/services/DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';

/// ---------------------------------------------------------------------------
/// ServiceOrderLocalDataSource
/// ---------------------------------------------------------------------------
/// Responsável por gerenciar TODAS as operações de persistência local
/// relacionadas à entidade [ServiceOrder], utilizando SQLite.
///
/// Papel na arquitetura:
/// - É a camada mais próxima do banco de dados
/// - Executa queries SQL e operações CRUD
/// - NÃO contém regras de negócio
///
/// Essa classe é consumida pelo Repository.
/// ---------------------------------------------------------------------------
class ServiceOrderLocalDataSource {
  /// Instância do helper responsável por gerenciar o SQLite
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ---------------------------------------------------------------------------
  // READ - Buscar todas as ordens de serviço
  // ---------------------------------------------------------------------------
  /// Retorna todas as ordens de serviço armazenadas no SQLite.
  ///
  /// Fluxo:
  /// 1. Abre conexão com banco
  /// 2. Executa query na tabela `service_orders`
  /// 3. Converte resultado (Map) para objetos [ServiceOrder]
  Future<List<ServiceOrder>> getAll() async {
    final db = await _dbHelper.database;

    // Consulta simples sem filtros (SELECT * FROM service_orders)
    final result = await db.query('service_orders');

    // Converte cada linha do banco para entidade ServiceOrder
    return result.map(ServiceOrder.fromMap).toList();
  }

  // ---------------------------------------------------------------------------
  // CREATE - Inserir ordem de serviço
  // ---------------------------------------------------------------------------
  /// Insere uma nova ordem de serviço no banco local.
  ///
  /// Estratégia:
  /// - Usa `ConflictAlgorithm.replace` para substituir caso já exista ID
  Future<void> insert(ServiceOrder order) async {
    final db = await _dbHelper.database;

    await db.insert(
      'service_orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------------------------------------------------------------------
  // UPDATE - Atualizar ordem existente
  // ---------------------------------------------------------------------------
  /// Atualiza uma ordem de serviço existente no banco.
  ///
  /// Critério de atualização:
  /// - Baseado no campo `id`
  Future<void> update(ServiceOrder order) async {
    final db = await _dbHelper.database;

    await db.update(
      'service_orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE - Remover ordem de serviço
  // ---------------------------------------------------------------------------
  /// Remove uma ordem de serviço do banco local com base no ID.
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;

    await db.delete('service_orders', where: 'id = ?', whereArgs: [id]);
  }
}
