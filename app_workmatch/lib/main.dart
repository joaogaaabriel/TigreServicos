import 'package:flutter/material.dart';

import 'tigreservicos/appWorkServico.dart';
import 'tigreservicos/AppDependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await AppDependencies.create();

  runApp(TigreServicosApp(dependencies: dependencies));
}
