import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme/AppColors.dart';
import '../../shared/SectionCard.dart';
import 'ServiceOderModel.dart';

/// Modal de detalhes do atendimento salvo.
class AttendanceDetailsModal extends StatelessWidget {
  const AttendanceDetailsModal({super.key, required this.order});

  final ServiceOrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.primaryDark),
                  ),
                ],
              ),
              Text(
                order.serviceName,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              if (order.isJustified)
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Justificativa',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(order.justification ?? '-'),
                    ],
                  ),
                ),
              if (order.isRealized) ...[
                _buildImageSection(
                  title: 'Foto de entrada',
                  base64Value: order.entryPhotoBase64,
                ),
                const SizedBox(height: 12),
                _buildImageSection(
                  title: 'Foto de saida',
                  base64Value: order.exitPhotoBase64,
                ),
                const SizedBox(height: 12),
                _buildImageSection(
                  title: 'Assinatura',
                  base64Value: order.signatureBase64,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection({
    required String title,
    required String? base64Value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.memory(
            _decode(base64Value),
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                height: 180,
                color: AppColors.primarySoft,
                alignment: Alignment.center,
                child:
                    const Text('Nao foi possivel renderizar a imagem salva.'),
              );
            },
          ),
        ),
      ],
    );
  }

  Uint8List _decode(String? value) {
    if (value == null || value.isEmpty) {
      return Uint8List(0);
    }
    return base64Decode(value);
  }
}
