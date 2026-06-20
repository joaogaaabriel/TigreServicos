import 'package:flutter/services.dart';

/// Formata data automaticamente enquanto o usuário digita: DD/MM/AAAA
/// Equivalente ao fmtData() do React/AuthController.
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;

    String formatted;
    if (limited.length <= 2) {
      formatted = limited;
    } else if (limited.length <= 4) {
      formatted = '${limited.substring(0, 2)}/${limited.substring(2)}';
    } else {
      formatted =
          '${limited.substring(0, 2)}/${limited.substring(2, 4)}/${limited.substring(4)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
