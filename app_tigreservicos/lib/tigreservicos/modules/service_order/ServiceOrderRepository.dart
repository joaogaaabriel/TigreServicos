import 'dart:convert';

import 'package:app_serviceflow/app/core/services/StorageService.dart';
import 'package:app_serviceflow/app/core/services/DatabaseHelper.dart';
import 'package:app_serviceflow/app/core/services/OfflineSync.dart';
import 'package:app_serviceflow/app/modules/service_order/ServiceOderModel.dart';
import 'package:app_serviceflow/app/modules/service_order/CustomerModel.dart';

class ServiceOrderRepository {
  ServiceOrderRepository({
    required StorageService storageService,
    required DatabaseHelper databaseHelper,
    required OfflineSync offlineSync,
  })  : _storageService = storageService,
        _offlineSync = offlineSync;

  final StorageService _storageService;
  final OfflineSync _offlineSync;

  static const _storageKey = 'service_orders';

  Future<List<ServiceOrderModel>> getAll() async {
    final jsonString = _storageService.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final list = (jsonDecode(jsonString) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    return list.map((map) => ServiceOrderModel.fromMap(map)).toList();
  }

  Future<void> saveAll(List<ServiceOrderModel> items) async {
    final encoded = jsonEncode(items.map((item) => item.toMap()).toList());
    await _storageService.setString(_storageKey, encoded);
  }

  Future<void> insert(ServiceOrderModel item) async {
    final items = await getAll();
    items.add(item);
    await saveAll(items);
  }

  Future<void> update(ServiceOrderModel item) async {
    final items = await getAll();
    final index = items.indexWhere((current) => current.id == item.id);

    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }

    await saveAll(items);
  }

  Future<void> delete(String id) async {
    final items = await getAll();
    items.removeWhere((item) => item.id == id);
    await saveAll(items);
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
    return todayOrders.any((order) => order.customerId == customerId);
  }

  Future<void> saveRealizedOrder({
    required CustomerModel customer,
    required String entryPhotoBase64,
    required String exitPhotoBase64,
    required String signatureBase64,
  }) async {
    await insert(
      ServiceOrderModel(
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
      ),
    );

    await _offlineSync.enqueue();
  }

  Future<void> saveJustifiedOrder({
    required CustomerModel customer,
    required String justification,
  }) async {
    await insert(
      ServiceOrderModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        customerId: customer.id ?? '',
        customerName: customer.name,
        serviceName: customer.serviceName,
        status: ServiceOrderStatus.justified,
        date: DateTime.now(),
        justification: justification.trim(),
      ),
    );

    await _offlineSync.enqueue();
  }
}
