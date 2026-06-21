class CadastroProfissionalDto {
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
  // role é sempre 'PROFISSIONAL' — não precisa de parâmetro

  Map<String, dynamic> toJson() {
    final enderecoCompleto =
        [endereco, numero, complemento].where((s) => s.isNotEmpty).join(', ');

    return {
      'nome': nome,
      'cpf': cpf.replaceAll(RegExp(r'\D'), ''),
      'telefone': telefone.replaceAll(RegExp(r'\D'), ''),
      'email': email,
      'dataNascimento': dataNascimento,
      'endereco': enderecoCompleto,
      'cidade': cidade,
      'estado': estado,
      'login': login,
      'senha': senha,
      'role': 'PROFISSIONAL', // sempre fixo — nunca depende do parâmetro
      'especialidade': especialidade,
      'descricao': descricao,
      'experienciaAnos': experienciaAnos,
    };
  }
}
