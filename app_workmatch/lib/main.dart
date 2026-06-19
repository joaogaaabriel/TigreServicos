import 'package:app_workmatch/AppDependencies.dart';
import 'package:app_workmatch/WorkServicosApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis de ambiente antes de qualquer outra coisa
  await dotenv.load(fileName: '.env');

  final dependencies = await AppDependencies.create();

  runApp(WorkServicosApp(dependencies: dependencies));
}
