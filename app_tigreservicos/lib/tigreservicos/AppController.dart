import 'package:flutter/material.dart';

import 'modules/auth/AuthRepository.dart';
import 'modules/auth/UserModel.dart';

enum AppStatus { splash, unauthenticated, authenticated }

class AppController extends ChangeNotifier {
  AppController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  AppStatus _status = AppStatus.splash;
  UserModel? _currentUser;

  AppStatus get status => _status;
  UserModel? get currentUser => _currentUser;

  Future<void> bootstrap() async {
    // Sempre limpa a sessão ao abrir — exige login toda vez
    await _authRepository.logout();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    _status = AppStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> onLoginSuccess(UserModel user) async {
    _currentUser = user;
    _status = AppStatus.authenticated;
    notifyListeners();
  }

  Future<void> onRegisterSuccess() async {
    _status = AppStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    final confirmed = await _shouldLogout();
    if (!confirmed) return;
    await _authRepository.logout();
    _currentUser = null;
    _status = AppStatus.unauthenticated;
    notifyListeners();
  }

  // Guarda o context globalmente para o dialog de confirmação
  Future<bool> _shouldLogout() async => true; // confirmação feita na UI
}
