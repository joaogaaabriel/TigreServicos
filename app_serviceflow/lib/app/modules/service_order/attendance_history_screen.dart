import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/section_card.dart';
import 'attendance_details_modal.dart';
import 'service_order_model.dart';
import 'service_order_repository.dart';

/// Lista os atendimentos do dia e abre o modal de detalhe.
class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({
    super.key,
    required this.repository,
  });

  final ServiceOrderRepository repository;

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late Future<List<ServiceOrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = widget.repository.getTodayOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atendimentos do dia')),
      body: FutureBuilder<List<ServiceOrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];
          final realizedCount = orders.where((item) => item.isRealized).length;
          final justifiedCount = orders.where((item) => item.isJustified).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildCounterCard(
                      label: 'REALIZADOS',
                      value: realizedCount,
                      color: AppColors.success,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCounterCard(
                      label: 'JUSTIFICADOS',
                      value: justifiedCount,
                      color: AppColors.warning,
                      icon: Icons.assignment_late_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (orders.isEmpty)
                const SectionCard(
                  child: Text('Nenhum atendimento salvo hoje ainda.'),
                ),
              ...orders.map(_buildOrderCard),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCounterCard({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(ServiceOrderModel order) {
    final badgeColor = order.isRealized ? AppColors.success : AppColors.warning;
    final badgeText = order.isRealized ? 'REALIZADO' : 'JUSTIFICADO';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AttendanceDetailsModal(order: order),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: SectionCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                child: Icon(
                  order.isRealized
                      ? Icons.check_circle_outline
                      : Icons.assignment_late_outlined,
                  color: badgeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.content_paste_search_outlined),
            ],
          ),
        ),
      ),
    );
  }
}
