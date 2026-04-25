import 'package:flutter/material.dart';

import 'auth_repository.dart';
import 'user_model.dart';

enum AuthMode { login, register }

/// Controller da tela de login/cadastro.
class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository}) : _repository = repository;

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

      return await _repository.login(email: email, password: password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
