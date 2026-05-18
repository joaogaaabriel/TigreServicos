import '../../core/services/StorageService.dart';
import '../../core/services/UserLocalDataSource.dart';
import 'UserModel.dart';

/// ---------------------------------------------------------------------------
/// AuthRepository
/// ---------------------------------------------------------------------------
/// Responsável por centralizar TODA a lógica de autenticação da aplicação.
/// ---------------------------------------------------------------------------
class AuthRepository {
  AuthRepository({
    required StorageService storageService,
    required UserLocalDataSource userLocalDataSource,
  })  : _storageService = storageService,
        _userLocalDataSource = userLocalDataSource;

  final StorageService _storageService;
  final UserLocalDataSource _userLocalDataSource;

  static const _sessionUserKey = 'session_user_email';
  static const _sessionTokenKey = 'session_token';

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final existingUser =
        await _userLocalDataSource.findByEmail(normalizedEmail);
    if (existingUser != null) {
      throw Exception('Já existe um cadastro com esse e-mail.');
    }

    final user = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
    );

    await _userLocalDataSource.insert(user);
    await _saveSession(user);
    return user;
  }

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

  Future<UserModel?> getLoggedUser() async {
    final sessionEmail = await _storageService.readSecure(_sessionUserKey);
    if (sessionEmail == null) return null;
    return _userLocalDataSource.findByEmail(sessionEmail);
  }

  Future<void> logout() async {
    await _storageService.deleteSecure(_sessionUserKey);
    await _storageService.deleteSecure(_sessionTokenKey);
  }

  Future<void> _saveSession(UserModel user) async {
    await _storageService.writeSecure(_sessionUserKey, user.email);
    await _storageService.writeSecure(_sessionTokenKey, user.token);
  }
}
