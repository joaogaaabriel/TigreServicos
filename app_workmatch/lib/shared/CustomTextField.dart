import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.autofocus = false,
    this.inputFormatters = const [],
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final bool autofocus;

  final List<TextInputFormatter> inputFormatters;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // _obscure controla APENAS campos de senha — nunca afeta outros campos
  bool _hideText = true;

  @override
  Widget build(BuildContext context) {
    // Campos que NÃO são senha nunca ficam obscuros
    final effectiveObscure = widget.obscureText && _hideText;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: effectiveObscure,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      autofocus: widget.autofocus,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        alignLabelWithHint: widget.maxLines > 1,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _hideText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _hideText = !_hideText),
              )
            : null,
      ),
    );
  }
}
