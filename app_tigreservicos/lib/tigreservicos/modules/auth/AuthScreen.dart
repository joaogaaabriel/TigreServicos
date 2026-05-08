import 'package:flutter/material.dart';

import '../../core/mixins/UiFeedbackMixin.dart';
import '../../core/mixins/ValidatorMixin.dart';
import '../../core/theme/AppColors.dart';
import '../../shared/CustomButton.dart';
import '../../shared/CustomTextField.dart';
import '../../shared/SectionCard.dart';
import 'AuthController.dart';
import 'AuthRepository.dart';
import 'UserModel.dart';

/// ---------------------------------------------------------------------------
/// AuthScreen
/// ---------------------------------------------------------------------------
/// Tela responsável por autenticação do usuário.
///
/// Essa tela suporta dois fluxos:
/// - Login
/// - Registro (cadastro local)
///
/// Arquitetura:
/// - Usa [AuthController] para gerenciar estado
/// - Usa [AuthRepository] via Controller
/// - Usa mixins para validação e feedback UI
///
/// Responsabilidades:
/// - Exibir formulário de login/registro
/// - Validar inputs
/// - Chamar autenticação
/// - Exibir loading e mensagens de erro
/// ---------------------------------------------------------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authRepository,
    required this.onAuthenticated,
  });

  /// Repositório de autenticação (injeção de dependência)
  final AuthRepository authRepository;

  /// Callback executado após login/registro bem-sucedido
  final Future<void> Function(UserModel user) onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

/// ---------------------------------------------------------------------------
/// State da AuthScreen
/// ---------------------------------------------------------------------------
/// Gerencia:
/// - Controllers dos inputs
/// - Instância do AuthController
/// - Submissão do formulário
/// ---------------------------------------------------------------------------
class _AuthScreenState extends State<AuthScreen>
    with UiFeedbackMixin, ValidatorMixin {
  /// Chave global do formulário para validação
  final _formKey = GlobalKey<FormState>();

  /// Controller do campo nome (registro)
  final _nameController = TextEditingController();

  /// Controller do campo email
  final _emailController = TextEditingController();

  /// Controller do campo senha
  final _passwordController = TextEditingController();

  /// Controller de autenticação (estado + lógica)
  late final AuthController _controller;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Inicializa controller com repository injetado
    _controller = AuthController(repository: widget.authRepository);
  }

  @override
  void dispose() {
    // Libera recursos da memória
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SUBMIT AUTH
  // ---------------------------------------------------------------------------

  /// Executa fluxo de autenticação (login ou registro).
  ///
  /// Fluxo:
  /// 1. Valida formulário
  /// 2. Chama AuthController.submit
  /// 3. Se sucesso, chama callback onAuthenticated
  /// 4. Se erro, exibe mensagem
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Executa login ou registro
      final user = await _controller.submit(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Notifica tela superior (ex: navegação)
      await widget.onAuthenticated(user);
    } catch (error) {
      // Exibe erro na UI
      showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // Escuta mudanças no AuthController (loading/mode)
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),

                // Limita largura para layout tipo mobile/web responsivo
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),

                  child: SectionCard(
                    padding: const EdgeInsets.all(24),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ----------------------------------------------------------------
                          // HEADER
                          // ----------------------------------------------------------------
                          const Text(
                            '🐯 Tigre Servicos',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ----------------------------------------------------------------
                          // CAMPO NOME (somente no registro)
                          // ----------------------------------------------------------------
                          if (_controller.isRegisterMode) ...[
                            CustomTextField(
                              controller: _nameController,
                              label: 'Nome',
                              validator: (value) =>
                                  requiredField(value, 'o nome'),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // ----------------------------------------------------------------
                          // EMAIL
                          // ----------------------------------------------------------------
                          CustomTextField(
                            controller: _emailController,
                            label: 'E-mail',
                            keyboardType: TextInputType.emailAddress,
                            validator: email,
                          ),

                          const SizedBox(height: 16),

                          // ----------------------------------------------------------------
                          // SENHA
                          // ----------------------------------------------------------------
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Senha',
                            obscureText: true,
                            validator: (value) =>
                                requiredField(value, 'a senha'),
                          ),

                          const SizedBox(height: 24),

                          // ----------------------------------------------------------------
                          // BOTÃO SUBMIT
                          // ----------------------------------------------------------------
                          CustomButton(
                            label: _controller.isLoading
                                ? 'Processando...'
                                : _controller.isRegisterMode
                                ? 'Cadastrar'
                                : 'Entrar',
                            onPressed: _controller.isLoading ? null : _submit,
                          ),

                          const SizedBox(height: 12),

                          // ----------------------------------------------------------------
                          // TOGGLE LOGIN / REGISTER
                          // ----------------------------------------------------------------
                          TextButton(
                            onPressed: _controller.isLoading
                                ? null
                                : _controller.toggleMode,
                            child: Text(
                              _controller.isRegisterMode
                                  ? 'Ja tem conta? Realizar Login'
                                  : 'Cadastre-se',
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
