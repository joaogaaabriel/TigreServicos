import 'package:app_serviceflow/app/modules/auth/AuthRepository.dart';
import 'package:app_serviceflow/app/modules/auth/UserModel.dart';
import 'package:flutter/foundation.dart';

/// ---------------------------------------------------------------------------
/// AuthMode
/// ---------------------------------------------------------------------------
/// Define o modo atual da tela de autenticação.
///
/// - login: usuário está autenticando
/// - register: usuário está criando conta
/// ---------------------------------------------------------------------------
enum AuthMode { login, register }

/// ---------------------------------------------------------------------------
/// AuthController
/// ---------------------------------------------------------------------------
/// Responsável por gerenciar o estado da autenticação na UI.
///
/// Essa classe segue o padrão ChangeNotifier e controla:
/// - Alternância entre login e registro
/// - Estado de carregamento (loading)
/// - Execução de login/registro via Repository
///
/// Papel na arquitetura:
/// - Camada de apresentação (UI State Management)
/// - Não contém regra de negócio complexa
/// - Apenas coordena ações do AuthRepository
/// ---------------------------------------------------------------------------
class AuthController extends ChangeNotifier {
  /// Construtor recebe o repositório responsável pelas regras de autenticação
  AuthController({required AuthRepository repository})
      : _repository = repository;

  /// Repositório de autenticação (camada de domínio/dados)
  final AuthRepository _repository;

  // ---------------------------------------------------------------------------
  // STATE MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Modo atual da tela (login ou registro)
  AuthMode _mode = AuthMode.login;

  /// Indica se há uma operação em andamento (login/register)
  bool _isLoading = false;

  /// Retorna o modo atual da autenticação
  AuthMode get mode => _mode;

  /// Retorna se o sistema está carregando operação assíncrona
  bool get isLoading => _isLoading;

  /// Verifica se está no modo registro
  bool get isRegisterMode => _mode == AuthMode.register;

  // ---------------------------------------------------------------------------
  // UI ACTIONS
  // ---------------------------------------------------------------------------

  /// Alterna entre modo login e registro.
  ///
  /// Usado na UI para trocar formulário dinamicamente.
  void toggleMode() {
    _mode = isRegisterMode ? AuthMode.login : AuthMode.register;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // AUTH FLOW (LOGIN / REGISTER)
  // ---------------------------------------------------------------------------

  /// Executa login ou registro dependendo do modo atual.
  ///
  /// Fluxo:
  /// 1. Ativa loading
  /// 2. Executa ação no repository
  /// 3. Desativa loading
  ///
  /// Parâmetros:
  /// - [name]: usado apenas no registro
  /// - [email]: email do usuário
  /// - [password]: senha do usuário
  ///
  /// Retorna:
  /// - [UserModel] autenticado ou criado
  Future<UserModel> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    // ativa loading para UI
    _isLoading = true;
    notifyListeners();

    try {
      // ---------------------------------------------------------------------
      // REGISTRO
      // ---------------------------------------------------------------------
      if (isRegisterMode) {
        return await _repository.register(
          name: name,
          email: email,
          password: password,
        );
      }

      // ---------------------------------------------------------------------
      // LOGIN
      // ---------------------------------------------------------------------
      return await _repository.login(
        email: email,
        password: password,
      );
    } finally {
      // garante que loading sempre será desativado
      _isLoading = false;
      notifyListeners();
    }
  }
}