import 'package:app_workmatch/screens/HomeClienteScreen.dart';
import 'package:app_workmatch/screens/HomeProfissionalScreen.dart';
import 'package:app_workmatch/screens/AuthScreen.dart';
import 'package:app_workmatch/screens/MeusServicosScreen.dart';
import 'package:app_workmatch/screens/NovoServicoScreen.dart';
import 'package:flutter/material.dart';

import 'AppController.dart';
import 'AppDependencies.dart';

class AppView extends StatefulWidget {
  const AppView({
    super.key,
    required this.controller,
    required this.dependencies,
  });

  final AppController controller;
  final AppDependencies dependencies;

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  AppDependencies get _deps => widget.dependencies;
  AppController get _ctrl => widget.controller;

  void _navegarParaNovoServico(BuildContext context) {
    final user = _ctrl.currentUser!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NovoServicoScreen(
          user: user,
          servicoService: _deps.servicoService,
        ),
      ),
    );
  }

  void _navegarParaMeusServicos(BuildContext context) {
    final user = _ctrl.currentUser!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeusServicosScreen(
          user: user,
          servicoService: _deps.servicoService,
        ),
      ),
    );
  }

  static Widget _splash() => const Scaffold(
        backgroundColor: Color(0xFF0A1628),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );

  @override
  Widget build(BuildContext context) {
    switch (_ctrl.status) {
      case AppStatus.splash:
        return _splash();

      case AppStatus.unauthenticated:
        return AuthScreen(
          authRepository: _deps.authRepository,
          onAuthenticated: _ctrl.onLoginSuccess,
        );

      case AppStatus.authenticated:
        final user = _ctrl.currentUser;
        if (user == null) return _splash();

        if (user.isProfissional) {
          return HomeProfissionalScreen(
            user: user,
            servicoService: _deps.servicoService,
            onLogout: _ctrl.logout,
          );
        }

        return HomeClienteScreen(
          user: user,
          servicoService: _deps.servicoService,
          onNovoServico: () => _navegarParaNovoServico(context),
          onVerServicos: () => _navegarParaMeusServicos(context),
          onVerServicosPorStatus: (status) => _navegarParaMeusServicos(context),
          onLogout: _ctrl
              .logout, // ← logout chama AppController.logout que limpa o user e vai para unauthenticated
        );
    }
  }
}
