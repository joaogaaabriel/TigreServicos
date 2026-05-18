import 'package:flutter/material.dart';

import 'AppController.dart';
import 'AppDependencies.dart';
import 'modules/auth/AuthScreen.dart';
import 'modules/dashboard/DashboardScreen.dart';
import 'modules/splash/SplashScreen.dart';

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
          onAuthenticated: controller.onLoginSuccess,
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