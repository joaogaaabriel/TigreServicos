import 'package:flutter/material.dart';

import '../../core/theme/AppColors.dart';
import '../../shared/SectionCard.dart';
import '../auth/UserModel.dart';
import '../service_order/AttendanceHistoryScreen.dart';
import '../service_order/CustomerModel.dart';
import '../service_order/JustifyVisitScreen.dart';
import '../service_order/PerformServiceScreen.dart';
import '../service_order/ServiceOrderRepository.dart';

/// Dashboard principal com a lista de clientes do dia.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.currentUser,
    required this.serviceOrderRepository,
    required this.onLogout,
  });

  final UserModel currentUser;
  final ServiceOrderRepository serviceOrderRepository;
  final Future<void> Function() onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<CustomerModel> _customers;
  final Map<String, bool> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _customers = widget.serviceOrderRepository.getMockedCustomers();
    _loadAttendanceStatus();
  }

  Future<void> _loadAttendanceStatus() async {
    final newMap = <String, bool>{};
    for (final customer in _customers) {
      newMap[customer.id ?? ''] = await widget.serviceOrderRepository
          .hasAttendanceToday(customer.id ?? '');
    }

    if (mounted) {
      setState(() {
        _attendanceMap
          ..clear()
          ..addAll(newMap);
      });
    }
  }

  Future<void> _openPerformService(CustomerModel customer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PerformServiceScreen(
          customer: customer,
          repository: widget.serviceOrderRepository,
        ),
      ),
    );

    await _loadAttendanceStatus();
  }

  Future<void> _openJustifyVisit(CustomerModel customer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JustifyVisitScreen(
          customer: customer,
          repository: widget.serviceOrderRepository,
        ),
      ),
    );

    await _loadAttendanceStatus();
  }

  Future<void> _openAttendanceHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttendanceHistoryScreen(
          repository: widget.serviceOrderRepository,
        ),
      ),
    );

    await _loadAttendanceStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: const Text('Ordens de Servico'),
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Text('\u{1F42F}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            'Ola, ${widget.currentUser.name}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onLogout,
                      color: Colors.white,
                      icon: const Icon(Icons.logout_rounded),
                      tooltip: 'Sair',
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  InkWell(
                    onTap: _openAttendanceHistory,
                    borderRadius: BorderRadius.circular(20),
                    child: const SectionCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primarySoft,
                            child: Icon(
                              Icons.history,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Consultar atendimentos',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Icon(Icons.assignment_outlined),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Clientes do dia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${_customers.length} agendados',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._customers.map(_buildCustomerCard),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    final hasAttendance = _attendanceMap[customer.id ?? ''] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                customer.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    customer.serviceName,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  if (hasAttendance)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F8EC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'OK',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'realizar') {
                  _openPerformService(customer);
                } else {
                  _openJustifyVisit(customer);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'realizar',
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                    title: Text('Realizar atendimento'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'justificar',
                  child: ListTile(
                    leading: Icon(
                      Icons.assignment_late_outlined,
                      color: AppColors.warning,
                    ),
                    title: Text('Justificar visita'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
