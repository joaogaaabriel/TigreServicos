import 'package:app_workmatch/AppDependencies.dart';
import 'package:app_workmatch/core/network/ApiClient.dart';
import 'package:app_workmatch/core/services/ServicoService.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/screens/AuthScreen.dart';
import 'package:app_workmatch/screens/HomeClienteScreen.dart';
import 'package:app_workmatch/screens/MeusServicosScreen.dart';
import 'package:app_workmatch/screens/NovoServicoScreen.dart';
import 'package:app_workmatch/core/theme/AppColors.dart';
import 'package:flutter/material.dart';

class AppRouter extends StatefulWidget {
  const AppRouter(
      {super.key, required this.dependencies, required ApiClient apiClient})
      : _apiClient = apiClient;

  final AppDependencies dependencies;
  final ApiClient _apiClient;

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  UserModel? _user;
  bool _checking = true;

  AppDependencies get _deps => widget.dependencies;

  ApiClient get apiClient => apiClient;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final saved = await _deps.authRepository.getStoredUser();
    if (mounted) {
      setState(() {
        _user = saved;
        _checking = false;
      });
    }
  }

  Future<void> _onAuthenticated(UserModel user) async {
    setState(() => _user = user);
  }

  Future<void> _onLogout() async {
    await _deps.authRepository.logout();
    if (mounted) setState(() => _user = null);
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

  void _navegarParaMeusServicos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeusServicosScreen(
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
      return _PlaceholderProfissional(user: _user!, onLogout: _onLogout);
    }

    return HomeClienteScreen(
      user: _user!,
      onNovoServico: _navegarParaNovoServico,
      onVerServicos: _navegarParaMeusServicos,
      onVerServicosPorStatus: (status) {
        // TODO
      },
      onLogout: _onLogout,
      servicoService: ServicoService(
        apiClient: widget._apiClient,
      ),
    );
  }
}

class _PlaceholderProfissional extends StatelessWidget {
  const _PlaceholderProfissional({required this.user, required this.onLogout});

  final UserModel user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text(
          'WorkMatch — Profissional',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogout,
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Olá, ${user.nome}!\nTela do profissional em breve.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppColors.textMid),
        ),
      ),
    );
  }
}
