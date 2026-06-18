import 'package:app_workmatch/repository/AuthRepository.dart';
import 'package:app_workmatch/services/StorageService.dart';
import 'package:app_workmatch/services/UserLocalDataSource.dart';

class AppDependencies {
  AppDependencies._({required this.authRepository});

  final AuthRepository authRepository;

  static Future<AppDependencies> create() async {
    final storageService = StorageService();
    await storageService.init();

    final userLocalDataSource = UserLocalDataSource();

    final authRepository = AuthRepository(
      baseUrl: 'http://192.168.1.7:8082',
      storageService: storageService,
      userLocalDataSource: userLocalDataSource,
    );

    return AppDependencies._(authRepository: authRepository);
  }
}
