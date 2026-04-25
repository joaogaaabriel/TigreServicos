import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'app_dependencies.dart';
import 'modules/auth/auth_screen.dart';
import 'modules/dashboard/dashboard_screen.dart';
import 'modules/splash/splash_screen.dart';

/// Esse arquivo so decide qual modulo aparece.
/// A navegacao interna continua simples, usando push normal.
class AppView extends StatelessWidget {
  const AppView({
    super.key,
    required this.controller,
    required this.dependencies,
  });

  final AppController controller;
  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    switch (controller.status) {
      case AppStatus.splash:
        return const SplashScreen();
      case AppStatus.unauthenticated:
        return AuthScreen(
          authRepository: dependencies.authRepository,
          onAuthenticated: controller.onAuthenticated,
        );
      case AppStatus.authenticated:
        return DashboardScreen(
          currentUser: controller.currentUser!,
          serviceOrderRepository: dependencies.serviceOrderRepository,
          onLogout: controller.logout,
        );
    }
  }
}
