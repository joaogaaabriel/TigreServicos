import 'package:app_workmatch/tigreservicos/core/model/CustomerModel.dart';
import 'package:app_workmatch/tigreservicos/core/services/OfflineSync.dart';
import 'package:app_workmatch/tigreservicos/core/services/ServiceOrderLocalDatasource.dart';
import 'package:app_workmatch/tigreservicos/core/services/StorageService.dart';

class ServiceOrderRepository {
  ServiceOrderRepository({
    required ServiceOrderLocalDataSource localDataSource,
    required StorageService storageService,
    required OfflineSync offlineSync,
  }) : _localDataSource = localDataSource;

  final ServiceOrderLocalDataSource _localDataSource;

  /// MOCK temporário (até integrar backend)
  List<CustomerModel> getMockedCustomers() {
    return [
      CustomerModel(
        id: '1',
        name: 'João Silva',
        serviceName: 'Instalação elétrica',
      ),
      CustomerModel(
        id: '2',
        name: 'Maria Souza',
        serviceName: 'Reparo hidráulico',
      ),
      CustomerModel(
        id: '3',
        name: 'Carlos Lima',
        serviceName: 'Manutenção geral',
      ),
    ];
  }

  /// verifica se já teve atendimento hoje (mock simples)
  Future<bool> hasAttendanceToday(String id) async {
    final orders = await _localDataSource.getAll();

    return orders
        .any((order) => order.customerId == id && order.isToday == true);
  }
}
