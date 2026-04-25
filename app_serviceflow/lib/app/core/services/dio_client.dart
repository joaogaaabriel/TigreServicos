import 'package:dio/dio.dart';

import 'storage_service.dart';

/// Cliente HTTP centralizado.
/// Hoje ele esta pronto para crescer, mas sem inventar fluxo remoto que o app ainda nao precisa.
class DioClient {
  DioClient({required StorageService storageService})
      : instance = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
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

  final Dio instance;
}
