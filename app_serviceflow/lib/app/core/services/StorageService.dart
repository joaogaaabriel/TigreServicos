import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// StorageService
/// ---------------------------------------------------------------------------
/// Classe responsável por centralizar o armazenamento local da aplicação,
/// oferecendo duas estratégias diferentes de persistência:
///
/// 1. SharedPreferences:
///    - Dados simples (não sensíveis)
///    - Strings, flags, configurações
///
/// 2. FlutterSecureStorage:
///    - Dados sensíveis
///    - Tokens, credenciais, informações privadas
///
/// Essa separação garante mais segurança e organização dos dados locais.
/// ---------------------------------------------------------------------------
class StorageService {
  /// Instância de SharedPreferences (armazenamento simples)
  late final SharedPreferences _preferences;

  /// Instância de armazenamento seguro (criptografado)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // INITIALIZATION
  // ---------------------------------------------------------------------------
  /// Inicializa o SharedPreferences.
  ///
  /// IMPORTANTE:
  /// Deve ser chamado antes de qualquer uso do StorageService,
  /// geralmente no `main()` da aplicação.
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // ---------------------------------------------------------------------------
  // SHARED PREFERENCES (dados não sensíveis)
  // ---------------------------------------------------------------------------

  /// Recupera uma String armazenada no SharedPreferences.
  ///
  /// Usado para dados simples como:
  /// - Configurações
  /// - Flags de UI
  /// - Dados temporários
  String? getString(String key) => _preferences.getString(key);

  /// Salva uma String no SharedPreferences.
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  /// Remove uma chave do SharedPreferences.
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  // ---------------------------------------------------------------------------
  // SECURE STORAGE (dados sensíveis)
  // ---------------------------------------------------------------------------

  /// Armazena um valor de forma segura e criptografada.
  ///
  /// Usado para:
  /// - JWT Token
  /// - Refresh Token
  /// - Dados sensíveis do usuário
  Future<void> writeSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Lê um valor armazenado no Secure Storage.
  Future<String?> readSecure(String key) async {
    return _secureStorage.read(key: key);
  }

  /// Remove um valor do Secure Storage.
  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }
}
