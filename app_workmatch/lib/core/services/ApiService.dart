import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8082";

  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );
  }
}