import 'package:flutter/material.dart';

import '../../core/theme/AppColors.dart';
import '../../shared/SectionCard.dart';
import 'AttendanceDetailsModal.dart';
import 'ServiceOderModel.dart';
import 'ServiceOrderRepository.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({
    super.key,
    required this.repository,
  });

  final ServiceOrderRepository repository;

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late Future<List<ServiceOrderModel>> _ordersFuture;
  String _filter = 'todos';

  @override
  void initState() {
    super.initState();
    _ordersFuture = widget.repository.getTodayOrders();
  }

  List<ServiceOrderModel> _applyFilter(List<ServiceOrderModel> orders) {
    if (_filter == 'realizado') {
      return orders.where((o) => o.isRealized).toList();
    }
    if (_filter == 'justificado') {
      return orders.where((o) => o.isJustified).toList();
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Atendimentos do dia')),
      body: FutureBuilder<List<ServiceOrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          final allOrders = snapshot.data ?? [];
          final filtered = _applyFilter(allOrders);
          final realizedCount = allOrders.where((o) => o.isRealized).length;
          final justifiedCount = allOrders.where((o) => o.isJustified).length;

          return ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
            children: [
              // Um único card com divisor — sem risco de overflow
              SectionCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCounter(
                        label: 'REALIZADOS',
                        value: realizedCount,
                        color: AppColors.success,
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 56,
                      color: Colors.black12,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: _buildCounter(
                        label: 'JUSTIFICADOS',
                        value: justifiedCount,
                        color: AppColors.warning,
                        icon: Icons.assignment_late_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todos', 'todos'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Realizados', 'realizado'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Justificados', 'justificado'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (filtered.isEmpty)
                const SectionCard(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Nenhum atendimento encontrado.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ...filtered.map(_buildOrderCard),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppColors.primarySoft,
      checkmarkColor: AppColors.primaryDark,
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryDark : Colors.black54,
        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
      ),
    );
  }

  // Contador simples — ícone em cima, label, número
  Widget _buildCounter({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(ServiceOrderModel order) {
    final isRealized = order.isRealized;
    final badgeColor = isRealized ? AppColors.success : AppColors.warning;
    final badgeText = isRealized ? 'REALIZADO' : 'JUSTIFICADO';
    final badgeIcon = isRealized
        ? Icons.check_circle_outline
        : Icons.assignment_late_outlined;

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
                backgroundColor: badgeColor.withValues(alpha: 0.15),
                child: Icon(badgeIcon, color: badgeColor),
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
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
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
