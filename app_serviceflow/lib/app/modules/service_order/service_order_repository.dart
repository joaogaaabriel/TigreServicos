import '../../core/repositories/base_repository.dart';
import '../../core/services/database_helper.dart';
import '../../core/services/offline_sync.dart';
import '../../core/services/storage_service.dart';
import 'customer_model.dart';
import 'service_order_model.dart';

/// Repositorio central das ordens de servico.
/// Ele entrega os clientes mockados e salva o historico local do dia.
class ServiceOrderRepository extends BaseRepository<ServiceOrderModel> {
  ServiceOrderRepository({
    required StorageService storageService,
    required this.databaseHelper,
    required this.offlineSync,
  }) : super(storageService: storageService);

  final DatabaseHelper databaseHelper;
  final OfflineSync offlineSync;

  @override
  String get storageKey => 'service_orders';

  @override
  ServiceOrderModel fromMap(Map<String, dynamic> map) {
    return ServiceOrderModel.fromMap(map);
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

    await offlineSync.enqueue();
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

    await offlineSync.enqueue();
  }
}
