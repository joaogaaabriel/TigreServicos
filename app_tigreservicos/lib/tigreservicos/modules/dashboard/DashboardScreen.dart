import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/AppColors.dart';
import '../../shared/SectionCard.dart';
import '../auth/UserModel.dart';
import '../service_order/AttendanceHistoryScreen.dart';
import '../service_order/CustomerModel.dart';
import '../service_order/JustifyVisitScreen.dart';
import '../service_order/PerformServiceScreen.dart';
import '../service_order/ServiceOrderRepository.dart';

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

  int get _attendedCount => _attendanceMap.values.where((v) => v).length;

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

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do sistema'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.onLogout();
  }

  Future<void> _openPerformService(CustomerModel customer) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: PerformServiceScreen(
            customer: customer,
            repository: widget.serviceOrderRepository,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
    await _loadAttendanceStatus();
  }

  Future<void> _openJustifyVisit(CustomerModel customer) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: JustifyVisitScreen(
            customer: customer,
            repository: widget.serviceOrderRepository,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
    await _loadAttendanceStatus();
  }

  Future<void> _openAttendanceHistory() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: AttendanceHistoryScreen(
            repository: widget.serviceOrderRepository,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
    await _loadAttendanceStatus();
  }

  @override
  Widget build(BuildContext context) {
    // Empurra o conteúdo acima da barra de navegação do celular
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                title: const Text(
                  'Ordens de Servico',
                  style: TextStyle(fontSize: 16),
                ),
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
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.currentUser.name.isNotEmpty
                              ? widget.currentUser.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              'Ola, ${widget.currentUser.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_attendedCount de ${_customers.length} atendidos hoje',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _confirmLogout,
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
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
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
                  if (_customers.isEmpty)
                    const SectionCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhum cliente agendado para hoje.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ..._customers.map(_buildCustomerCard),
                ]),
              ),
            ),
          ],
        ),
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
                color: hasAttendance ? AppColors.success : AppColors.primary,
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
                  const SizedBox(height: 4),
                  Text(
                    customer.serviceName,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  if (hasAttendance)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Atendido',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Menu desabilitado visualmente se já atendido
            Opacity(
              opacity: hasAttendance ? 0.35 : 1.0,
              child: PopupMenuButton<String>(
                enabled: !hasAttendance,
                tooltip: hasAttendance ? 'Ja atendido hoje' : 'Opcoes',
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
            ),
          ],
        ),
      ),
    );
  }
}
