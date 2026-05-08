import 'package:app_serviceflow/app/core/services/StorageService.dart';
import 'package:app_serviceflow/app/core/services/UserLocalDataSource.dart';
import 'package:app_serviceflow/app/modules/auth/UserModel.dart';

/// ---------------------------------------------------------------------------
/// AuthRepository
/// ---------------------------------------------------------------------------
/// Responsável por centralizar TODA a lógica de autenticação da aplicação.
///
/// Essa classe atua como camada de domínio entre:
/// - AuthController (UI)
/// - UserLocalDataSource (SQLite)
/// - StorageService (sessão segura)
///
/// Responsabilidades:
/// - Registrar usuários
/// - Realizar login
/// - Gerenciar sessão do usuário
/// - Persistir token/email de forma segura
/// - Recuperar usuário logado
/// - Fazer logout
///
/// Esse repository implementa autenticação LOCAL (offline-first).
/// ---------------------------------------------------------------------------
class AuthRepository {
  /// Construtor com dependências injetadas
  AuthRepository({
    required StorageService storageService,
    required UserLocalDataSource userLocalDataSource,
  }) : _storageService = storageService,
       _userLocalDataSource = userLocalDataSource;

  /// Serviço de armazenamento seguro (SharedPreferences + Secure Storage)
  final StorageService _storageService;

  /// DataSource responsável pelo SQLite de usuários
  final UserLocalDataSource _userLocalDataSource;

  // ---------------------------------------------------------------------------
  // SESSION KEYS
  // ---------------------------------------------------------------------------

  /// Chave usada para armazenar email do usuário logado
  static const _sessionUserKey = 'session_user_email';

  /// Chave usada para armazenar token da sessão
  static const _sessionTokenKey = 'session_token';

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------

  /// Registra um novo usuário no sistema local.
  ///
  /// Fluxo:
  /// 1. Normaliza email (lowercase + trim)
  /// 2. Verifica se usuário já existe
  /// 3. Cria novo UserModel
  /// 4. Salva no SQLite
  /// 5. Cria sessão automaticamente
  ///
  /// Exceções:
  /// - Email já cadastrado
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Verifica duplicidade de usuário
    final existingUser = await _userLocalDataSource.findByEmail(
      normalizedEmail,
    );

    if (existingUser != null) {
      throw Exception('Já existe um cadastro com esse e-mail.');
    }

    // Criação da entidade de usuário
    final user = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Persistência local
    await _userLocalDataSource.insert(user);

    // Cria sessão automaticamente
    await _saveSession(user);

    return user;
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------

  /// Realiza login verificando email e senha no banco local.
  ///
  /// Fluxo:
  /// 1. Normaliza email
  /// 2. Busca usuário no SQLite
  /// 3. Valida credenciais
  /// 4. Cria sessão
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final user = await _userLocalDataSource.findByEmailAndPassword(
      normalizedEmail,
      password,
    );

    if (user == null) {
      throw Exception('E-mail ou senha inválidos.');
    }

    await _saveSession(user);
    return user;
  }

  // ---------------------------------------------------------------------------
  // SESSION RECOVERY
  // ---------------------------------------------------------------------------

  /// Recupera o usuário atualmente logado (sessão ativa).
  ///
  /// Fluxo:
  /// 1. Lê email salvo no Secure Storage
  /// 2. Busca usuário no SQLite
  Future<UserModel?> getLoggedUser() async {
    final sessionEmail = await _storageService.readSecure(_sessionUserKey);

    if (sessionEmail == null) return null;

    return _userLocalDataSource.findByEmail(sessionEmail);
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  /// Remove sessão do usuário.
  ///
  /// Limpa:
  /// - Email da sessão
  /// - Token da sessão
  Future<void> logout() async {
    await _storageService.deleteSecure(_sessionUserKey);
    await _storageService.deleteSecure(_sessionTokenKey);
  }

  // ---------------------------------------------------------------------------
  // PRIVATE SESSION HANDLER
  // ---------------------------------------------------------------------------

  /// Salva sessão do usuário no Secure Storage.
  ///
  /// Responsável por persistir:
  /// - Email do usuário logado
  /// - Token de autenticação
  Future<void> _saveSession(UserModel user) async {
    await _storageService.writeSecure(_sessionUserKey, user.email);
    await _storageService.writeSecure(_sessionTokenKey, user.token);
  }
}
