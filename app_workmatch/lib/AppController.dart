import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/repository/AuthRepository.dart';
import 'package:flutter/material.dart';

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
    await Future.delayed(const Duration(milliseconds: 1500));

    final user = await _authRepository.getStoredUser();

    if (user != null) {
      _currentUser = user;
      _status = AppStatus.authenticated;
    } else {
      _status = AppStatus.unauthenticated;
    }

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
    await _authRepository.logout(); // remove do SharedPreferences
    _currentUser = null;
    _status = AppStatus.unauthenticated;
    notifyListeners(); // AppView detecta e exibe AuthScreen
  }
}
