import 'package:shared_preferences/shared_preferences.dart';

/// Esse servico mistura dois jeitos de salvar dados:
/// - shared_preferences para listas e dados simples do app
/// - "secure" local tambem usando shared_preferences para evitar dependencia
///   nativa no Android durante a compilacao.
///
/// Importante:
/// Esse ajuste prioriza a funcionalidade do projeto academico.
/// Em um app de producao, tokens sensiveis deveriam ficar em armazenamento
/// realmente seguro, como o Keystore/Keychain via plugin especifico.
class StorageService {
  late final SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  String? getString(String key) => _preferences.getString(key);

  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  Future<void> writeSecure(String key, String value) async {
    // Mantemos um metodo separado para nao mudar o restante do app.
    // Assim, o repositorio de autenticacao continua chamando writeSecure,
    // mas por baixo dos panos os dados sao salvos localmente.
    await _preferences.setString(key, value);
  }

  Future<String?> readSecure(String key) async {
    // Lemos da mesma chave salva no armazenamento local.
    return _preferences.getString(key);
  }

  Future<void> deleteSecure(String key) async {
    // Remove o dado salvo da sessao para simular o logout.
    await _preferences.remove(key);
  }
}
