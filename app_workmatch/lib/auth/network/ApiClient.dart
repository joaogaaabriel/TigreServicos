import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiClient {
  static const _baseUrl = "http://192.168.1.7:8082";

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Pega o token salvo no SharedPreferences (mesmo local do AuthRepository)
          try {
            final prefs = await SharedPreferences.getInstance();
            final raw = prefs.getString('workmatch_user');
            if (raw != null) {
              final user = jsonDecode(raw);
              final token = user['token'];
              if (token != null && token.toString().isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
          } catch (_) {}
          handler.next(options);
        },
        onError: (error, handler) {
          print(
              '>>> ApiClient erro: ${error.response?.statusCode} ${error.message}');
          handler.next(error);
        },
      ),
    );
}
