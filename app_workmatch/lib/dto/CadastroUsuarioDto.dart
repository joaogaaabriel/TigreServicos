/// DTO de cadastro — usado tanto para CLIENTE quanto para PROFISSIONAL.
/// O campo [role] determina o endpoint e quais campos extras são enviados.
class CadastroUsuarioDto {
  const CadastroUsuarioDto({
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.dataNascimento,
    required this.endereco,
    required this.cidade,
    required this.estado,
    required this.login,
    required this.senha,
    required this.role,
    this.especialidade,
    this.descricao,
    this.experienciaAnos,
  });

  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String dataNascimento; // "yyyy-MM-dd"
  final String endereco; // já concatenado: "Rua X, 123, Apto 2"
  final String cidade;
  final String estado;
  final String login;
  final String senha;
  final String role; // "CLIENTE" | "PROFISSIONAL"

  // Exclusivos de Profissional
  final String? especialidade;
  final String? descricao;
  final int? experienciaAnos;

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'cpf': cpf.replaceAll(RegExp(r'\D'), ''),
        'telefone': telefone.replaceAll(RegExp(r'\D'), ''),
        'email': email,
        'dataNascimento': dataNascimento,
        'endereco': endereco,
        'cidade': cidade,
        'estado': estado,
        'login': login,
        'senha': senha,
        'role': role,
        if (especialidade != null) 'especialidade': especialidade,
        if (descricao != null) 'descricao': descricao,
        if (experienciaAnos != null) 'experienciaAnos': experienciaAnos,
      };
}
