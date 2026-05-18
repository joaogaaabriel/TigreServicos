import 'package:app_serviceflow/app/core/services/DatabaseHelper.dart';
import 'package:app_serviceflow/app/core/services/OfflineSync.dart';
import 'package:app_serviceflow/app/modules/service_order/CustomerModel.dart';
import 'package:app_serviceflow/app/modules/service_order/ServiceOderModel.dart';
import 'package:sqflite/sqflite.dart';

class ServiceOrderRepository {
  ServiceOrderRepository({
    required DatabaseHelper databaseHelper,
    required OfflineSync offlineSync,
  })  : _databaseHelper = databaseHelper,
        _offlineSync = offlineSync;

  final DatabaseHelper _databaseHelper;
  final OfflineSync _offlineSync;

  Future<List<ServiceOrderModel>> getAll() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'service_orders',
      orderBy: 'createdAt DESC',
    );

    return result
        .map((map) => ServiceOrderModel.fromMap(map))
        .toList();
  }

  Future<void> insert(ServiceOrderModel item) async {
    final db = await _databaseHelper.database;

    print('SALVANDO ORDEM...');
    print(item.toMap());

    await db.insert(
      'service_orders',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('ORDEM SALVA!');
  }

  Future<void> update(ServiceOrderModel item) async {
    final db = await _databaseHelper.database;

    await db.update(
      'service_orders',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;

    await db.delete(
      'service_orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  List<CustomerModel> getMockedCustomers() {
    final now = DateTime.now();

    return [
      CustomerModel(
        id: 'c1',
        createdAt: now,
        name: 'Maria Aparecida Silva',
        serviceName: 'Instalacao eletrica residencial',
      ),
      CustomerModel(
        id: 'c2',
        createdAt: now,
        name: 'Joao Carlos Mendes',
        serviceName: 'Manutencao de quadro de energia',
      ),
      CustomerModel(
        id: 'c3',
        createdAt: now,
        name: 'Restaurante Sabor & Arte',
        serviceName: 'Vistoria em circuito de cozinha',
      ),
      CustomerModel(
        id: 'c4',
        createdAt: now,
        name: 'Beatriz Oliveira',
        serviceName: 'Troca de tomadas e testes finais',
      ),
    ];
  }

  Future<List<ServiceOrderModel>> getTodayOrders() async {
    final allOrders = await getAll();

    final now = DateTime.now();

    return allOrders.where((order) {
      return order.date.year == now.year &&
          order.date.month == now.month &&
          order.date.day == now.day;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<bool> hasAttendanceToday(String customerId) async {
    final todayOrders = await getTodayOrders();

    return todayOrders.any(
          (order) => order.customerId == customerId,
    );
  }

  Future<void> saveRealizedOrder({
    required CustomerModel customer,
    required String entryPhotoBase64,
    required String exitPhotoBase64,
    required String signatureBase64,
  }) async {
    final order = ServiceOrderModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      customerId: customer.id ?? '',
      customerName: customer.name,
      serviceName: customer.serviceName,
      status: ServiceOrderStatus.realized,
      date: DateTime.now(),
      entryPhotoBase64: entryPhotoBase64,
      exitPhotoBase64: exitPhotoBase64,
      signatureBase64: signatureBase64,
    );

    await insert(order);

    await _offlineSync.enqueue();
  }

  Future<void> saveJustifiedOrder({
    required CustomerModel customer,
    required String justification,
  }) async {
    final order = ServiceOrderModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      customerId: customer.id ?? '',
      customerName: customer.name,
      serviceName: customer.serviceName,
      status: ServiceOrderStatus.justified,
      date: DateTime.now(),
      justification: justification.trim(),
    );

    await insert(order);

    await _offlineSync.enqueue();
  }
}