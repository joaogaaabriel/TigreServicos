import 'dart:convert';
import 'package:app_workmatch/core/network/ApiClient.dart';

class ServicoService {
  const ServicoService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  // ── Publicar ──────────────────────────────────────────────────────────────

  Future<void> publicarServico({
    required Map<String, dynamic> dados,
    required String clienteId,
  }) async {
    final res = await _api.post('/api/servicos', {
      'titulo': dados['titulo'],
      'especialidade': dados['especialidade'],
      'descricao': dados['descricao'],
      'cidade': dados['cidade'],
      'estado': dados['estado'],
      'clienteId': clienteId,
    });

    if (res.statusCode == 200 || res.statusCode == 201) return;

    _api.throwFromResponse(res);
  }

  // ── Listar por cliente ────────────────────────────────────────────────────

  Future<List<dynamic>> listarPorCliente(String clienteId) async {
    final res = await _api.get('/api/servicos/cliente/$clienteId');

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }

    _api.throwFromResponse(res);
  }

  // ── Listar publicados (com filtros e paginação) ───────────────────────────

  Future<List<dynamic>> listarPublicados({
    String? especialidade,
    String? cidade,
    int page = 0,
    int size = 20,
  }) async {
    final params = {
      'page': page,
      'size': size,
      if (especialidade != null && especialidade != 'Todas')
        'especialidade': especialidade,
      if (cidade != null && cidade.isNotEmpty) 'cidade': cidade,
    };

    // Monta query string manualmente
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final res = await _api.get('/api/servicos/publicados?$query');

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['content'] as List<dynamic>? ?? [];
    }

    _api.throwFromResponse(res);
  }
}
