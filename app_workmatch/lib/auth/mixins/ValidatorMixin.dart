/// Validacoes basicas e reaproveitaveis.
mixin ValidatorMixin {
  String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Preencha $fieldName.';
    }
    return null;
  }

  String? email(String? value) {
    final cleanValue = value?.trim() ?? '';
    if (cleanValue.isEmpty || !cleanValue.contains('@')) {
      return 'Digite um e-mail valido.';
    }
    return null;
  }
}
