import 'package:app_workmatch/core/theme/AppTheme.dart';
import 'package:flutter/material.dart';

import 'AppController.dart';
import 'AppDependencies.dart';
import 'AppView.dart';

class WorkServicosApp extends StatefulWidget {
  const WorkServicosApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<WorkServicosApp> createState() => _WorkServicosAppState();
}

class _WorkServicosAppState extends State<WorkServicosApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController(
      authRepository: widget.dependencies.authRepository,
    )..bootstrap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Work Match',
          theme: AppTheme.lightTheme,
          home: AppView(
            controller: _controller,
            dependencies: widget.dependencies,
          ),
        );
      },
    );
  }
}
