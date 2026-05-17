import 'package:flutter/material.dart';

import 'tigreservicos/appTigreServico.dart';
import 'tigreservicos/AppDependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A ideia aqui e simples: sobe tudo que o app precisa antes de desenhar a UI.
  final dependencies = await AppDependencies.create();

  runApp(TigreServicosApp(dependencies: dependencies));
}
