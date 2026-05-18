import 'package:flutter/material.dart';

import '../../core/mixins/UiFeedbackMixin.dart';
import '../../core/mixins/ValidatorMixin.dart';
import '../../core/theme/AppColors.dart';
import '../../shared/CustomButton.dart';
import '../../shared/CustomTextField.dart';
import 'CustomerModel.dart';
import 'ServiceOrderController.dart';
import 'ServiceOrderRepository.dart';

/// Tela para justificar visita nao realizada.
class JustifyVisitScreen extends StatefulWidget {
  const JustifyVisitScreen({
    super.key,
    required this.customer,
    required this.repository,
  });

  final CustomerModel customer;
  final ServiceOrderRepository repository;

  @override
  State<JustifyVisitScreen> createState() => _JustifyVisitScreenState();
}

class _JustifyVisitScreenState extends State<JustifyVisitScreen>
    with UiFeedbackMixin, ValidatorMixin {
  final _formKey = GlobalKey<FormState>();
  final _justificationController = TextEditingController();
  late final ServiceOrderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServiceOrderController(repository: widget.repository);
    _justificationController.addListener(_refreshCounter);
  }

  @override
  void dispose() {
    _justificationController.removeListener(_refreshCounter);
    _controller.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await _controller.saveJustified(
        customer: widget.customer,
        justification: _justificationController.text,
      );
    } catch (error) {
      showMessage(error.toString().replaceFirst('Exception: ', ''));
      return;
    }

    if (!mounted) {
      return;
    }

    showMessage('Justificativa salva com sucesso.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Justificar visita')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Descreva o motivo pelo qual o atendimento nao pode ser realizado. Essa informacao sera registrada no historico.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: CustomTextField(
                      controller: _justificationController,
                      label: 'Descricao da justificativa *',
                      maxLines: 8,
                      validator: (value) =>
                          requiredField(value, 'a justificativa'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_justificationController.text.length} caracteres',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  const Spacer(),
                  CustomButton(
                    label: _controller.isSaving
                        ? 'Salvando...'
                        : 'Finalizar atendimento',
                    icon: Icons.check_circle_outline,
                    onPressed: _controller.isSaving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _refreshCounter() {
    if (mounted) {
      setState(() {});
    }
  }
}
