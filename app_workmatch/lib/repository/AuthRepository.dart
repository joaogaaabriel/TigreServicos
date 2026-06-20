import 'dart:convert';
import 'package:app_workmatch/core/network/ApiClient.dart';
import 'package:app_workmatch/dto/CadastroUsuarioDto.dart'
    hide CadastroUsuarioDto;
import 'package:app_workmatch/dto/CadastroProfissionalDto.dart'
    hide CadastroProfissionalDto;
import 'package:app_workmatch/model/UserModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  AuthRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;
  static const _userKey = 'workmatch_user';

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<UserModel> login({
    required String login,
    required String senha,
  }) async {
    final res = await _api.post('/api/login', {'login': login, 'senha': senha});

    if (res.statusCode == 200 || res.statusCode == 201) {
      final user = UserModel.fromJson(jsonDecode(res.body));
      await _storeUser(user);
      return user;
    }

    if (res.statusCode == 401) throw Exception('Login ou senha inválidos.');
    _api.throwFromResponse(res);
  }

  // ── Cadastro ──────────────────────────────────────────────────────────────

  Future<void> cadastrarUsuario(CadastroUsuarioDto dto) async {
    final endpoint =
        dto.role == 'PROFISSIONAL' ? '/api/profissionais' : '/api/usuarios';

    final res = await _api.post(endpoint, dto.toJson());

    if (res.statusCode == 200 || res.statusCode == 201) return;

    _api.throwFromResponse(res);
  }

  Future<void> cadastrarProfissional(CadastroProfissionalDto dto) async {
    final res = await _api.post('/api/profissionais', dto.toJson());

    if (res.statusCode == 200 || res.statusCode == 201) return;

    _api.throwFromResponse(res);
  }

  // ── Validação ─────────────────────────────────────────────────────────────

  Future<void> validarCpf(String cpfLimpo) async {
    final resValida = await _api.post('/api/validar/cpf', {'cpf': cpfLimpo});
    if (resValida.statusCode == 200) {
      final body = jsonDecode(resValida.body) as Map<String, dynamic>;
      if (body['valido'] == false) throw Exception('CPF inválido.');
    }

    final resExiste = await _api.get('/api/validar/cpf-existe/$cpfLimpo');
    if (resExiste.statusCode == 200) {
      final body = jsonDecode(resExiste.body) as Map<String, dynamic>;
      if (body['existe'] == true) throw Exception('CPF já cadastrado.');
    }
  }

  // ── CEP (ViaCEP — externo, não passa pelo gateway) ───────────────────────

  Future<Map<String, dynamic>> buscarCep(String cepLimpo) async {
    final res = await http
        .get(
          Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
        )
        .timeout(const Duration(seconds: 8));

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Erro ao buscar CEP.');
  }

  // ── Storage ───────────────────────────────────────────────────────────────

  Future<void> _storeUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
