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
    required this.onLoginSuccess,
    required this.onRegisterSuccess,
  });

  final AuthRepository authRepository;
  final Future<void> Function(UserModel user) onLoginSuccess;
  final Future<void> Function() onRegisterSuccess;

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
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_controller.isRegisterMode) {
        await _controller.submit(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;

        // Limpa os campos
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();

        // Volta para modo login primeiro, depois mostra mensagem
        _controller.toggleMode();
        showMessage('Cadastro realizado! Faca login para continuar.');

        // Notifica o AppController que o cadastro foi concluído
        await widget.onRegisterSuccess();
      } else {
        final user = await _controller.submit(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        await widget.onLoginSuccess(user);
      }
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
          resizeToAvoidBottomInset: true,
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
                            '🐯 Tigre Servicos',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _controller.isRegisterMode
                                ? 'Crie sua conta para continuar'
                                : 'Entre com suas credenciais',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 24),
                          if (_controller.isRegisterMode) ...[
                            CustomTextField(
                              controller: _nameController,
                              label: 'Nome',
                              autofocus: true,
                              validator: (value) =>
                                  requiredField(value, 'o nome'),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Email — obscureText: false garante que nunca fica com bolinhas
                          CustomTextField(
                            controller: _emailController,
                            label: 'E-mail',
                            autofocus: !_controller.isRegisterMode,
                            keyboardType: TextInputType.emailAddress,
                            obscureText: false,
                            validator: email,
                          ),
                          const SizedBox(height: 16),
                          // Senha — obscureText: true ativa o olho
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
