import '../../core/repositories/base_repository.dart';
import '../../core/services/database_helper.dart';
import '../../core/services/storage_service.dart';
import 'user_model.dart';

/// Repositorio de autenticacao local.
/// Aqui ficam cadastro, login e leitura da sessao salva.
class AuthRepository extends BaseRepository<UserModel> {
  AuthRepository({
    required StorageService storageService,
    required this.databaseHelper,
  }) : super(storageService: storageService);

  final DatabaseHelper databaseHelper;

  static const _sessionUserKey = 'session_user_email';
  static const _sessionTokenKey = 'session_token';

  @override
  String get storageKey => 'users';

  @override
  UserModel fromMap(Map<String, dynamic> map) => UserModel.fromMap(map);

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final users = await getAll();
    final normalizedEmail = email.trim().toLowerCase();

    final alreadyExists = users.any((user) => user.email == normalizedEmail);
    if (alreadyExists) {
      throw Exception('Ja existe um cadastro com esse e-mail.');
    }

    final user = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
    );

    await insert(user);
    await _saveSession(user);
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final users = await getAll();
    final normalizedEmail = email.trim().toLowerCase();

    final user = users.cast<UserModel?>().firstWhere(
          (item) =>
              item?.email == normalizedEmail && item?.password == password,
          orElse: () => null,
        );

    if (user == null) {
      throw Exception('E-mail ou senha invalidos.');
    }

    await _saveSession(user);
    return user;
  }

  Future<UserModel?> getLoggedUser() async {
    final sessionEmail = await databaseHelper.storageService.readSecure(_sessionUserKey);
    if (sessionEmail == null) {
      return null;
    }

    final users = await getAll();
    try {
      return users.firstWhere((user) => user.email == sessionEmail);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await databaseHelper.storageService.deleteSecure(_sessionUserKey);
    await databaseHelper.storageService.deleteSecure(_sessionTokenKey);
  }

  Future<void> _saveSession(UserModel user) async {
    await databaseHelper.storageService.writeSecure(_sessionUserKey, user.email);
    await databaseHelper.storageService.writeSecure(_sessionTokenKey, user.token);
  }
}
