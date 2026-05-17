import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import '../../core/mixins/UiFeedbackMixin.dart';
import '../../core/theme/AppColors.dart';
import '../../shared/CustomButton.dart';
import '../../shared/SectionCard.dart';
import 'CustomerModel.dart';
import 'ServiceOrderController.dart';
import 'ServiceOrderRepository.dart';

class PerformServiceScreen extends StatefulWidget {
  const PerformServiceScreen({
    super.key,
    required this.customer,
    required this.repository,
  });

  final CustomerModel customer;
  final ServiceOrderRepository repository;

  @override
  State<PerformServiceScreen> createState() => _PerformServiceScreenState();
}

class _PerformServiceScreenState extends State<PerformServiceScreen>
    with UiFeedbackMixin {
  late final ServiceOrderController _controller;

  @override
  void initState() {
    super.initState();
    // Sem addListener aqui — era a causa do bug da assinatura
    _controller = ServiceOrderController(repository: widget.repository);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await _controller.saveRealized(widget.customer);
      if (!mounted) return;
      showMessage('Atendimento salvo com sucesso.');
      Navigator.of(context).pop();
    } catch (error) {
      showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Realizar atendimento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SERVICO',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.customer.serviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Fotos ficam no AnimatedBuilder — rebuildam ao tirar foto
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                children: [
                  _buildPhotoPicker(
                    title: 'Foto de entrada *',
                    base64Image: _controller.entryPhotoBase64,
                    onTap: () => _pickImage(true),
                  ),
                  const SizedBox(height: 16),
                  _buildPhotoPicker(
                    title: 'Foto de saida *',
                    base64Image: _controller.exitPhotoBase64,
                    onTap: () => _pickImage(false),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
          const Text(
            'Assinatura do cliente *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Assinatura FORA do AnimatedBuilder — não rebuilda ao notifyListeners
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Signature(
                controller: _controller.signatureController,
                backgroundColor: Colors.white,
              ),
            ),
          ),

          TextButton.icon(
            onPressed: _controller.clearSignature,
            icon: const Icon(Icons.layers_clear_outlined),
            label: const Text('Limpar assinatura'),
          ),
          const SizedBox(height: 12),

          // Botão lê canFinishRealized na hora do tap — sem listener
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomButton(
                label: _controller.isSaving
                    ? 'Salvando...'
                    : 'Finalizar atendimento',
                icon: Icons.check_circle_outline,
                onPressed: _controller.isSaving ? null : _save,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker({
    required String title,
    required String? base64Image,
    required Future<void> Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: base64Image == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.camera_alt_outlined,
                            color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      Text('Tirar / escolher foto'),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      _controller.decodeBase64Image(base64Image),
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(bool isEntryPhoto) async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      if (isEntryPhoto) {
        await _controller.pickEntryPhotoFrom(source);
      } else {
        await _controller.pickExitPhotoFrom(source);
      }
    } catch (_) {
      showMessage('Nao foi possivel abrir a camera/galeria neste dispositivo.');
    }
  }
}
