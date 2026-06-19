import 'package:app_workmatch/core/theme/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:app_workmatch/core/services/ServicoService.dart';
import 'package:app_workmatch/core/services/ServicoTab.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'CandidatosServicoScreen.dart';
import 'ChatServicoScreen.dart';

/// MeusServicosScreen — visual equivalente ao MeusServicos.jsx (CEL v3.0)
/// Navegação:
///   status PUBLICADO     → CandidatosServicoScreen
///   status NEGOCIANDO / ANDAMENTO / FINALIZADO → ChatServicoScreen
class MeusServicosScreen extends StatefulWidget {
  const MeusServicosScreen({
    super.key,
    required this.user,
    required this.servicoService,
  });

  final UserModel user;
  final ServicoService servicoService;

  @override
  State<MeusServicosScreen> createState() => _MeusServicosScreenState();
}

class _MeusServicosScreenState extends State<MeusServicosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _servicos = [];
  bool _loading = true;

  final _tabs = tabsCliente;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _carregar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      final result =
          await widget.servicoService.listarPorCliente(widget.user.id);
      if (mounted) {
        setState(() => _servicos = List<Map<String, dynamic>>.from(result));
      }
    } catch (_) {
      // erro silencioso — lista fica vazia
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _filtrar(int index) {
    final statuses = _tabs[index].statuses;
    return _servicos.where((s) => statuses.contains(s['status'])).toList();
  }

  void _abrirServico(Map<String, dynamic> servico) {
    final status = (servico['status'] ?? '').toString().toUpperCase();
    final servicoId = servico['id']?.toString() ?? '';

    if (status == 'PUBLICADO') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CandidatosServicoScreen(
          servicoId: servicoId,
          user: widget.user,
          servicoService: widget.servicoService,
        ),
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatServicoScreen(
          servicoId: servicoId,
          user: widget.user,
          servicoService: widget.servicoService,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Meus Serviços',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Atualizar',
            onPressed: _carregar,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.yellow,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blue),
            )
          : TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (i) {
                final lista = _filtrar(i);
                if (lista.isEmpty) return _EmptyState(label: _tabs[i].label);
                return RefreshIndicator(
                  onRefresh: _carregar,
                  color: AppColors.blue,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length,
                    itemBuilder: (context, index) => _ServicoCard(
                      servico: lista[index],
                      onTap: () => _abrirServico(lista[index]),
                    ),
                  ),
                );
              }),
            ),
    );
  }
}

// ── Card de serviço ───────────────────────────────────────────────────────────

class _ServicoCard extends StatelessWidget {
  const _ServicoCard({required this.servico, required this.onTap});

  final Map<String, dynamic> servico;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = (servico['status'] ?? '').toString().toUpperCase();
    final titulo = servico['titulo'] ?? '';
    final especialidade = servico['especialidade'] ?? '';
    final cidade = servico['cidade'] ?? '';
    final estado = servico['estado'] ?? '';
    final local = [cidade, estado].where((s) => s.isNotEmpty).join(' / ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + badge de status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _StatusBadge(status: status),
              ],
            ),
            if (especialidade.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bluePale,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  especialidade,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (local.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 13, color: AppColors.textMid),
                  const SizedBox(width: 3),
                  Text(
                    local,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textMid),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Ação contextual
            Row(
              children: [
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      status == 'PUBLICADO'
                          ? Icons.people_outline
                          : Icons.chat_bubble_outline,
                      size: 14,
                      color: AppColors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status == 'PUBLICADO'
                          ? 'Ver candidatos'
                          : 'Abrir conversa',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge de status ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  static Color _cor(String s) {
    switch (s) {
      case 'PUBLICADO':
        return AppColors.blue;
      case 'NEGOCIANDO':
        return AppColors.warning;
      case 'CONTRATADO':
      case 'ANDAMENTO':
        return const Color(0xFF0EA5A0);
      case 'FINALIZADO':
        return AppColors.success;
      default:
        return AppColors.inactive;
    }
  }

  static String _label(String s) {
    switch (s) {
      case 'PUBLICADO':
        return 'Publicado';
      case 'NEGOCIANDO':
        return 'Negociando';
      case 'CONTRATADO':
        return 'Contratado';
      case 'ANDAMENTO':
        return 'Em andamento';
      case 'FINALIZADO':
        return 'Finalizado';
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = _cor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(status),
        style: TextStyle(
          fontSize: 11,
          color: cor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text(
            'Nenhum serviço em "$label"',
            style: const TextStyle(color: AppColors.textMid, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
