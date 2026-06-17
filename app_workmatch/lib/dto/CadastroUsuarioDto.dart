class CadastroUsuarioDto {
  final String nome;
  final String cpf;
  final String email;

  CadastroUsuarioDto({
    required this.nome,
    required this.cpf,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'cpf': cpf,
        'email': email,
      };
}
