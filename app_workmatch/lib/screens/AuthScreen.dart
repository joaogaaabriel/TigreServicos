import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/repository/AuthRepository.dart';
import 'package:app_workmatch/tigreservicos/core/mixins/UiFeedbackMixin.dart';
import 'package:app_workmatch/tigreservicos/core/mixins/ValidatorMixin.dart';
import 'package:app_workmatch/tigreservicos/core/theme/AppColors.dart';
import 'package:app_workmatch/tigreservicos/modules/auth/AuthController.dart';
import 'package:app_workmatch/tigreservicos/shared/CustomButton.dart';
import 'package:app_workmatch/tigreservicos/shared/CustomTextField.dart';
import 'package:app_workmatch/tigreservicos/shared/SectionCard.dart';
import 'package:flutter/material.dart';

// ── Constantes ────────────────────────────────────────────────────────────────

const _estados = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MT',
  'MS',
  'MG',
  'PA',
  'PB',
  'PR',
  'PE',
  'PI',
  'RJ',
  'RN',
  'RS',
  'RO',
  'RR',
  'SC',
  'SP',
  'SE',
  'TO',
];

const _stepLabels = ['', 'Dados pessoais', 'Endereço', 'Acesso'];

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
  // Controlador de login simples
  final _loginController = TextEditingController();
  final _senhaController = TextEditingController();
  late final AuthController _controller;

  bool _isLoading = false;
  bool _isRegisterMode = false;

  int _step = 0;
  String? _perfil;

  // Campos do formulário de cadastro
  final _nomeC = TextEditingController();
  final _cpfC = TextEditingController();
  final _telefoneC = TextEditingController();
  final _dataNascC = TextEditingController();
  final _emailC = TextEditingController();
  final _cepC = TextEditingController();
  final _enderecoC = TextEditingController();
  final _numeroC = TextEditingController();
  final _complementoC = TextEditingController();
  final _cidadeC = TextEditingController();
  String? _estadoSel;
  final _especialidadeC = TextEditingController();
  final _descricaoC = TextEditingController();
  final _expAnosC = TextEditingController();
  final _loginCadC = TextEditingController();
  final _senhaCadC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AuthController(repository: widget.authRepository);
  }

  @override
  void dispose() {
    _controller.dispose();
    _loginController.dispose();
    _senhaController.dispose();
    _nomeC.dispose();
    _cpfC.dispose();
    _telefoneC.dispose();
    _dataNascC.dispose();
    _emailC.dispose();
    _cepC.dispose();
    _enderecoC.dispose();
    _numeroC.dispose();
    _complementoC.dispose();
    _cidadeC.dispose();
    _especialidadeC.dispose();
    _descricaoC.dispose();
    _expAnosC.dispose();
    _loginCadC.dispose();
    _senhaCadC.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final login = _loginController.text.trim();
    final senha = _senhaController.text;

    if (login.isEmpty) {
      showMessage('Informe o login');
      return;
    }
    if (senha.isEmpty) {
      showMessage('Informe a senha');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await widget.authRepository.login(
        login: login,
        senha: senha,
      );
      if (!mounted) return;
      await widget.onAuthenticated(user);
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _escolherPerfil(String perfil) => setState(() {
        _perfil = perfil;
        _step = 1;
      });

  bool get _isProfissional => _perfil == 'PROFISSIONAL';

  void _nextStep1() {
    if (_nomeC.text.trim().isEmpty) {
      showMessage('Nome obrigatório');
      return;
    }
    if (_cpfC.text.replaceAll(RegExp(r'\D'), '').length < 11) {
      showMessage('CPF inválido');
      return;
    }
    if (_telefoneC.text.replaceAll(RegExp(r'\D'), '').length < 10) {
      showMessage('Telefone inválido');
      return;
    }
    if (_dataNascC.text.isEmpty) {
      showMessage('Data de nascimento obrigatória');
      return;
    }
    setState(() => _step = 2);
  }

  void _nextStep2() {
    if (!_emailC.text.contains('@')) {
      showMessage('E-mail inválido');
      return;
    }
    if (_cepC.text.replaceAll(RegExp(r'\D'), '').length < 8) {
      showMessage('CEP inválido');
      return;
    }
    if (_enderecoC.text.trim().isEmpty) {
      showMessage('Endereço obrigatório');
      return;
    }
    if (_cidadeC.text.trim().isEmpty) {
      showMessage('Cidade obrigatória');
      return;
    }
    if (_estadoSel == null) {
      showMessage('Selecione o estado');
      return;
    }
    if (_isProfissional && _especialidadeC.text.trim().isEmpty) {
      showMessage('Especialidade obrigatória');
      return;
    }
    setState(() => _step = 3);
  }

  // ── Cadastro — POST /api/usuarios ou /api/profissionais ─────────────────

  Future<void> _submitCadastro() async {
    if (_loginCadC.text.trim().length < 4) {
      showMessage('Login mínimo de 4 caracteres');
      return;
    }
    if (_senhaCadC.text.length < 6) {
      showMessage('Senha mínimo de 6 caracteres');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dataNasc = _parseDateToIso(_dataNascC.text);

      if (_isProfissional) {
        await widget.authRepository.cadastrarProfissional(
          CadastroProfissionalDto(
            nome: _nomeC.text.trim(),
            cpf: _cpfC.text.replaceAll(RegExp(r'\D'), ''),
            email: _emailC.text.trim(),
            telefone: _telefoneC.text.replaceAll(RegExp(r'\D'), ''),
            dataNascimento: dataNasc,
            cep: _cepC.text.replaceAll(RegExp(r'\D'), ''),
            endereco: _enderecoC.text.trim(),
            numero: _numeroC.text.trim(),
            complemento: _complementoC.text.trim(),
            cidade: _cidadeC.text.trim(),
            estado: _estadoSel ?? '',
            especialidade: _especialidadeC.text.trim(),
            descricao: _descricaoC.text.trim(),
            experienciaAnos: int.tryParse(_expAnosC.text) ?? 0,
            login: _loginCadC.text.trim(),
            senha: _senhaCadC.text,
          ),
        );
      } else {
        await widget.authRepository.cadastrarUsuario(
          CadastroUsuarioDto(
            nome: _nomeC.text.trim(),
            cpf: _cpfC.text.replaceAll(RegExp(r'\D'), ''),
            email: _emailC.text.trim(),
            telefone: _telefoneC.text.replaceAll(RegExp(r'\D'), ''),
            dataNascimento: dataNasc,
            cep: _cepC.text.replaceAll(RegExp(r'\D'), ''),
            endereco: _enderecoC.text.trim(),
            numero: _numeroC.text.trim(),
            complemento: _complementoC.text.trim(),
            cidade: _cidadeC.text.trim(),
            estado: _estadoSel ?? '',
            login: _loginCadC.text.trim(),
            senha: _senhaCadC.text,
            role: 'CLIENTE',
          ),
        );
      }

      if (!mounted) return;
      showMessage('Cadastro realizado com sucesso!');
      setState(() {
        setState(() => _isRegisterMode = !_isRegisterMode);
        _loginController.text = _loginCadC.text;
        _step = 0;
        _perfil = null;
      });
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Converte DD/MM/AAAA ou YYYY-MM-DD para YYYY-MM-DD
  String _parseDateToIso(String input) {
    final parts = input.split('/');
    if (parts.length == 3 && parts[0].length == 2) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return input; // já está no formato ISO
  }

  void _goToMode(bool register) => setState(() {
        setState(() => _isRegisterMode = !_isRegisterMode);
        _step = 0;
        _perfil = null;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SectionCard(
                padding: const EdgeInsets.all(28),
                child: _isRegisterMode ? _buildCadastro() : _buildLogin(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Cabeçalho comum ───────────────────────────────────────────────────────

  Widget _buildHeader({required String subtitle}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy),
              children: [
                TextSpan(text: 'Work'),
                TextSpan(
                    text: 'Match', style: TextStyle(color: AppColors.blue)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.textMid)),
        ],
      );

  Widget _buildStepBar() => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Row(
          children: List.generate(3, (i) {
            final n = i + 1;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: _step >= n ? AppColors.navy : AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
      );

  Widget _buildLogin() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(subtitle: 'Faça login com sua conta'),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _loginController,
            label: 'Login',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _senhaController,
            label: 'Senha',
            obscureText: true,
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: _isLoading ? 'Entrando...' : 'Entrar',
            onPressed: _isLoading
                ? null
                : () async {
                    print('>>> DIRETO NO BOTÃO');
                    final login = _loginController.text.trim();
                    final senha = _senhaController.text;
                    print('>>> login=$login senha=$senha');
                    if (login.isEmpty || senha.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preencha os campos')),
                      );
                      return;
                    }
                    setState(() => _isLoading = true);
                    try {
                      final user = await widget.authRepository.login(
                        login: login,
                        senha: senha,
                      );
                      print('>>> user: ${user.toJson()}');
                      if (!mounted) return;
                      await widget.onAuthenticated(user);
                    } catch (e) {
                      print('>>> erro: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _goToMode(true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.blue, padding: EdgeInsets.zero),
            child: const Text('Não tem conta? Cadastre-se',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      );

  // ── Cadastro ──────────────────────────────────────────────────────────────

  Widget _buildCadastro() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            subtitle: _perfil == null
                ? 'Crie sua conta gratuita'
                : 'Passo $_step de 3 — ${_stepLabels[_step]}',
          ),
          if (_perfil != null) _buildStepBar(),
          const SizedBox(height: 20),
          if (_perfil == null) _buildEscolhaPerfil(),
          if (_perfil != null && _step == 1) _buildStep1(),
          if (_perfil != null && _step == 2) _buildStep2(),
          if (_perfil != null && _step == 3) _buildStep3(),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => _goToMode(false),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.blue, padding: EdgeInsets.zero),
              child: const Text('Já possui conta? Entrar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      );

  // ── Passo 0: Escolher perfil ──────────────────────────────────────────────

  Widget _buildEscolhaPerfil() => Column(
        children: [
          CustomButton(
            label: 'Sou Cliente',
            icon: Icons.person_outline,
            onPressed: () => _escolherPerfil('CLIENTE'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _escolherPerfil('PROFISSIONAL'),
              icon: const Icon(Icons.construction_outlined, size: 18),
              label: const Text('Sou Profissional'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.navy, width: 1.5),
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      );

  // ── Passo 1: Dados pessoais ───────────────────────────────────────────────

  Widget _buildStep1() => Column(
        children: [
          CustomTextField(controller: _nomeC, label: 'Nome completo'),
          const SizedBox(height: 12),
          CustomTextField(
              controller: _cpfC,
              label: 'CPF',
              hint: '000.000.000-00',
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          CustomTextField(
              controller: _telefoneC,
              label: 'Telefone',
              hint: '(00) 00000-0000',
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          CustomTextField(
              controller: _dataNascC,
              label: 'Data de nascimento',
              hint: 'DD/MM/AAAA',
              keyboardType: TextInputType.datetime),
          const SizedBox(height: 20),
          CustomButton(label: 'Próximo', onPressed: _nextStep1),
        ],
      );

  // ── Passo 2: Endereço ─────────────────────────────────────────────────────

  Widget _buildStep2() => Column(
        children: [
          CustomTextField(
              controller: _emailC,
              label: 'E-mail',
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          CustomTextField(
              controller: _cepC,
              label: 'CEP',
              hint: '00000-000',
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          CustomTextField(
              controller: _enderecoC,
              label: 'Endereço',
              hint: 'Rua, Avenida...'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: CustomTextField(
                    controller: _numeroC,
                    label: 'Número',
                    hint: 'Ex.: 123',
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(
                child: CustomTextField(
                    controller: _complementoC,
                    label: 'Complemento',
                    hint: 'Apto, Sala...')),
          ]),
          const SizedBox(height: 12),
          CustomTextField(controller: _cidadeC, label: 'Cidade'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _estadoSel,
            decoration: const InputDecoration(labelText: 'Estado'),
            items: _estados
                .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                .toList(),
            onChanged: (v) => setState(() => _estadoSel = v),
          ),
          if (_isProfissional) ...[
            const SizedBox(height: 12),
            CustomTextField(
                controller: _especialidadeC,
                label: 'Especialidade',
                hint: 'Ex.: Eletricista'),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _descricaoC,
                label: 'Descrição',
                hint: 'Descreva sua experiência...',
                maxLines: 3),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _expAnosC,
                label: 'Anos de experiência',
                hint: 'Ex.: 5',
                keyboardType: TextInputType.number),
          ],
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: _outlineBtn('Voltar', () => setState(() => _step = 1))),
            const SizedBox(width: 10),
            Expanded(
                child: CustomButton(label: 'Próximo', onPressed: _nextStep2)),
          ]),
        ],
      );

  // ── Passo 3: Acesso ───────────────────────────────────────────────────────

  Widget _buildStep3() => Column(
        children: [
          CustomTextField(
              controller: _loginCadC,
              label: 'Login',
              hint: 'Mínimo 4 caracteres'),
          const SizedBox(height: 12),
          CustomTextField(
              controller: _senhaCadC,
              label: 'Senha',
              hint: 'Mínimo 6 caracteres',
              obscureText: true),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: _outlineBtn('Voltar', () => setState(() => _step = 2))),
            const SizedBox(width: 10),
            Expanded(
                child: CustomButton(
              label: _isLoading ? 'Criando conta...' : 'Criar Conta',
              onPressed: _isLoading ? null : _submitCadastro,
            )),
          ]),
        ],
      );

  // ── Helper: botão outline ─────────────────────────────────────────────────

  Widget _outlineBtn(String label, VoidCallback onPressed) => SizedBox(
        height: 54,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.navy,
            side: const BorderSide(color: AppColors.navy, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          child: Text(label),
        ),
      );
}
