import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/repository/AuthRepository.dart';
import 'package:app_workmatch/screens/HomeClienteScreen.dart';
import 'package:app_workmatch/screens/AuthScreen.dart';
import 'package:app_workmatch/screens/NovoServicoScreen.dart';
import 'package:app_workmatch/tigreservicos/core/services/StorageService.dart';
import 'package:app_workmatch/tigreservicos/core/services/UserLocalDataSource.dart';
import 'package:app_workmatch/tigreservicos/core/theme/AppColors.dart';
import 'package:flutter/material.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

final storageService = StorageService();
final userLocalDataSource = UserLocalDataSource();

class _AppRouterState extends State<AppRouter> {
  final _repo = AuthRepository(
      storageService: storageService,
      userLocalDataSource: UserLocalDataSource());
  UserModel? _user;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  // Tenta restaurar sessão salva no SharedPreferences
  Future<void> _restoreSession() async {
    final saved = await _repo.getStoredUser();
    if (mounted)
      setState(() {
        _user = saved;
        _checking = false;
      });
  }

  Future<void> _onAuthenticated(UserModel user) async {
    setState(() => _user = user);
  }

  Future<void> _onLogout() async {
    await _repo.logout();
    if (mounted) setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    // Splash mínimo enquanto verifica sessão
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(child: CircularProgressIndicator(color: AppColors.yellow)),
      );
    }

    // Não autenticado → AuthScreen
    if (_user == null) {
      return AuthScreen(
        authRepository: _repo,
        onAuthenticated: _onAuthenticated,
      );
    }

    return _user!.isProfissional
        ? _PlaceholderProfissional(
            user: _user!,
            onLogout: _onLogout,
          )
        : HomeClienteScreen(
            user: _user!,
            onNovoServico: () {
              print('ENTROU NO APP ROUTER');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NovoServicoScreen(
                    user: _user!,
                  ),
                ),
              );
            },
            onVerServicos: () {
              // TODO
            },
            onVerServicosPorStatus: (status) {
              // TODO
            },
            onLogout: _onLogout,
          );
  }
}

// Placeholder temporário para profissional — substitua por HomeProfissionalScreen
class _PlaceholderProfissional extends StatelessWidget {
  const _PlaceholderProfissional({required this.user, required this.onLogout});
  final UserModel user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text('WorkMatch — Profissional',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogout,
          ),
        ],
      ),
      body: Center(
        child: Text('Olá, ${user.nome}!\nTela do profissional em breve.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.textMid)),
      ),
    );
  }
}
