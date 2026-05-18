import '../../core/services/OfflineSync.dart';
import '../../core/services/StorageService.dart';
import 'ServiceOderModel.dart';
import 'ServiceOrderLocalDatasource.dart';
import 'CustomerModel.dart';

class ServiceOrderRepository {
  ServiceOrderRepository({
    required this.localDatasource,
    required this.storageService,
    required this.offlineSync,
  });

  final ServiceOrderLocalDatasource localDatasource;
  final StorageService storageService;
  final OfflineSync offlineSync;

  Future<List<ServiceOrderModel>> getAll() {
    return localDatasource.getAll();
  }

  Future<void> insert(ServiceOrderModel item) async {
    await localDatasource.insert(item);
    await offlineSync.enqueue();
  }

  Future<void> update(ServiceOrderModel item) async {
    await localDatasource.update(item);
    await offlineSync.enqueue();
  }

  Future<void> delete(String id) async {
    await localDatasource.delete(id);
    await offlineSync.enqueue();
  }

  Future<List<ServiceOrderModel>> getTodayOrders() {
    return localDatasource.getToday();
  }

  Future<bool> hasAttendanceToday(String customerId) async {
    final today = await getTodayOrders();
    return today.any((o) => o.customerId == customerId);
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
  }

  // 🔥 FIX AQUI: agora funciona de verdade
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
}