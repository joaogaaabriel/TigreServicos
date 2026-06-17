import 'package:flutter/material.dart';

import 'AppController.dart';
import 'AppDependencies.dart';
import 'AppView.dart';
import 'core/theme/AppTheme.dart';

class TigreServicosApp extends StatefulWidget {
  const TigreServicosApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<TigreServicosApp> createState() => _TigreServicosAppState();
}

class _TigreServicosAppState extends State<TigreServicosApp> {
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
