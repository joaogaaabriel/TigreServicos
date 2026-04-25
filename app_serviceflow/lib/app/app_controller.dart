import 'package:flutter/material.dart';

import 'modules/auth/auth_repository.dart';
import 'modules/auth/user_model.dart';

enum AppStatus { splash, unauthenticated, authenticated }

/// Controller bem direto para decidir "qual tela raiz aparece agora".
class AppController extends ChangeNotifier {
  AppController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  AppStatus _status = AppStatus.splash;
  UserModel? _currentUser;

  AppStatus get status => _status;
  UserModel? get currentUser => _currentUser;

  Future<void> bootstrap() async {
    final results = await Future.wait<dynamic>([
      _authRepository.getLoggedUser(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);

    _currentUser = results.first as UserModel?;
    _status = _currentUser == null
        ? AppStatus.unauthenticated
        : AppStatus.authenticated;
    notifyListeners();
  }

  Future<void> onAuthenticated(UserModel user) async {
    _currentUser = user;
    _status = AppStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    _status = AppStatus.unauthenticated;
    notifyListeners();
  }
}
