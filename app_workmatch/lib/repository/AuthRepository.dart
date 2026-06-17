import 'dart:convert';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/tigreservicos/core/services/StorageService.dart';
import 'package:app_workmatch/tigreservicos/core/services/UserLocalDataSource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class AuthRepository {
  AuthRepository(
      {String? baseUrl,
      required StorageService storageService,
      required UserLocalDataSource userLocalDataSource})
      : _base = baseUrl ?? 'http://10.0.2.2:8082';

  final String _base;
  static const _userKey = 'workmatch_user';

  // ── Headers ───────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // ignore: unused_element
  Future<Map<String, String>> _authHeaders() async {
    final user = await getStoredUser();
    return {
      'Content-Type': 'application/json',
      if (user?.token != null) 'Authorization': 'Bearer ${user!.token}',
    };
  }

  Future<UserModel> login({
    required String login,
    required String senha,
  }) async {
    print('>>> fazendo requisição para $_base/api/login');
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/login'),
            headers: _headers,
            body: jsonEncode({'login': login, 'senha': senha}),
          )
          .timeout(const Duration(seconds: 10)); // ← adiciona isso

      print('>>> status: ${res.statusCode}');
      print('>>> body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final user = UserModel.fromJson(jsonDecode(res.body));
        await _storeUser(user);
        return user;
      }
      if (res.statusCode == 401) throw Exception('Login ou senha inválidos.');
      throw Exception('Erro ao conectar ao servidor. (${res.statusCode})');
    } catch (e) {
      print('>>> exception no login: $e');
      rethrow;
    }
  }

  Future<UserModel> cadastrarUsuario(CadastroUsuarioDto dto) async {
    final res = await http.post(
      Uri.parse('$_base/api/usuarios'),
      headers: _headers,
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(res.body));
    }

    _throwFromResponse(res);
  }

  Future<UserModel> cadastrarProfissional(CadastroProfissionalDto dto) async {
    final res = await http.post(
      Uri.parse('$_base/api/profissionais'),
      headers: _headers,
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(res.body));
    }

    _throwFromResponse(res);
  }

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

  bool get isAuthenticated => false;

  Never _throwFromResponse(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      final msg = body['message'] ?? body['erro'] ?? body['error'];
      if (msg != null) throw Exception(msg.toString());
    } catch (e) {
      if (e is Exception) rethrow;
    }
    throw Exception('Erro ${res.statusCode}: ${res.reasonPhrase}');
  }
}
