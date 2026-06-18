import 'package:app_workmatch/screens/HomeClienteScreen.dart';
import 'package:app_workmatch/screens/AuthScreen.dart';
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
  @override
  Widget build(BuildContext context) {
    switch (widget.controller.status) {
      case AppStatus.splash:
        return const Scaffold(
          backgroundColor: Color(0xFF0A1628),
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );

      case AppStatus.unauthenticated:
        return AuthScreen(
          authRepository: widget.dependencies.authRepository,
          onAuthenticated: widget.controller.onLoginSuccess,
        );

      case AppStatus.authenticated:
        final user = widget.controller.currentUser;

        if (user == null)
          return const Scaffold(
            backgroundColor: Color(0xFF0A1628),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );

        // Roteamento por role — igual ao AppRouter.dart do frontend
        if (user.isProfissional) {
          // TODO: substituir pelo HomeProfissionalScreen quando pronto
          // return HomeProfissionalScreen(user: user, onLogout: controller.logout);
          return _ProfissionalPlaceholder(
            nome: user.nome,
            onLogout: widget.controller.logout,
          );
        }

        // CLIENTE → HomeClienteScreen
        return HomeClienteScreen(
          user: user,
          onNovoServico: () {
            // TODO: navegar para tela de novo serviço / chat com IA
          },
          onVerServicos: () {
            // TODO: navegar para lista de serviços
          },
          onVerServicosPorStatus: (status) {
            // TODO: navegar para lista filtrada por status
          },
          onLogout: widget.controller.logout,
        );
    }
  }
}

// ── Placeholder temporário para Profissional ──────────────────────────────────

class _ProfissionalPlaceholder extends StatelessWidget {
  const _ProfissionalPlaceholder({required this.nome, required this.onLogout});

  final String nome;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkMatch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Olá, $nome!\nTela do profissional em breve.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
