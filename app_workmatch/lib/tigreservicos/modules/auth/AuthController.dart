import 'package:flutter/foundation.dart';
import 'package:app_workmatch/repository/AuthRepository.dart';

enum AuthMode { login, register }

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

  Future<void> login({
    required String login,
    required String senha,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.login(
        login: login,
        senha: senha,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
