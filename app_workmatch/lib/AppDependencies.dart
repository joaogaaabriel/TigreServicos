import 'package:app_workmatch/core/network/ApiClient.dart';
import 'package:app_workmatch/core/services/ServicoService.dart';
import 'package:app_workmatch/repository/AuthRepository.dart';

/// Composição de todas as dependências do app.
/// Criado uma única vez em [main] e repassado pela árvore de widgets.
class AppDependencies {
  AppDependencies._({
    required this.apiClient,
    required this.authRepository,
    required this.servicoService,
  });

  final ApiClient apiClient;
  final AuthRepository authRepository;
  final ServicoService servicoService;

  static Future<AppDependencies> create() async {
    final apiClient = ApiClient();

    return AppDependencies._(
      apiClient: apiClient,
      authRepository: AuthRepository(apiClient: apiClient),
      servicoService: ServicoService(apiClient: apiClient),
    );
  }
}
