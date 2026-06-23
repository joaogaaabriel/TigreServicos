import 'package:app_workmatch/core/services/ServicoService.dart';
import 'package:app_workmatch/core/theme/AppColors.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:flutter/material.dart';
import 'CandidatosServicoScreen.dart';
import 'ChatServicoScreen.dart';

// ── Tabs — equivalente ao TABS_CLIENTE / TABS_PROFISSIONAL do React ───────────

class _Tab {
  final String label;
  final List<String> statuses;
  const _Tab(this.label, this.statuses);
}

const _tabsCliente = [
  _Tab('Ativos', ['PUBLICADO', 'NEGOCIANDO', 'CONTRATADO', 'ANDAMENTO']),
  _Tab('Finalizados', ['FINALIZADO']),
  _Tab('Arquivados', ['ARQUIVADO']),
];

const _tabsProfissional = [
  _Tab('Ativos', ['NEGOCIANDO', 'CONTRATADO', 'ANDAMENTO']),
  _Tab('Finalizados', ['FINALIZADO']),
];

// ── MeusServicosScreen ────────────────────────────────────────────────────────

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

  List<_Tab> get _tabs =>
      widget.user.isProfissional ? _tabsProfissional : _tabsCliente;

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

  // ── Chamada diferenciada por role — igual ao React ────────────────────────

  Future<void> _carregar() async {
    setState(() => _loading = true);
    bool ehProfissional = true;
    try {
      final List<dynamic> result;
      if (widget.user.isProfissional) {
        result = await widget.servicoService.listarServicos(widget.user.id,
            userId: widget.user.id, ehProfissional: ehProfissional);
      } else {
        ehProfissional = false;
        result = await widget.servicoService.listarServicos(widget.user.id,
            userId: widget.user.id, ehProfissional: ehProfissional);
      }
      if (mounted) {
        setState(() => _servicos = List<Map<String, dynamic>>.from(result));
      }
    } catch (_) {
      // erro silencioso
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _filtrar(int index) {
    final statuses = _tabs[index].statuses;
    return _servicos
        .where((s) => statuses.contains(s['status']?.toString()))
        .toList();
  }

  int _contar(int index) => _filtrar(index).length;

  void _abrirServico(Map<String, dynamic> servico) {
    final status = (servico['status'] ?? '').toString().toUpperCase();
    final servicoId = servico['id']?.toString() ?? '';

    if (!widget.user.isProfissional && status == 'PUBLICADO') {
      // Cliente com serviço publicado → ver candidatos
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CandidatosServicoScreen(
          servicoId: servicoId,
          user: widget.user,
          servicoService: widget.servicoService,
        ),
      ));
    } else if (['NEGOCIANDO', 'CONTRATADO', 'ANDAMENTO'].contains(status)) {
      // Qualquer perfil com serviço em andamento → chat
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatServicoScreen(
            servicoId: servicoId,
            user: widget.user,
            servicoService: widget.servicoService,
            profissionalId: widget.user.id),
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
        title: const Text('Meus Serviços',
            style: TextStyle(fontWeight: FontWeight.w700)),
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
          tabs: List.generate(_tabs.length, (i) {
            final count = _loading ? 0 : _contar(i);
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_tabs[i].label),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blue))
          : TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (i) {
                final lista = _filtrar(i);
                if (lista.isEmpty) {
                  return _EmptyState(label: _tabs[i].label);
                }
                return RefreshIndicator(
                  onRefresh: _carregar,
                  color: AppColors.blue,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length,
                    itemBuilder: (context, index) => _ServicoCard(
                      servico: lista[index],
                      isProfissional: widget.user.isProfissional,
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
  const _ServicoCard({
    required this.servico,
    required this.isProfissional,
    required this.onTap,
  });

  final Map<String, dynamic> servico;
  final bool isProfissional;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = (servico['status'] ?? '').toString().toUpperCase();
    final titulo = servico['titulo']?.toString() ?? '';
    final especialidade = servico['especialidade']?.toString() ?? '';
    final cidade = servico['cidade']?.toString() ?? '';
    final estado = servico['estado']?.toString() ?? '';
    final local = [cidade, estado].where((s) => s.isNotEmpty).join(' / ');

    // Profissional: mostra nome do cliente. Cliente: mostra nome do profissional
    final outraParte = isProfissional
        ? servico['clienteNome']?.toString()
        : servico['profissionalNome']?.toString();

    // Define se o card é clicável
    final clicavel = !isProfissional && status == 'PUBLICADO' ||
        ['NEGOCIANDO', 'CONTRATADO', 'ANDAMENTO'].contains(status);

    return GestureDetector(
      onTap: clicavel ? onTap : null,
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
            // Título + badge
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

            // Especialidade
            if (especialidade.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.work_outline,
                      size: 13, color: AppColors.blue),
                  const SizedBox(width: 4),
                  Text(
                    especialidade,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            // Local
            if (local.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 13, color: AppColors.textMid),
                  const SizedBox(width: 4),
                  Text(local,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMid)),
                ],
              ),
            ],

            // Nome da outra parte (profissional ou cliente)
            if (outraParte != null && outraParte.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 13, color: AppColors.textMid),
                  const SizedBox(width: 4),
                  Text(outraParte,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMid)),
                ],
              ),
            ],

            // Ação contextual
            if (clicavel) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    !isProfissional && status == 'PUBLICADO'
                        ? Icons.people_outline
                        : Icons.chat_bubble_outline,
                    size: 14,
                    color: AppColors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    !isProfissional && status == 'PUBLICADO'
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
      case 'ARQUIVADO':
        return AppColors.inactive;
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
      case 'ARQUIVADO':
        return 'Arquivado';
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
        style: TextStyle(fontSize: 11, color: cor, fontWeight: FontWeight.w700),
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
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.navy),
          ),
          const SizedBox(height: 6),
          const Text(
            'Quando houver serviços com esse status,\neles vão aparecer aqui.',
            style: TextStyle(fontSize: 13, color: AppColors.textMid),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
