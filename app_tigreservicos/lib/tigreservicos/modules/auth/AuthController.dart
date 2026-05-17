import 'package:flutter/foundation.dart';

import 'AuthRepository.dart';
import 'UserModel.dart';

enum AuthMode { login, register }

/// ---------------------------------------------------------------------------
/// AuthController
/// ---------------------------------------------------------------------------
/// Responsável por gerenciar o estado da autenticação na UI.
///
/// Essa classe segue o padrão ChangeNotifier e controla:
/// - Alternância entre login e registro
/// - Estado de carregamento (loading)
/// - Execução de login/registro via Repository
/// ---------------------------------------------------------------------------
class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;

  AuthMode get mode => _mode;
  bool get isLoading => _isLoading;
  bool get isRegisterMode => _mode == AuthMode.register;

  void toggleMode() {
    _mode = isRegisterMode ? AuthMode.login : AuthMode.register;
    notifyListeners();
  }

  Future<UserModel> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isRegisterMode) {
        return await _repository.register(
          name: name,
          email: email,
          password: password,
        );
      }

      return await _repository.login(
        email: email,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
