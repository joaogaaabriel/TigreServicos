import 'dart:convert';
import 'package:app_workmatch/auth/network/ApiClient.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServicoService {
  static const String _baseUrl = "http://192.168.1.7:8082";

  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('workmatch_user');
      if (raw == null) return null;
      return jsonDecode(raw)['token']?.toString();
    } catch (_) {
      return null;
    }
  }

  static Future<void> publicarServico({
    required Map<String, dynamic> dados,
    required String clienteId,
  }) async {
    final token = await _getToken();
    final body = {
      "titulo": dados["titulo"],
      "especialidade": dados["especialidade"],
      "descricao": dados["descricao"],
      "cidade": dados["cidade"],
      "estado": dados["estado"],
      "clienteId": clienteId,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/api/servicos'),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print('>>> publicarServico status: ${response.statusCode}');
    print('>>> publicarServico body: ${response.body}');

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Erro ao publicar serviço: ${response.body}");
    }
  }

  static Future<List<dynamic>> listarPorCliente(String id) async {
    try {
      final response = await ApiClient.dio.get('/api/servicos/cliente/$id');
      print('>>> listarPorCliente status: ${response.statusCode}');
      print('>>> listarPorCliente data: ${response.data}');
      return response.data ?? [];
    } catch (e) {
      print('>>> listarPorCliente erro: $e');
      throw Exception("Erro ao listar serviços do cliente: $e");
    }
  }

  static Future<List<dynamic>> listarPublicados({
    String? especialidade,
    String? cidade,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/api/servicos/publicados',
        queryParameters: {
          'page': page,
          'size': size,
          if (especialidade != null && especialidade != 'Todas')
            'especialidade': especialidade,
          if (cidade != null && cidade.isNotEmpty) 'cidade': cidade,
        },
      );
      return response.data['content'] ?? [];
    } catch (e) {
      print('>>> listarPublicados erro: $e');
      throw Exception("Erro ao listar serviços: $e");
    }
  }
}
