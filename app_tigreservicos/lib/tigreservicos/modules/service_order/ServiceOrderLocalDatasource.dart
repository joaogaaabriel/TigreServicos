import '../../core/services/DatabaseHelper.dart';
import 'ServiceOderModel.dart';

class ServiceOrderLocalDatasource {
  ServiceOrderLocalDatasource(this._db);

  final DatabaseHelper _db;

  static const tableName = 'service_orders';

  Future<void> insert(ServiceOrderModel order) async {
    final db = await _db.database;

    await db.insert(
      tableName,
      order.toMap(),
    );
  }

  Future<void> update(ServiceOrderModel order) async {
    final db = await _db.database;

    await db.update(
      tableName,
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db.database;

    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ServiceOrderModel>> getAll() async {
    final db = await _db.database;

    final result = await db.query(tableName);

    return result
        .map((map) => ServiceOrderModel.fromMap(map))
        .toList();
  }

  Future<List<ServiceOrderModel>> getToday() async {
    final all = await getAll();
    final now = DateTime.now();

    return all.where((order) {
      return order.date.year == now.year &&
          order.date.month == now.month &&
          order.date.day == now.day;
    }).toList();
  }
}