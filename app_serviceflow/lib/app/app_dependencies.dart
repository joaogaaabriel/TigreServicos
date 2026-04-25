import 'core/services/database_helper.dart';
import 'core/services/dio_client.dart';
import 'core/services/offline_sync.dart';
import 'core/services/storage_service.dart';
import 'modules/auth/auth_repository.dart';
import 'modules/service_order/service_order_repository.dart';

/// Aqui fica a "caixa de ferramentas" do app.
/// Em projeto pequeno isso resolve a injecao sem colocar pacote extra.
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

    final databaseHelper = DatabaseHelper(storageService: storageService);
    final dioClient = DioClient(storageService: storageService);
    final offlineSync = OfflineSync(storageService: storageService);

    return AppDependencies._(
      storageService: storageService,
      databaseHelper: databaseHelper,
      dioClient: dioClient,
      offlineSync: offlineSync,
      authRepository: AuthRepository(
        storageService: storageService,
        databaseHelper: databaseHelper,
      ),
      serviceOrderRepository: ServiceOrderRepository(
        storageService: storageService,
        databaseHelper: databaseHelper,
        offlineSync: offlineSync,
      ),
    );
  }
}
