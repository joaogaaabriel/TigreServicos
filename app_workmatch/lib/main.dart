import 'AppDependencies.dart';
import 'WorkServicosApp.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await AppDependencies.create();

  runApp(WorkServicosApp(dependencies: dependencies));
}
