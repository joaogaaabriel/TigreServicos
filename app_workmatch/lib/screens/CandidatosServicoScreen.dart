import 'package:app_workmatch/core/theme/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:app_workmatch/core/services/ServicoService.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'ChatServicoScreen.dart';

/// CandidatosServicoScreen — equivalente Flutter de CandidatosServico.jsx
/// Lógica preservada:
///  - carregar() → GET /api/candidaturas/servico/{servicoId}
///  - contratar() → PATCH /api/servicos/{id}/avancar → navega para ChatServico
///  - abrirChat() → navega direto para ChatServico (sem contratar)
class CandidatosServicoScreen extends StatefulWidget {
  const CandidatosServicoScreen({
    super.key,
    required this.servicoId,
    required this.user,
    required this.servicoService,
  });

  final String servicoId;
  final UserModel user;
  final ServicoService servicoService;

  @override
  State<CandidatosServicoScreen> createState() =>
      _CandidatosServicoScreenState();
}

class _CandidatosServicoScreenState extends State<CandidatosServicoScreen> {
  List<Map<String, dynamic>> _candidatos = [];
  bool _carregando = true;
  String? _contratando; // profissionalId em processo de contratação

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final result =
          await widget.servicoService.listarCandidatos(widget.servicoId);
      if (mounted) {
        setState(() => _candidatos = List<Map<String, dynamic>>.from(result));
      }
    } catch (_) {
      if (mounted) _showToast('Erro ao carregar candidatos.', isError: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _contratar(String profissionalId) async {
    setState(() => _contratando = profissionalId);
    try {
      await widget.servicoService.avancarServico(
        servicoId: widget.servicoId,
        profissionalId: profissionalId,
      );
      if (!mounted) return;
      _showToast('Profissional selecionado! Negociação iniciada.');
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ChatServicoScreen(
          servicoId: widget.servicoId,
          user: widget.user,
          servicoService: widget.servicoService,
        ),
      ));
    } catch (e) {
      if (mounted) {
        _showToast('Erro ao selecionar profissional.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _contratando = null);
    }
  }

  void _abrirChat(String profissionalId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatServicoScreen(
        servicoId: widget.servicoId,
        user: widget.user,
        servicoService: widget.servicoService,
        profissionalId: profissionalId,
      ),
    ));
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Candidatos',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            Text('Selecione o profissional para negociar',
                style: TextStyle(fontSize: 12, color: Colors.white60)),
          ],
        ),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blue))
          : _candidatos.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  onRefresh: _carregar,
                  color: AppColors.blue,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _candidatos.length,
                    itemBuilder: (context, i) => _CandidatoCard(
                      candidato: _candidatos[i],
                      contratando: _contratando,
                      onConversar: () => _abrirChat(
                          _candidatos[i]['profissionalId'].toString()),
                      onContratar: () => _contratar(
                          _candidatos[i]['profissionalId'].toString()),
                    ),
                  ),
                ),
    );
  }
}

// ── Card de candidato ─────────────────────────────────────────────────────────

class _CandidatoCard extends StatelessWidget {
  const _CandidatoCard({
    required this.candidato,
    required this.contratando,
    required this.onConversar,
    required this.onContratar,
  });

  final Map<String, dynamic> candidato;
  final String? contratando;
  final VoidCallback onConversar;
  final VoidCallback onContratar;

  @override
  Widget build(BuildContext context) {
    final nome = candidato['nome'] ?? '';
    final especialidade = candidato['especialidade'] ?? '';
    final cidade = candidato['cidade'] ?? '';
    final estado = candidato['estado'] ?? '';
    final local = [cidade, estado].where((s) => s.isNotEmpty).join(' — ');
    final profId = candidato['profissionalId']?.toString() ?? '';
    final isContratando = contratando == profId;

    return Container(
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
          // Nome + especialidade + local
          Text(
            nome,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (especialidade.isNotEmpty)
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
              if (local.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textMid),
                    const SizedBox(width: 3),
                    Text(
                      local,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMid),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          // Ações
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: isContratando ? null : onConversar,
                icon: const Icon(Icons.chat_bubble_outline, size: 15),
                label: const Text('Conversar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.border),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isContratando ? null : onContratar,
                  icon: isContratando
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_outlined, size: 15),
                  label: Text(isContratando
                      ? 'Selecionando...'
                      : 'Selecionar profissional'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 52, color: AppColors.textLight),
          const SizedBox(height: 12),
          const Text(
            'Nenhum candidato ainda',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navy),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aguarde profissionais se candidatarem ao seu serviço.',
            style: TextStyle(fontSize: 13, color: AppColors.textMid),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
