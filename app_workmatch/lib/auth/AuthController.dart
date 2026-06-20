import 'package:flutter/foundation.dart';
import 'package:app_workmatch/dto/CadastroUsuarioDto.dart'
    hide CadastroUsuarioDto;
import 'package:app_workmatch/dto/CadastroProfissionalDto.dart'
    hide CadastroProfissionalDto;
import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/repository/AuthRepository.dart';

enum AuthMode { login, register }

enum AuthPerfil { none, cliente, profissional }

enum AuthStep { perfil, dados, endereco, acesso } // step 0→1→2→3

// ── Erros por campo ───────────────────────────────────────────────────────────

class FieldErrors {
  FieldErrors(this._map);
  final Map<String, String> _map;

  String? operator [](String key) => _map[key];
  bool get isEmpty => _map.isEmpty;
  FieldErrors clear(String key) => FieldErrors(Map.from(_map)..remove(key));
  FieldErrors merge(Map<String, String> extra) =>
      FieldErrors({..._map, ...extra});
  static FieldErrors empty() => FieldErrors({});
}

// ── Modelo do formulário ──────────────────────────────────────────────────────

class CadastroForm {
  CadastroForm({
    this.nome = '',
    this.cpf = '',
    this.telefone = '',
    this.dataNascimento = '',
    this.email = '',
    this.cep = '',
    this.endereco = '',
    this.numero = '',
    this.complemento = '',
    this.cidade = '',
    this.estado = '',
    this.especialidade = '',
    this.descricao = '',
    this.experienciaAnos = '',
    this.login = '',
    this.senha = '',
  });

  final String nome, cpf, telefone, dataNascimento;
  final String email, cep, endereco, numero, complemento, cidade, estado;
  final String especialidade, descricao, experienciaAnos;
  final String login, senha;

  CadastroForm copyWith({
    String? nome,
    String? cpf,
    String? telefone,
    String? dataNascimento,
    String? email,
    String? cep,
    String? endereco,
    String? numero,
    String? complemento,
    String? cidade,
    String? estado,
    String? especialidade,
    String? descricao,
    String? experienciaAnos,
    String? login,
    String? senha,
  }) =>
      CadastroForm(
        nome: nome ?? this.nome,
        cpf: cpf ?? this.cpf,
        telefone: telefone ?? this.telefone,
        dataNascimento: dataNascimento ?? this.dataNascimento,
        email: email ?? this.email,
        cep: cep ?? this.cep,
        endereco: endereco ?? this.endereco,
        numero: numero ?? this.numero,
        complemento: complemento ?? this.complemento,
        cidade: cidade ?? this.cidade,
        estado: estado ?? this.estado,
        especialidade: especialidade ?? this.especialidade,
        descricao: descricao ?? this.descricao,
        experienciaAnos: experienciaAnos ?? this.experienciaAnos,
        login: login ?? this.login,
        senha: senha ?? this.senha,
      );
}

// ── Controller ────────────────────────────────────────────────────────────────

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  // ── Estado ────────────────────────────────────────────────────────────────

  AuthMode _mode = AuthMode.login;
  AuthPerfil _perfil = AuthPerfil.none;
  AuthStep _step = AuthStep.perfil;
  bool _loading = false;
  bool _loadingCep = false;
  bool _showPass = false;
  CadastroForm _form = CadastroForm();
  FieldErrors _errors = FieldErrors.empty();

  // Toast temporário
  String? _toastMsg;
  bool _toastError = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  AuthMode get mode => _mode;
  AuthPerfil get perfil => _perfil;
  AuthStep get step => _step;
  bool get loading => _loading;
  bool get loadingCep => _loadingCep;
  bool get showPass => _showPass;
  CadastroForm get form => _form;
  FieldErrors get errors => _errors;
  bool get isRegisterMode => _mode == AuthMode.register;
  bool get isProfissional => _perfil == AuthPerfil.profissional;
  String? get toastMsg => _toastMsg;
  bool get toastError => _toastError;

  // ── Modo ──────────────────────────────────────────────────────────────────

  void toggleMode() {
    _mode = isRegisterMode ? AuthMode.login : AuthMode.register;
    _resetCadastro();
    notifyListeners();
  }

  void setMode(AuthMode mode) {
    _mode = mode;
    _resetCadastro();
    notifyListeners();
  }

  void _resetCadastro() {
    _perfil = AuthPerfil.none;
    _step = AuthStep.perfil;
    _form = CadastroForm();
    _errors = FieldErrors.empty();
    _toastMsg = null;
  }

  // ── Escolher perfil (step 0 → 1) ─────────────────────────────────────────

  void escolherPerfil(AuthPerfil tipo) {
    _perfil = tipo;
    _form = CadastroForm();
    _errors = FieldErrors.empty();
    _step = AuthStep.dados;
    notifyListeners();
  }

  void voltarParaPerfil() {
    _perfil = AuthPerfil.none;
    _step = AuthStep.perfil;
    _errors = FieldErrors.empty();
    notifyListeners();
  }

  // ── Formatadores (igual ao React) ─────────────────────────────────────────

  static String fmtCpf(String v) {
    v = v.replaceAll(RegExp(r'\D'), '');
    if (v.length > 11) v = v.substring(0, 11);
    if (v.length <= 3) return v;
    if (v.length <= 6) return '${v.substring(0, 3)}.${v.substring(3)}';
    if (v.length <= 9)
      return '${v.substring(0, 3)}.${v.substring(3, 6)}.${v.substring(6)}';
    return '${v.substring(0, 3)}.${v.substring(3, 6)}.${v.substring(6, 9)}-${v.substring(9)}';
  }

  static String fmtTel(String v) {
    v = v.replaceAll(RegExp(r'\D'), '');
    if (v.length > 11) v = v.substring(0, 11);
    if (v.length <= 2) return '($v';
    if (v.length <= 7) return '(${v.substring(0, 2)}) ${v.substring(2)}';
    return '(${v.substring(0, 2)}) ${v.substring(2, 7)}-${v.substring(7)}';
  }

  static String fmtCep(String v) {
    v = v.replaceAll(RegExp(r'\D'), '');
    if (v.length > 8) v = v.substring(0, 8);
    return v.length > 5 ? '${v.substring(0, 5)}-${v.substring(5)}' : v;
  }

  // ── Atualizar campo ───────────────────────────────────────────────────────

  /// Formata data como DD/MM/AAAA ao digitar
  static String fmtData(String v) {
    v = v.replaceAll(RegExp(r'\D'), '');
    if (v.length > 8) v = v.substring(0, 8);
    if (v.length <= 2) return v;
    if (v.length <= 4) return '${v.substring(0, 2)}/${v.substring(2)}';
    return '${v.substring(0, 2)}/${v.substring(2, 4)}/${v.substring(4)}';
  }

  void updateField(String name, String raw) {
    String value = raw;
    if (name == 'cpf') value = fmtCpf(raw);
    if (name == 'telefone') value = fmtTel(raw);
    if (name == 'dataNascimento') value = fmtData(raw);
    if (name == 'cep') {
      value = fmtCep(raw);
      if (value.replaceAll(RegExp(r'\D'), '').length == 8) {
        _buscarCep(value);
      }
    }

    _form = _setField(name, value);
    _errors = _errors.clear(name);
    notifyListeners();
  }

  CadastroForm _setField(String name, String v) {
    switch (name) {
      case 'nome':
        return _form.copyWith(nome: v);
      case 'cpf':
        return _form.copyWith(cpf: v);
      case 'telefone':
        return _form.copyWith(telefone: v);
      case 'dataNascimento':
        return _form.copyWith(dataNascimento: v);
      case 'email':
        return _form.copyWith(email: v);
      case 'cep':
        return _form.copyWith(cep: v);
      case 'endereco':
        return _form.copyWith(endereco: v);
      case 'numero':
        return _form.copyWith(numero: v);
      case 'complemento':
        return _form.copyWith(complemento: v);
      case 'cidade':
        return _form.copyWith(cidade: v);
      case 'estado':
        return _form.copyWith(estado: v);
      case 'especialidade':
        return _form.copyWith(especialidade: v);
      case 'descricao':
        return _form.copyWith(descricao: v);
      case 'experienciaAnos':
        return _form.copyWith(experienciaAnos: v);
      case 'login':
        return _form.copyWith(login: v);
      case 'senha':
        return _form.copyWith(senha: v);
      default:
        return _form;
    }
  }

  void toggleShowPass() {
    _showPass = !_showPass;
    notifyListeners();
  }

  // ── Busca CEP (ViaCEP) — igual ao React ──────────────────────────────────

  Future<void> _buscarCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'\D'), '');
    _loadingCep = true;
    notifyListeners();
    try {
      // Usa ApiClient para não depender de http direto
      final res = await _repository.buscarCep(cepLimpo);
      if (res['erro'] == true) {
        _errors = _errors.merge({'cep': 'CEP não encontrado'});
      } else {
        _form = _form.copyWith(
          endereco: res['logradouro'] ?? '',
          cidade: res['localidade'] ?? '',
          estado: res['uf'] ?? '',
        );
      }
    } catch (_) {
      _errors = _errors.merge({'cep': 'Erro ao buscar CEP'});
    } finally {
      _loadingCep = false;
      notifyListeners();
    }
  }

  // ── Validadores (igual ao React) ──────────────────────────────────────────

  Map<String, String> _validateStep1() {
    final e = <String, String>{};
    if (_form.nome.trim().isEmpty) e['nome'] = 'Nome obrigatório';
    if (_form.cpf.length < 14) e['cpf'] = 'CPF inválido';
    if (_form.telefone.length < 14) e['telefone'] = 'Telefone inválido';
    if (_form.dataNascimento.isEmpty) e['dataNascimento'] = 'Obrigatório';
    return e;
  }

  Map<String, String> _validateStep2() {
    final e = <String, String>{};
    if (!_form.email.contains('@')) e['email'] = 'E-mail inválido';
    if (_form.cep.replaceAll(RegExp(r'\D'), '').length < 8)
      e['cep'] = 'CEP inválido';
    if (_form.endereco.trim().isEmpty) e['endereco'] = 'Endereço obrigatório';
    if (_form.cidade.trim().isEmpty) e['cidade'] = 'Cidade obrigatória';
    if (_form.estado.isEmpty) e['estado'] = 'Estado obrigatório';
    if (isProfissional && _form.especialidade.trim().isEmpty)
      e['especialidade'] = 'Especialidade obrigatória';
    return e;
  }

  Map<String, String> _validateStep3() {
    final e = <String, String>{};
    if (_form.login.trim().length < 4)
      e['login'] = 'Login mínimo de 4 caracteres';
    if (_form.senha.length < 6) e['senha'] = 'Mínimo 6 caracteres';
    return e;
  }

  // ── Step 1 → 2: valida CPF via API (igual ao React) ──────────────────────

  Future<bool> handleStep1Next() async {
    final errs = _validateStep1();
    if (errs.isNotEmpty) {
      _errors = FieldErrors(errs);
      notifyListeners();
      return false;
    }

    _loading = true;
    notifyListeners();
    try {
      final cpfLimpo = _form.cpf.replaceAll(RegExp(r'\D'), '');

      // 1. Valida formato
      await _repository.validarCpf(cpfLimpo);

      _step = AuthStep.endereco;
      return true;
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      // Mapeia mensagem do backend para campo
      if (msg.toLowerCase().contains('cpf')) {
        _errors = FieldErrors({'cpf': msg});
      } else {
        _showToast(msg, error: true);
      }
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Step 2 → 3 ────────────────────────────────────────────────────────────

  bool handleStep2Next() {
    final errs = _validateStep2();
    if (errs.isNotEmpty) {
      _errors = FieldErrors(errs);
      notifyListeners();
      return false;
    }
    _step = AuthStep.acesso;
    _errors = FieldErrors.empty();
    notifyListeners();
    return true;
  }

  void voltarStep() {
    if (_step == AuthStep.acesso)
      _step = AuthStep.endereco;
    else if (_step == AuthStep.endereco)
      _step = AuthStep.dados;
    else if (_step == AuthStep.dados) voltarParaPerfil();
    _errors = FieldErrors.empty();
    notifyListeners();
  }

  // ── Submit final (igual ao React handleSubmit) ────────────────────────────

  Future<UserModel?> handleSubmit() async {
    final errs = _validateStep3();
    if (errs.isNotEmpty) {
      _errors = FieldErrors(errs);
      notifyListeners();
      return null;
    }

    _loading = true;
    notifyListeners();

    try {
      // Monta endereço concatenado igual ao React
      final enderecoCompleto = [_form.endereco, _form.numero, _form.complemento]
          .where((s) => s.trim().isNotEmpty)
          .join(', ');

      if (isProfissional) {
        await _repository.cadastrarProfissional(CadastroProfissionalDto(
          nome: _form.nome,
          cpf: _form.cpf,
          email: _form.email,
          telefone: _form.telefone,
          dataNascimento: _parseDateToIso(_form.dataNascimento),
          cep: _form.cep,
          endereco: _form.endereco,
          numero: _form.numero,
          complemento: _form.complemento,
          cidade: _form.cidade,
          estado: _form.estado,
          especialidade: _form.especialidade,
          descricao: _form.descricao,
          experienciaAnos: int.tryParse(_form.experienciaAnos) ?? 0,
          login: _form.login,
          senha: _form.senha,
        ));
      } else {
        await _repository.cadastrarUsuario(CadastroUsuarioDto(
          nome: _form.nome,
          cpf: _form.cpf,
          email: _form.email,
          telefone: _form.telefone,
          dataNascimento: _parseDateToIso(_form.dataNascimento),
          endereco: enderecoCompleto,
          cidade: _form.cidade,
          estado: _form.estado,
          login: _form.login,
          senha: _form.senha,
          role: 'CLIENTE',
          cep: '',
          numero: '',
          complemento: '',
        ));
      }

      _showToast('Conta criada com sucesso!', error: false);
      _resetCadastro();
      return null; // caller redireciona para login
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showToast(msg.isNotEmpty ? msg : 'Erro ao criar conta.', error: true);
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<UserModel?> login({
    required String login,
    required String senha,
  }) async {
    if (login.trim().isEmpty || senha.isEmpty) {
      _showToast('Preencha login e senha.', error: true);
      return null;
    }
    _loading = true;
    notifyListeners();
    try {
      final user = await _repository.login(login: login, senha: senha);
      return user;
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showToast(msg.isNotEmpty ? msg : 'Erro ao conectar.', error: true);
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Toast ─────────────────────────────────────────────────────────────────

  void _showToast(String msg, {required bool error}) {
    _toastMsg = msg;
    _toastError = error;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), clearToast);
  }

  void clearToast() {
    _toastMsg = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Converte DD/MM/AAAA, DD-MM-AAAA ou DDMMAAAA → AAAA-MM-DD
  static String _parseDateToIso(String input) {
    final s = input.trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) return s;
    final m1 = RegExp(r'^(\d{2})[/\-](\d{2})[/\-](\d{4})$').firstMatch(s);
    if (m1 != null) return '${m1.group(3)}-${m1.group(2)}-${m1.group(1)}';
    final m2 = RegExp(r'^(\d{2})(\d{2})(\d{4})$').firstMatch(s);
    if (m2 != null) return '${m2.group(3)}-${m2.group(2)}-${m2.group(1)}';
    return s;
  }
}
