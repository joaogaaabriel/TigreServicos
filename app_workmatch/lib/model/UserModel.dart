class UserModel {
  final String id;
  final String nome;
  final String email;
  final String login;
  final String role;
  final String? token;
  final String? cpf;
  final String? telefone;
  final String? cidade;
  final String? estado;
  final String? especialidade;

  const UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.login,
    required this.role,
    this.token,
    this.cpf,
    this.telefone,
    this.cidade,
    this.estado,
    this.especialidade,
  });

  bool get isProfissional => role == 'PROFISSIONAL';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        nome: json['nome']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        login: json['login']?.toString() ?? '',
        role: json['role']?.toString() ?? 'CLIENTE',
        token: json['token']?.toString(),
        cpf: json['cpf']?.toString(),
        telefone: json['telefone']?.toString(),
        cidade: json['cidade']?.toString(),
        estado: json['estado']?.toString(),
        especialidade: json['especialidade']?.toString(),
      );

  static Function(Map<String, Object?> e)? get fromMap => null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'login': login,
        'role': role,
        if (token != null) 'token': token,
        if (cpf != null) 'cpf': cpf,
        if (telefone != null) 'telefone': telefone,
        if (cidade != null) 'cidade': cidade,
        if (estado != null) 'estado': estado,
        if (especialidade != null) 'especialidade': especialidade,
      };

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'login': login,
      'role': role,
      'token': token,
      'cpf': cpf,
      'telefone': telefone,
      'cidade': cidade,
      'estado': estado,
      'especialidade': especialidade,
    };
  }
}

class CadastroUsuarioDto {
  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String dataNascimento; // 'YYYY-MM-DD'
  final String cep;
  final String endereco;
  final String numero;
  final String complemento;
  final String cidade;
  final String estado;
  final String login;
  final String senha;
  final String role;

  const CadastroUsuarioDto({
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.dataNascimento,
    required this.cep,
    required this.endereco,
    required this.numero,
    required this.complemento,
    required this.cidade,
    required this.estado,
    required this.login,
    required this.senha,
    this.role = 'CLIENTE',
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'cpf': cpf,
        'email': email,
        'telefone': telefone,
        'dataNascimento': dataNascimento,
        'cep': cep,
        'endereco': endereco,
        'numero': numero,
        'complemento': complemento,
        'cidade': cidade,
        'estado': estado,
        'login': login,
        'senha': senha,
        'role': role,
      };
}

class CadastroProfissionalDto {
  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String dataNascimento;
  final String cep;
  final String endereco;
  final String numero;
  final String complemento;
  final String cidade;
  final String estado;
  final String especialidade;
  final String descricao;
  final int experienciaAnos;
  final String login;
  final String senha;

  const CadastroProfissionalDto({
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.dataNascimento,
    required this.cep,
    required this.endereco,
    required this.numero,
    required this.complemento,
    required this.cidade,
    required this.estado,
    required this.especialidade,
    required this.descricao,
    required this.experienciaAnos,
    required this.login,
    required this.senha,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'cpf': cpf,
        'email': email,
        'telefone': telefone,
        'dataNascimento': dataNascimento,
        'cep': cep,
        'endereco': endereco,
        'numero': numero,
        'complemento': complemento,
        'cidade': cidade,
        'estado': estado,
        'especialidade': especialidade,
        'descricao': descricao,
        'experienciaAnos': experienciaAnos,
        'login': login,
        'senha': senha,
      };
}
