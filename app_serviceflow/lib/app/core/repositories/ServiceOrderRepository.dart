import 'package:app_serviceflow/app/core/services/ServiceOrder.dart';
import 'package:app_serviceflow/app/core/services/ServiceOrderLocalDatasource.dart';

class ServiceOrderRepository {
  ServiceOrderRepository({required ServiceOrderLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final ServiceOrderLocalDataSource _localDataSource;

  Future<List<ServiceOrder>> getAll() {
    return _localDataSource.getAll();
  }

  Future<void> save(ServiceOrder order) {
    return _localDataSource.insert(order);
  }

  Future<void> update(ServiceOrder order) {
    return _localDataSource.update(order);
  }

  Future<void> delete(String id) {
    return _localDataSource.delete(id);
  }
}
