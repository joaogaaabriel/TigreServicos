import 'package:app_workmatch/core/services/ServicoService.dart';
import 'package:app_workmatch/core/theme/AppColors.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:flutter/material.dart';

// ── Constantes ────────────────────────────────────────────────────────────────

const _especialidades = [
  'Todas',
  'Eletricista',
  'Encanador',
  'Pintor',
  'Pedreiro',
  'Marceneiro',
  'Jardineiro',
  'Diarista',
  'Técnico de TI',
  'Outro',
];

const _statusLabel = {
  'PUBLICADO': 'Publicado',
  'NEGOCIANDO': 'Negociando',
  'CONTRATADO': 'Contratado',
  'ANDAMENTO': 'Em andamento',
  'FINALIZADO': 'Finalizado',
};

Color _statusColor(String? status) {
  switch (status) {
    case 'PUBLICADO':
      return AppColors.blue;
    case 'NEGOCIANDO':
      return AppColors.warning;
    case 'CONTRATADO':
    case 'ANDAMENTO':
      return AppColors.success;
    case 'FINALIZADO':
      return Colors.grey;
    default:
      return Colors.black54;
  }
}

const _pageSize = 20;

// ── Widget principal ─────────────────────────────────────────────────────────

class HomeProfissionalScreen extends StatefulWidget {
  const HomeProfissionalScreen({
    super.key,
    required this.user,
    required this.servicoService,
    required this.onLogout,
  });

  final UserModel user;
  final ServicoService servicoService;
  final Future<void> Function() onLogout;

  @override
  State<HomeProfissionalScreen> createState() => _HomeProfissionalScreenState();
}

class _HomeProfissionalScreenState extends State<HomeProfissionalScreen> {
  List<Map<String, dynamic>> _servicos = [];
  Set<String> _candidatados = {};
  bool _carregando = true;
  String? _enviando; // id do serviço sendo candidatado
  String _filtroEsp = 'Todas';
  String _filtroCidade = '';
  int _pagina = 0;
  bool _ultima = true;

  final _cidadeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarServicos(resetar: true);
  }

  @override
  void dispose() {
    _cidadeController.dispose();
    super.dispose();
  }

  // ── Dados ────────────────────────────────────────────────────────────────

  Future<void> _carregarServicos({bool resetar = false, int? pagina}) async {
    final pg = pagina ?? (resetar ? 0 : _pagina);
    setState(() => _carregando = true);

    try {
      final lista = await widget.servicoService.listarPublicados(
        especialidade: _filtroEsp == 'Todas' ? null : _filtroEsp,
        cidade: _filtroCidade.trim().isEmpty ? null : _filtroCidade.trim(),
        page: pg,
        size: _pageSize,
      );

      // Candidaturas do profissional — ignoramos erro se endpoint não existir ainda
      Set<String> cands = {};
      try {
        final resCands = await widget.servicoService
            .listarCandidaturasProfissional(widget.user.id);
        cands = resCands.map((c) => c['servicoId'].toString()).toSet();
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _servicos = resetar
            ? List<Map<String, dynamic>>.from(
                lista.map((e) => e as Map<String, dynamic>))
            : [..._servicos, ...lista.map((e) => e as Map<String, dynamic>)];
        _candidatados = cands;
        _pagina = pg;
        _ultima = lista.length < _pageSize;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar serviços: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _candidatar(Map<String, dynamic> servico) async {
    final id = servico['id'].toString();
    if (_enviando != null || _candidatados.contains(id)) return;

    setState(() => _enviando = id);
    try {
      await widget.servicoService.candidatar(
        servicoId: id,
        profissionalId: widget.user.id,
      );
      if (!mounted) return;
      setState(() => _candidatados = {..._candidatados, id});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidatura enviada!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _enviando = null);
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _filtroCidade = _cidadeController.text;
      _pagina = 0;
    });
    _carregarServicos(resetar: true);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            children: [
              TextSpan(text: 'Work'),
              TextSpan(
                  text: 'Match', style: TextStyle(color: AppColors.yellow)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await widget.onLogout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _FiltrosSection(
            especialidades: _especialidades,
            filtroAtual: _filtroEsp,
            cidadeController: _cidadeController,
            onEspSelecionada: (esp) {
              setState(() => _filtroEsp = esp);
              _carregarServicos(resetar: true);
            },
            onCidadeConfirmada: _aplicarFiltros,
          ),
          Expanded(
            child: _carregando && _pagina == 0
                ? const Center(child: CircularProgressIndicator())
                : _servicos.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum serviço encontrado com esses filtros.',
                          style: TextStyle(color: AppColors.textMid),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _servicos.length + (_ultima ? 0 : 1),
                        itemBuilder: (context, i) {
                          if (i == _servicos.length) {
                            return _BotaoCarregarMais(
                              carregando: _carregando,
                              onTap: () =>
                                  _carregarServicos(pagina: _pagina + 1),
                            );
                          }
                          final s = _servicos[i];
                          final id = s['id'].toString();
                          return _ServicoCard(
                            servico: s,
                            jaCandidatou: _candidatados.contains(id),
                            emEnvio: _enviando == id,
                            userId: widget.user.id,
                            onCandidatar: () => _candidatar(s),
                            onChat: (servicoId) {
                              // TODO: navegar para chat
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Filtros ───────────────────────────────────────────────────────────────────

class _FiltrosSection extends StatelessWidget {
  const _FiltrosSection({
    required this.especialidades,
    required this.filtroAtual,
    required this.cidadeController,
    required this.onEspSelecionada,
    required this.onCidadeConfirmada,
  });

  final List<String> especialidades;
  final String filtroAtual;
  final TextEditingController cidadeController;
  final void Function(String) onEspSelecionada;
  final VoidCallback onCidadeConfirmada;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 16, color: AppColors.navy),
              const SizedBox(width: 6),
              const Text(
                'Filtros',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                    fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Chips de especialidade
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: especialidades.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final esp = especialidades[i];
                final ativo = filtroAtual == esp;
                return GestureDetector(
                  onTap: () => onEspSelecionada(esp),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: ativo ? AppColors.navy : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: ativo ? AppColors.navy : AppColors.border),
                    ),
                    child: Text(
                      esp,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ativo ? Colors.white : AppColors.textMid,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Campo cidade
          TextField(
            controller: cidadeController,
            onSubmitted: (_) => onCidadeConfirmada(),
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Filtrar por cidade...',
              hintStyle: const TextStyle(fontSize: 13),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, size: 18),
                onPressed: onCidadeConfirmada,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card de serviço ───────────────────────────────────────────────────────────

class _ServicoCard extends StatelessWidget {
  const _ServicoCard({
    required this.servico,
    required this.jaCandidatou,
    required this.emEnvio,
    required this.userId,
    required this.onCandidatar,
    required this.onChat,
  });

  final Map<String, dynamic> servico;
  final bool jaCandidatou;
  final bool emEnvio;
  final String userId;
  final VoidCallback onCandidatar;
  final void Function(String servicoId) onChat;

  @override
  Widget build(BuildContext context) {
    final status = servico['status']?.toString() ?? '';
    final id = servico['id']?.toString() ?? '';
    final podeCandidatar = status == 'PUBLICADO' && !jaCandidatou;
    final podeChat =
        ['NEGOCIANDO', 'CONTRATADO', 'ANDAMENTO'].contains(status) &&
            servico['profissionalId']?.toString() == userId;
    final cor = _statusColor(status);
    final descricao = servico['descricao']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + badge status
            Row(
              children: [
                Expanded(
                  child: Text(
                    servico['titulo']?.toString() ?? '',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel[status] ?? status,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: cor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Meta: especialidade + cidade
            Wrap(
              spacing: 12,
              children: [
                if (servico['especialidade'] != null)
                  _MetaChip(
                      icon: Icons.work_outline,
                      text: servico['especialidade'].toString()),
                if (servico['cidade'] != null)
                  _MetaChip(
                      icon: Icons.location_on_outlined,
                      text: [
                        servico['cidade'],
                        if (servico['estado'] != null) servico['estado'],
                      ].join(' — ')),
              ],
            ),
            // Descrição truncada
            if (descricao.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                descricao.length > 140
                    ? '${descricao.substring(0, 140)}...'
                    : descricao,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textMid, height: 1.5),
              ),
            ],
            const SizedBox(height: 12),
            // Ações
            Row(
              children: [
                if (podeCandidatar)
                  FilledButton(
                    onPressed: emEnvio ? null : onCandidatar,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8)),
                    child: emEnvio
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Candidatar-se',
                            style: TextStyle(fontSize: 13)),
                  ),
                if (jaCandidatou && status == 'PUBLICADO')
                  Row(
                    children: const [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: AppColors.success),
                      SizedBox(width: 4),
                      Text('Candidatura enviada',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textMid)),
                    ],
                  ),
                if (podeChat) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => onChat(id),
                    icon: const Icon(Icons.chat_bubble_outline, size: 14),
                    label: const Text('Chat', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMid),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
      ],
    );
  }
}

class _BotaoCarregarMais extends StatelessWidget {
  const _BotaoCarregarMais({required this.carregando, required this.onTap});
  final bool carregando;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: OutlinedButton(
          onPressed: carregando ? null : onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.navy,
            side: const BorderSide(color: AppColors.navy),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: carregando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Carregar mais'),
        ),
      ),
    );
  }
}
