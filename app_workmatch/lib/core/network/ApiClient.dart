import 'dart:convert';
import 'package:app_workmatch/core/config/AppConfig.dart';
import 'package:http/http.dart' as http;

/// Cliente HTTP centralizado.
/// Toda chamada ao backend passa por aqui — nunca use http.get/post direto.
///
/// Injete via AppDependencies e repasse para os repositories.
class ApiClient {
  ApiClient({String? token}) : _token = token;

  final String? _token;

  // ── Headers ───────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Métodos ───────────────────────────────────────────────────────────────

  Future<http.Response> get(String path) =>
      http.get(_uri(path), headers: _headers).timeout(AppConfig.apiTimeout);

  Future<http.Response> post(String path, Object body) => http
      .post(_uri(path), headers: _headers, body: jsonEncode(body))
      .timeout(AppConfig.apiTimeout);

  Future<http.Response> put(String path, Object body) => http
      .put(_uri(path), headers: _headers, body: jsonEncode(body))
      .timeout(AppConfig.apiTimeout);

  Future<http.Response> delete(String path) =>
      http.delete(_uri(path), headers: _headers).timeout(AppConfig.apiTimeout);

  // ── Helper ────────────────────────────────────────────────────────────────

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  /// Lança Exception com a mensagem do backend ou status HTTP.
  Never throwFromResponse(http.Response res) {
    // Print do body completo para debug
    print('===== RESPONSE ERROR [${res.statusCode}] =====');
    print(res.body);
    print('=============================================');
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;

      // Mensagem direta
      final msg = body['message'] ?? body['erro'] ?? body['error'];
      if (msg != null) throw Exception(msg.toString());

      // Erros de validação do Spring (@Valid) — lista de campos
      final errors = body['errors'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final msgs = errors
            .map(
                (e) => (e as Map<String, dynamic>)['message']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .join(', ');
        if (msgs.isNotEmpty) throw Exception(msgs);
      }
    } catch (e) {
      if (e is Exception) rethrow;
    }
    throw Exception('Erro ${res.statusCode}: ${res.reasonPhrase}');
  }
}
