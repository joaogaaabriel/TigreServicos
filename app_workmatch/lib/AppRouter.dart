import 'package:app_workmatch/AppDependencies.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/screens/AuthScreen.dart';
import 'package:app_workmatch/screens/HomeClienteScreen.dart';
import 'package:app_workmatch/screens/HomeProfissionalScreen.dart';
import 'package:app_workmatch/screens/MeusServicosScreen.dart';
import 'package:app_workmatch/screens/NovoServicoScreen.dart';
import 'package:app_workmatch/core/theme/AppColors.dart';
import 'package:flutter/material.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  UserModel? _user;
  bool _checking = true;
  int _itemAtivo = 0; // índice do menu ativo — igual ao useLocation do React

  AppDependencies get _deps => widget.dependencies;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final saved = await _deps.authRepository.getStoredUser();
    if (mounted)
      setState(() {
        _user = saved;
        _checking = false;
      });
  }

  Future<void> _onAuthenticated(UserModel user) async {
    setState(() {
      _user = user;
      _itemAtivo = 0;
    });
  }

  Future<void> _onLogout() async {
    await _deps.authRepository.logout();
    if (mounted) {
      setState(() => _user = null);
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  // ── Navegação via menu — equivalente ao handleNav do React ───────────────

  void _onNavegar(int index) {
    if (index == _itemAtivo) return;

    switch (index) {
      case 0: // Início
        setState(() => _itemAtivo = 0);
        break;

      case 1: // Meus serviços
        setState(() => _itemAtivo = 1);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeusServicosScreen(
              user: _user!,
              servicoService: _deps.servicoService,
            ),
          ),
        ).then((_) => setState(() => _itemAtivo = 0));
        break;

      case 2: // Perfil — TODO
        setState(() => _itemAtivo = 2);
        break;

      case 3: // Suporte — TODO
        setState(() => _itemAtivo = 3);
        break;
    }
  }

  void _navegarParaNovoServico() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NovoServicoScreen(
          user: _user!,
          servicoService: _deps.servicoService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.yellow),
        ),
      );
    }

    if (_user == null) {
      return AuthScreen(
        authRepository: _deps.authRepository,
        onAuthenticated: _onAuthenticated,
      );
    }

    if (_user!.isProfissional) {
      return HomeProfissionalScreen(
        user: _user!,
        servicoService: _deps.servicoService,
        onLogout: _onLogout,
        itemAtivo: _itemAtivo,
        onNavegar: _onNavegar,
      );
    }

    return HomeClienteScreen(
      user: _user!,
      servicoService: _deps.servicoService,
      onNovoServico: _navegarParaNovoServico,
      onVerServicos: () => _onNavegar(1),
      onVerServicosPorStatus: (_) => _onNavegar(1),
      onLogout: _onLogout,
      itemAtivo: _itemAtivo,
      onNavegar: _onNavegar,
    );
  }
}
