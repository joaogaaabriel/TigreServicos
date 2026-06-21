import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/repository/AuthRepository.dart';
import 'package:app_workmatch/shared/CustomButton.dart';
import 'package:app_workmatch/shared/SectionCard.dart';
import 'package:app_workmatch/core/theme/AppColors.dart';
import 'package:app_workmatch/dto/CadastroUsuarioDto.dart'
    hide CadastroUsuarioDto;
import 'package:app_workmatch/dto/CadastroProfissionalDto.dart'
    hide CadastroProfissionalDto;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

// ── Formatadores (equivalentes ao fmtCpf/fmtTel/fmtCep/fmtData do React) ─────

class _CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(_, TextEditingValue n) {
    var v = n.text.replaceAll(RegExp(r'\D'), '');
    if (v.length > 11) v = v.substring(0, 11);
    String f;
    if (v.length <= 3)
      f = v;
    else if (v.length <= 6)
      f = '${v.substring(0, 3)}.${v.substring(3)}';
    else if (v.length <= 9)
      f = '${v.substring(0, 3)}.${v.substring(3, 6)}.${v.substring(6)}';
    else
      f = '${v.substring(0, 3)}.${v.substring(3, 6)}.${v.substring(6, 9)}-${v.substring(9)}';
    return TextEditingValue(
        text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}

class _TelFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(_, TextEditingValue n) {
    var v = n.text.replaceAll(RegExp(r'\D'), '');
    if (v.length > 11) v = v.substring(0, 11);
    String f;
    if (v.length <= 2)
      f = '($v';
    else if (v.length <= 7)
      f = '(${v.substring(0, 2)}) ${v.substring(2)}';
    else
      f = '(${v.substring(0, 2)}) ${v.substring(2, 7)}-${v.substring(7)}';
    return TextEditingValue(
        text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}

class _CepFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(_, TextEditingValue n) {
    var v = n.text.replaceAll(RegExp(r'\D'), '');
    if (v.length > 8) v = v.substring(0, 8);
    final f = v.length > 5 ? '${v.substring(0, 5)}-${v.substring(5)}' : v;
    return TextEditingValue(
        text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}

class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(_, TextEditingValue n) {
    var v = n.text.replaceAll(RegExp(r'\D'), '');
    if (v.length > 8) v = v.substring(0, 8);
    String f;
    if (v.length <= 2)
      f = v;
    else if (v.length <= 4)
      f = '${v.substring(0, 2)}/${v.substring(2)}';
    else
      f = '${v.substring(0, 2)}/${v.substring(2, 4)}/${v.substring(4)}';
    return TextEditingValue(
        text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}

// ── AuthScreen ────────────────────────────────────────────────────────────────

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

class _AuthScreenState extends State<AuthScreen> {
  // ── Login
  final _loginCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  // ── Cadastro
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
  final _especialidadeC = TextEditingController();
  final _descricaoC = TextEditingController();
  final _expAnosC = TextEditingController();
  final _loginCadC = TextEditingController();
  final _senhaCadC = TextEditingController();

  String? _estadoSel;
  bool _isRegisterMode = false;
  int _step = 0;
  String? _perfil;

  bool _loading = false;
  bool _loadingCep = false;
  bool _showPass = false;

  // Erros inline por campo — equivalente ao errors{} do React
  Map<String, String> _errors = {};

  @override
  void dispose() {
    for (final c in [
      _loginCtrl,
      _senhaCtrl,
      _nomeC,
      _cpfC,
      _telefoneC,
      _dataNascC,
      _emailC,
      _cepC,
      _enderecoC,
      _numeroC,
      _complementoC,
      _cidadeC,
      _especialidadeC,
      _descricaoC,
      _expAnosC,
      _loginCadC,
      _senhaCadC,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isProfissional => _perfil == 'PROFISSIONAL';

  void _clearError(String key) =>
      setState(() => _errors = {..._errors}..remove(key));
  void _setErrors(Map<String, String> errs) => setState(() => _errors = errs);

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red.shade700 : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  static String _parseDateToIso(String input) {
    final s = input.trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) return s;
    final m1 = RegExp(r'^(\d{2})[/\-](\d{2})[/\-](\d{4})$').firstMatch(s);
    if (m1 != null) return '${m1.group(3)}-${m1.group(2)}-${m1.group(1)}';
    final m2 = RegExp(r'^(\d{2})(\d{2})(\d{4})$').firstMatch(s);
    if (m2 != null) return '${m2.group(3)}-${m2.group(2)}-${m2.group(1)}';
    return s;
  }

  // ── Busca CEP automática (igual ao handleChange do React para cep) ─────────

  Future<void> _buscarCep(String cep) async {
    final limpo = cep.replaceAll(RegExp(r'\D'), '');
    if (limpo.length != 8) return;
    setState(() => _loadingCep = true);
    try {
      final data = await widget.authRepository.buscarCep(limpo);
      if (data['erro'] == true) {
        _setErrors({..._errors, 'cep': 'CEP não encontrado'});
      } else {
        setState(() {
          _enderecoC.text = data['logradouro'] ?? '';
          _cidadeC.text = data['localidade'] ?? '';
          _estadoSel = data['uf'];
          _errors = {..._errors}..remove('cep');
        });
      }
    } catch (_) {
      _setErrors({..._errors, 'cep': 'Erro ao buscar CEP'});
    } finally {
      if (mounted) setState(() => _loadingCep = false);
    }
  }

  // ── Step 1: validação + CPF via API (igual ao handleStep1Next do React) ───

  Future<void> _handleStep1Next() async {
    final errs = <String, String>{};
    if (_nomeC.text.trim().isEmpty) errs['nome'] = 'Nome obrigatório';
    if (_cpfC.text.length < 14) errs['cpf'] = 'CPF inválido';
    if (_telefoneC.text.length < 14) errs['telefone'] = 'Telefone inválido';
    if (_dataNascC.text.length < 10) errs['dataNascimento'] = 'Obrigatório';
    if (errs.isNotEmpty) {
      _setErrors(errs);
      return;
    }

    setState(() => _loading = true);
    try {
      final cpfLimpo = _cpfC.text.replaceAll(RegExp(r'\D'), '');
      await widget.authRepository.validarCpf(cpfLimpo);
      setState(() {
        _errors = {};
        _step = 2;
      });
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.toLowerCase().contains('cpf')) {
        _setErrors({'cpf': msg});
      } else {
        _toast(msg, error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Step 2 ─────────────────────────────────────────────────────────────────

  void _handleStep2Next() {
    final errs = <String, String>{};
    if (!_emailC.text.contains('@')) errs['email'] = 'E-mail inválido';
    if (_cepC.text.replaceAll(RegExp(r'\D'), '').length < 8)
      errs['cep'] = 'CEP inválido';
    if (_enderecoC.text.trim().isEmpty)
      errs['endereco'] = 'Endereço obrigatório';
    if (_cidadeC.text.trim().isEmpty) errs['cidade'] = 'Cidade obrigatória';
    if (_estadoSel == null) errs['estado'] = 'Estado obrigatório';
    if (_isProfissional && _especialidadeC.text.trim().isEmpty)
      errs['especialidade'] = 'Especialidade obrigatória';
    if (errs.isNotEmpty) {
      _setErrors(errs);
      return;
    }
    setState(() {
      _errors = {};
      _step = 3;
    });
  }

  // ── Submit (igual ao handleSubmit do React) ────────────────────────────────

  Future<void> _handleSubmit() async {
    final errs = <String, String>{};
    if (_loginCadC.text.trim().length < 4)
      errs['login'] = 'Login mínimo de 4 caracteres';
    if (_senhaCadC.text.length < 6) errs['senha'] = 'Mínimo 6 caracteres';
    if (errs.isNotEmpty) {
      _setErrors(errs);
      return;
    }

    setState(() => _loading = true);
    try {
      final dataNasc = _parseDateToIso(_dataNascC.text);
      final enderecoCompleto = [
        _enderecoC.text.trim(),
        _numeroC.text.trim(),
        _complementoC.text.trim()
      ].where((s) => s.isNotEmpty).join(', ');

      // ── DEBUG: print de todos os dados antes de enviar ──────────────────
      print(
          '===== CADASTRO ${_isProfissional ? "PROFISSIONAL" : "CLIENTE"} =====');
      print('nome           : ${_nomeC.text.trim()}');
      print(
          'cpf            : ${_cpfC.text.replaceAll(RegExp(r'\D'), '')}  ← raw: ${_cpfC.text}');
      print('email          : ${_emailC.text.trim()}');
      print(
          'telefone       : ${_telefoneC.text.replaceAll(RegExp(r'\D'), '')}  ← raw: ${_telefoneC.text}');
      print('dataNascimento : $dataNasc  ← raw: ${_dataNascC.text}');
      print('endereco       : ${_enderecoC.text.trim()}');
      print('numero         : ${_numeroC.text.trim()}');
      print('complemento    : ${_complementoC.text.trim()}');
      print('enderecoCompleto: $enderecoCompleto');
      print('cidade         : ${_cidadeC.text.trim()}');
      print('estado         : $_estadoSel');
      print('login          : ${_loginCadC.text.trim()}');
      if (_isProfissional) {
        print('especialidade  : ${_especialidadeC.text.trim()}');
        print('descricao      : ${_descricaoC.text.trim()}');
        print('experienciaAnos: ${int.tryParse(_expAnosC.text) ?? 0}');
      }
      print('=================================');

      if (_isProfissional) {
        await widget.authRepository
            .cadastrarProfissional(CadastroProfissionalDto(
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
          role: 'PROFISSIONAL',
        ));
      } else {
        await widget.authRepository.cadastrarUsuario(CadastroUsuarioDto(
          nome: _nomeC.text.trim(),
          cpf: _cpfC.text.replaceAll(RegExp(r'\D'), ''),
          email: _emailC.text.trim(),
          telefone: _telefoneC.text.replaceAll(RegExp(r'\D'), ''),
          dataNascimento: dataNasc,
          endereco: enderecoCompleto,
          cidade: _cidadeC.text.trim(),
          estado: _estadoSel ?? '',
          login: _loginCadC.text.trim(),
          senha: _senhaCadC.text,
          role: 'CLIENTE',
          cep: _cepC.text.replaceAll(RegExp(r'\D'), ''),
          numero: _numeroC.text.trim(),
          complemento: _complementoC.text.trim(),
        ));
      }

      if (!mounted) return;
      _toast('Conta criada com sucesso!');
      setState(() {
        _isRegisterMode = false;
        _loginCtrl.text = _loginCadC.text;
        _step = 0;
        _perfil = null;
        _errors = {};
      });
    } on Exception catch (e) {
      // Extrai mensagem do backend — igual ao error.response?.data?.message do React
      final msg = e.toString().replaceFirst('Exception: ', '');
      print('===== ERRO BACKEND =====');
      print(e.toString());
      print('========================');
      _toast(msg.isNotEmpty ? msg : 'Erro ao criar conta.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    final login = _loginCtrl.text.trim();
    final senha = _senhaCtrl.text;
    if (login.isEmpty || senha.isEmpty) {
      _toast('Preencha login e senha.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final user =
          await widget.authRepository.login(login: login, senha: senha);
      if (!mounted) return;
      await widget.onAuthenticated(user);
    } on Exception catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
          children: List.generate(
              3,
              (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            _step >= i + 1 ? AppColors.navy : AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  )),
        ),
      );

  Widget _buildLogin() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(subtitle: 'Faça login com sua conta'),
          const SizedBox(height: 24),
          _field('Login', _loginCtrl),
          const SizedBox(height: 16),
          _fieldSenha('Senha', _senhaCtrl),
          const SizedBox(height: 24),
          CustomButton(
            label: _loading ? 'Entrando...' : 'Entrar',
            onPressed: _loading ? null : _handleLogin,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() {
              _isRegisterMode = true;
              _step = 0;
              _perfil = null;
              _errors = {};
            }),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.blue, padding: EdgeInsets.zero),
            child: const Text('Não tem conta? Cadastre-se',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      );

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
              onPressed: () => setState(() {
                _isRegisterMode = false;
                _step = 0;
                _perfil = null;
                _errors = {};
              }),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.blue, padding: EdgeInsets.zero),
              child: const Text('Já possui conta? Entrar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      );

  Widget _buildEscolhaPerfil() => Column(
        children: [
          CustomButton(
            label: 'Sou Cliente',
            icon: Icons.person_outline,
            onPressed: () => setState(() {
              _perfil = 'CLIENTE';
              _step = 1;
              _errors = {};
            }),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() {
                _perfil = 'PROFISSIONAL';
                _step = 1;
                _errors = {};
              }),
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

  Widget _buildStep1() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Nome completo', _nomeC,
              key: 'nome',
              hint: 'Seu nome completo',
              onChanged: (_) => _clearError('nome')),
          const SizedBox(height: 12),
          _field('CPF', _cpfC,
              key: 'cpf',
              hint: '000.000.000-00',
              keyboard: TextInputType.number,
              formatters: [_CpfFormatter()],
              onChanged: (_) => _clearError('cpf')),
          const SizedBox(height: 12),
          _field('Telefone', _telefoneC,
              key: 'telefone',
              hint: '(00) 00000-0000',
              keyboard: TextInputType.phone,
              formatters: [_TelFormatter()],
              onChanged: (_) => _clearError('telefone')),
          const SizedBox(height: 12),
          _field('Data de nascimento', _dataNascC,
              key: 'dataNascimento',
              hint: 'DD/MM/AAAA',
              keyboard: TextInputType.number,
              formatters: [_DateFormatter()],
              onChanged: (_) => _clearError('dataNascimento')),
          const SizedBox(height: 20),
          CustomButton(
            label: _loading ? 'Validando...' : 'Próximo',
            onPressed: _loading ? null : _handleStep1Next,
          ),
        ],
      );

  Widget _buildStep2() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('E-mail', _emailC,
              key: 'email',
              hint: 'seuemail@email.com',
              keyboard: TextInputType.emailAddress,
              onChanged: (_) => _clearError('email')),
          const SizedBox(height: 12),
          _field('CEP', _cepC,
              key: 'cep',
              hint: '00000-000',
              keyboard: TextInputType.number,
              formatters: [_CepFormatter()],
              suffix: _loadingCep
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.blue))
                  : null, onChanged: (v) {
            _clearError('cep');
            if (v.replaceAll(RegExp(r'\D'), '').length == 8) _buscarCep(v);
          }),
          const SizedBox(height: 12),
          _field('Endereço', _enderecoC,
              key: 'endereco',
              hint: 'Rua, Avenida...',
              onChanged: (_) => _clearError('endereco')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _field('Número', _numeroC,
                    hint: 'Ex.: 123', keyboard: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(
                child: _field('Complemento', _complementoC,
                    hint: 'Apto, Sala...')),
          ]),
          const SizedBox(height: 12),
          _field('Cidade', _cidadeC,
              key: 'cidade',
              hint: 'Sua cidade',
              onChanged: (_) => _clearError('cidade')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _estadoSel,
            decoration: InputDecoration(
              labelText: 'Estado',
              errorText: _errors['estado'],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: _errors['estado'] != null
                        ? Colors.red
                        : AppColors.border),
              ),
            ),
            items: _estados
                .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                .toList(),
            onChanged: (v) => setState(() {
              _estadoSel = v;
              _clearError('estado');
            }),
          ),
          if (_isProfissional) ...[
            const SizedBox(height: 12),
            _field('Especialidade', _especialidadeC,
                key: 'especialidade',
                hint: 'Ex.: Eletricista',
                onChanged: (_) => _clearError('especialidade')),
            const SizedBox(height: 12),
            _field('Descrição', _descricaoC,
                hint: 'Descreva sua experiência...', maxLines: 3),
            const SizedBox(height: 12),
            _field('Anos de experiência', _expAnosC,
                hint: 'Ex.: 5', keyboard: TextInputType.number),
          ],
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: _outlineBtn('Voltar', () => setState(() => _step = 1))),
            const SizedBox(width: 10),
            Expanded(
                child: CustomButton(
                    label: 'Próximo', onPressed: _handleStep2Next)),
          ]),
        ],
      );

  Widget _buildStep3() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Login', _loginCadC,
              key: 'login',
              hint: 'Mínimo 4 caracteres',
              onChanged: (_) => _clearError('login')),
          const SizedBox(height: 12),
          _fieldSenha('Senha', _senhaCadC, errorKey: 'senha'),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: _outlineBtn('Voltar', () => setState(() => _step = 2))),
            const SizedBox(width: 10),
            Expanded(
                child: CustomButton(
              label: _loading ? 'Criando conta...' : 'Criar Conta',
              onPressed: _loading ? null : _handleSubmit,
            )),
          ]),
        ],
      );

  // ── Widgets reutilizáveis ─────────────────────────────────────────────────

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? key,
    String? hint,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    int? maxLines,
    Widget? suffix,
    void Function(String)? onChanged,
  }) {
    final hasError = key != null && (_errors[key]?.isNotEmpty ?? false);
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      inputFormatters: formatters,
      maxLines: maxLines ?? 1,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: hasError ? _errors[key] : null,
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.all(12), child: suffix)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: hasError ? Colors.red : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: hasError ? Colors.red : AppColors.blue, width: 1.5),
        ),
      ),
    );
  }

  // Campo senha com ícone de cadeado e toggle olho — igual ao React
  Widget _fieldSenha(String label, TextEditingController ctrl,
      {String? errorKey}) {
    final hasError =
        errorKey != null && (_errors[errorKey]?.isNotEmpty ?? false);
    return TextField(
      controller: ctrl,
      obscureText: !_showPass,
      onChanged: errorKey != null ? (_) => _clearError(errorKey) : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Mínimo 6 caracteres',
        errorText: hasError ? _errors[errorKey] : null,
        prefixIcon: const Icon(Icons.lock_outline,
            size: 18, color: AppColors.textLight),
        suffixIcon: IconButton(
          icon: Icon(
            _showPass
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18,
            color: AppColors.textLight,
          ),
          onPressed: () => setState(() => _showPass = !_showPass),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: hasError ? Colors.red : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: hasError ? Colors.red : AppColors.blue, width: 1.5),
        ),
      ),
    );
  }

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
