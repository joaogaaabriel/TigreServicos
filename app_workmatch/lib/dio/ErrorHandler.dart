import 'package:dio/dio.dart';

class ErrorHandler {
  static String parse(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        // message principal
        if (data['message'] != null) {
          // Bean Validation
          if (data['errors'] is Map) {
            final errors = Map<String, dynamic>.from(data['errors']);

            return errors.values.join('\n');
          }

          return data['message'].toString();
        }
      }

      switch (error.response?.statusCode) {
        case 401:
          return 'Usuário ou senha inválidos';

        case 403:
          return 'Acesso negado';

        case 404:
          return 'Recurso não encontrado';

        case 500:
          return 'Erro interno do servidor';
      }
    }

    return 'Ocorreu um erro inesperado';
  }
}
