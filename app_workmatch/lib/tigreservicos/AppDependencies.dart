import 'package:app_workmatch/repository/AuthRepository.dart';
import 'package:app_workmatch/tigreservicos/core/repositories/ServiceOrderRepository.dart';

import 'core/services/DatabaseHelper.dart';
import 'core/services/DioClient.dart';
import 'core/services/OfflineSync.dart';
import 'core/services/StorageService.dart';
import 'core/services/UserLocalDataSource.dart';
import 'core/services/ServiceOrderLocalDatasource.dart';

class AppDependencies {
  AppDependencies._({
    required this.storageService,
    required this.databaseHelper,
    required this.dioClient,
    required this.offlineSync,
    required this.authRepository,
    required this.serviceOrderRepository,
  });

  final StorageService storageService;
  final DatabaseHelper databaseHelper;
  final DioClient dioClient;
  final OfflineSync offlineSync;

  final AuthRepository authRepository;
  final ServiceOrderRepository serviceOrderRepository;

  static Future<AppDependencies> create() async {
    final storageService = StorageService();
    await storageService.init();

    final databaseHelper = DatabaseHelper.instance;

    final dioClient = DioClient(
      storageService: storageService,
    );

    final offlineSync = OfflineSync(
      storageService: storageService,
    );

    final userLocalDataSource = UserLocalDataSource();
    final serviceOrderLocalDataSource =
        ServiceOrderLocalDataSource(databaseHelper);

    final authRepository = AuthRepository(
      baseUrl: 'http://192.168.1.7:8082',
      storageService: storageService,
      userLocalDataSource: userLocalDataSource,
    );

    final serviceOrderRepository = ServiceOrderRepository(
      localDataSource: serviceOrderLocalDataSource,
      storageService: storageService,
      offlineSync: offlineSync,
    );

    return AppDependencies._(
      storageService: storageService,
      databaseHelper: databaseHelper,
      dioClient: dioClient,
      offlineSync: offlineSync,
      authRepository: authRepository,
      serviceOrderRepository: serviceOrderRepository,
    );
  }
}
