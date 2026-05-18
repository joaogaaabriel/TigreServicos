import 'package:app_serviceflow/app/core/services/ServiceOrder.dart';
import 'package:app_serviceflow/app/core/services/DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class ServiceOrderLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<ServiceOrder>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('service_orders');
    return result.map(ServiceOrder.fromMap).toList();
  }

  Future<void> insert(ServiceOrder order) async {
    final db = await _dbHelper.database;

    print('SALVANDO ORDEM...');
    print(order.toMap());

    await db.insert(
      'service_orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('ORDEM SALVA!');
  }

  Future<void> update(ServiceOrder order) async {
    final db = await _dbHelper.database;
    await db.update(
      'service_orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'service_orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
