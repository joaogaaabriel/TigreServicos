import 'core/services/UserLocalDataSource.dart';
import 'core/services/DatabaseHelper.dart';
import 'core/services/DioClient.dart';
import 'core/services/OfflineSync.dart';
import 'core/services/StorageService.dart';

import 'modules/auth/AuthRepository.dart';
import 'modules/service_order/ServiceOrderRepository.dart';

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

    return AppDependencies._(
      storageService: storageService,
      databaseHelper: databaseHelper,
      dioClient: dioClient,
      offlineSync: offlineSync,

      authRepository: AuthRepository(
        storageService: storageService,
        userLocalDataSource: UserLocalDataSource(),
      ),

      serviceOrderRepository: ServiceOrderRepository(
        databaseHelper: databaseHelper,
        offlineSync: offlineSync,
      ),
    );
  }
}