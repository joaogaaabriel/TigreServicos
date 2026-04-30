import 'package:flutter/material.dart';

/// Mixin pequeno para evitar repetir SnackBar em toda tela.
mixin UiFeedbackMixin<T extends StatefulWidget> on State<T> {
  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
