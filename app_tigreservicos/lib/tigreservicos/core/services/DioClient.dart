import 'package:app_serviceflow/app/core/services/StorageService.dart';
import 'package:dio/dio.dart';

/// ---------------------------------------------------------------------------
/// DioClient
/// ---------------------------------------------------------------------------
/// Classe responsável por configurar e expor uma instância do Dio,
/// utilizada para requisições HTTP na aplicação.
///
/// Responsabilidades:
/// - Configurar timeouts globais
/// - Interceptar requisições para adicionar token JWT automaticamente
/// - Centralizar configuração de comunicação com API
///
/// Isso evita repetição de código em services e mantém o controle
/// de autenticação centralizado.
/// ---------------------------------------------------------------------------
class DioClient {
  /// Instância configurada do Dio (cliente HTTP)
  final Dio instance;

  /// Construtor principal.
  ///
  /// Recebe o [StorageService] para recuperar o token armazenado localmente
  /// e injetá-lo automaticamente nas requisições.
  DioClient({required StorageService storageService})
    : instance = Dio(
        BaseOptions(
          // Tempo máximo para estabelecer conexão com o servidor
          connectTimeout: const Duration(seconds: 10),

          // Tempo máximo para receber resposta da API
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    // -----------------------------------------------------------------------
    // INTERCEPTORS
    // -----------------------------------------------------------------------
    // Interceptor responsável por manipular requisições e respostas HTTP.
    instance.interceptors.add(
      InterceptorsWrapper(
        // -------------------------------------------------------------------
        // REQUEST INTERCEPTOR
        // -------------------------------------------------------------------
        // Executado antes de cada requisição HTTP.
        // Aqui adicionamos o token de autenticação no header.
        onRequest: (options, handler) async {
          // Recupera token salvo localmente (Secure Storage)
          final token = await storageService.readSecure('session_token');

          // Se existir token válido, adiciona no header Authorization
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Continua fluxo da requisição
          handler.next(options);
        },

        // -------------------------------------------------------------------
        // ERROR INTERCEPTOR
        // -------------------------------------------------------------------
        // Executado quando ocorre erro na requisição HTTP.
        // Aqui apenas repassamos o erro sem tratamento adicional.
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }
}
