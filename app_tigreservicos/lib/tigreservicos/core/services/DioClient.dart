import 'package:dio/dio.dart';

import 'StorageService.dart';

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
    instance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.readSecure('session_token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }
}
