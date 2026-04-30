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

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authRepository,
    required this.onAuthenticated,
  });

  final AuthRepository authRepository;
  final Future<void> Function(UserModel user) onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with UiFeedbackMixin, ValidatorMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(repository: widget.authRepository);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final user = await _controller.submit(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      await widget.onAuthenticated(user);
    } catch (error) {
      showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SectionCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '\u{1F42F} Tigre Servicos',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          /*Text(
                            _controller.isRegisterMode
                                ? 'Cadastro local simples para testar o fluxo do app.'
                                : 'Entre com seu cadastro salvo no aparelho.',
                            style: const TextStyle(color: Colors.black54),
                          ),*/
                          const SizedBox(height: 24),
                          if (_controller.isRegisterMode) ...[
                            CustomTextField(
                              controller: _nameController,
                              label: 'Nome',
                              validator: (value) =>
                                  requiredField(value, 'o nome'),
                            ),
                            const SizedBox(height: 16),
                          ],
                          CustomTextField(
                            controller: _emailController,
                            label: 'E-mail',
                            keyboardType: TextInputType.emailAddress,
                            validator: email,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Senha',
                            obscureText: true,
                            validator: (value) =>
                                requiredField(value, 'a senha'),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            label: _controller.isLoading
                                ? 'Processando...'
                                : _controller.isRegisterMode
                                    ? 'Cadastrar'
                                    : 'Entrar',
                            onPressed: _controller.isLoading ? null : _submit,
                          ),
                          const SizedBox(height: 12),
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
