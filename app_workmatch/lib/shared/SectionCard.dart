import 'package:flutter/material.dart';

/// Card com espacamento padrao.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // remove a margem padrão de 4px do Card
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
