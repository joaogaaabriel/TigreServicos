import 'package:flutter/material.dart';

class ListaServicosScreen extends StatelessWidget {
  final String titulo;
  final List servicos;

  const ListaServicosScreen({
    super.key,
    required this.titulo,
    required this.servicos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: ListView.builder(
        itemCount: servicos.length,
        itemBuilder: (context, index) {
          final s = servicos[index];

          return ListTile(
            title: Text(s['titulo'] ?? ''),
            subtitle: Text(s['status'] ?? ''),
          );
        },
      ),
    );
  }
}
