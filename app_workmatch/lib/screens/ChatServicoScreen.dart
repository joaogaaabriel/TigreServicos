import 'dart:async';
import 'package:app_workmatch/core/theme/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:app_workmatch/core/services/ServicoService.dart';
import 'package:app_workmatch/model/UserModel.dart';

class ChatServicoScreen extends StatefulWidget {
  const ChatServicoScreen({
    super.key,
    required this.servicoId,
    required this.user,
    required this.servicoService,
    this.profissionalId, // opcional — passado por CandidatosServico
  });

  final String servicoId;
  final UserModel user;
  final ServicoService servicoService;
  final String? profissionalId;

  @override
  State<ChatServicoScreen> createState() => _ChatServicoScreenState();
}

class _ChatServicoScreenState extends State<ChatServicoScreen> {
  Map<String, dynamic>? _servico;
  List<Map<String, dynamic>> _mensagens = [];
  bool _loading = true;
  bool _enviando = false;

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _poolTimer; // equivalente ao poolRef do React

  @override
  void initState() {
    super.initState();
    _carregarDados();
    // Polling a cada 4 segundos — igual ao setInterval(carregarMensagens, 4000)
    _poolTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _carregarMensagens(),
    );
  }

  @override
  void dispose() {
    _poolTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /* ── Lógica preservada ───────────────────────────────────────────── */

  Future<void> _carregarDados() async {
    try {
      final results = await Future.wait([
        widget.servicoService.buscarServico(widget.servicoId),
        widget.servicoService.listarMensagens(widget.servicoId),
      ]);
      if (mounted) {
        setState(() {
          _servico = results[0] as Map<String, dynamic>?;
          _mensagens =
              List<Map<String, dynamic>>.from(results[1] as List? ?? []);
        });
        _scrollToBottom();
      }
    } catch (_) {
      // erro silencioso
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _carregarMensagens() async {
    try {
      final data =
          await widget.servicoService.listarMensagens(widget.servicoId);
      if (mounted) {
        setState(() =>
            _mensagens = List<Map<String, dynamic>>.from(data as List? ?? []));
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _handleEnviar() async {
    final texto = _inputController.text.trim();
    if (texto.isEmpty || _enviando) return;

    _inputController.clear();
    setState(() => _enviando = true);

    try {
      await widget.servicoService.enviarMensagem(
        servicoId: widget.servicoId,
        remetenteId: widget.user.id,
        remetenteRole: widget.user.role,
        conteudo: texto,
      );
      await _carregarMensagens();
    } catch (_) {
      // erro silencioso — mantém o campo limpo para reenvio
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  bool _isMinha(Map<String, dynamic> msg) {
    return msg['remetenteId']?.toString() == widget.user.id;
  }

  static const _meses = [
    '',
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  String _fmtData(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')} de ${_meses[local.month]}';
  }

  /// Equivalente a agruparPorData() do React.
  /// Retorna uma lista mista de separadores de data e mensagens.
  List<_ChatItem> _agruparPorData() {
    final items = <_ChatItem>[];
    String? dataAtual;

    for (final msg in _mensagens) {
      final raw = msg['enviadoEm'];
      final dt = raw != null ? DateTime.tryParse(raw.toString()) : null;
      final label = dt != null ? _fmtData(dt) : '';

      if (label != dataAtual) {
        if (label.isNotEmpty) items.add(_ChatItem.separador(label));
        dataAtual = label;
      }
      items.add(_ChatItem.mensagem(msg));
    }
    return items;
  }

  /* ── UI ──────────────────────────────────────────────────────────── */

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Conversa',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.blue)),
      );
    }

    final itens = _agruparPorData();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chat",
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            if (_servico?['titulo'] != null)
              Text(
                _servico!['titulo'],
                style: const TextStyle(fontSize: 11, color: Colors.white60),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Card de info do serviço ──────────────────────────────
          if (_servico != null) _InfoCard(servico: _servico!),

          // ── Área de mensagens ────────────────────────────────────
          Expanded(
            child: _mensagens.isEmpty
                ? _EmptyChat()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: itens.length,
                    itemBuilder: (context, i) {
                      final item = itens[i];
                      if (item.isSeparador) {
                        return _DateSeparator(label: item.label!);
                      }
                      final msg = item.msg!;
                      return _MessageBubble(
                        msg: msg,
                        minha: _isMinha(msg),
                      );
                    },
                  ),
          ),

          // ── Input ────────────────────────────────────────────────
          _InputBar(
            controller: _inputController,
            enviando: _enviando,
            onEnviar: _handleEnviar,
          ),
        ],
      ),
    );
  }
}

/* =============================================================
   Modelo interno de item de chat
============================================================= */

class _ChatItem {
  final bool isSeparador;
  final String? label;
  final Map<String, dynamic>? msg;

  const _ChatItem._({required this.isSeparador, this.label, this.msg});

  factory _ChatItem.separador(String label) =>
      _ChatItem._(isSeparador: true, label: label);

  factory _ChatItem.mensagem(Map<String, dynamic> msg) =>
      _ChatItem._(isSeparador: false, msg: msg);
}

/* =============================================================
   Card de info do serviço (topo)
============================================================= */

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.servico});
  final Map<String, dynamic> servico;

  @override
  Widget build(BuildContext context) {
    final status = servico['status']?.toString() ?? '';
    final cidade = servico['cidade']?.toString() ?? '';
    final estado = servico['estado']?.toString() ?? '';
    final local = [cidade, estado].where((s) => s.isNotEmpty).join('/');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bluePale,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (servico['titulo'] != null)
            _InfoChip(label: 'Serviço', value: servico['titulo']),
          if (servico['especialidade'] != null)
            _InfoChip(label: 'Especialidade', value: servico['especialidade']),
          if (local.isNotEmpty) _InfoChip(label: 'Local', value: local),
          if (status.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});
  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: AppColors.text),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value?.toString() ?? ''),
        ],
      ),
    );
  }
}

/* =============================================================
   Bolha de mensagem
============================================================= */

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.msg, required this.minha});
  final Map<String, dynamic> msg;
  final bool minha;

  String _fmtHora(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            minha ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Nome do remetente (só para mensagens do outro)
          if (!minha && msg['remetenteNome'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 3),
              child: Text(
                msg['remetenteNome'].toString(),
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textLight),
              ),
            ),

          // Bubble
          Align(
            alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: minha ? AppColors.blue : AppColors.surface,
                  border: minha ? null : Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(minha ? 14 : 4),
                    bottomRight: Radius.circular(minha ? 4 : 14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  msg['conteudo']?.toString() ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: minha ? Colors.white : AppColors.text,
                  ),
                ),
              ),
            ),
          ),

          // Hora
          Padding(
            padding: EdgeInsets.only(
              top: 3,
              left: minha ? 0 : 4,
              right: minha ? 4 : 0,
            ),
            child: Text(
              _fmtHora(msg['enviadoEm']?.toString()),
              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }
}

/* =============================================================
   Separador de data
============================================================= */

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ),
      ),
    );
  }
}

/* =============================================================
   Empty state (sem mensagens)
============================================================= */

class _EmptyChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.textLight),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma mensagem ainda.',
            style: TextStyle(fontSize: 14, color: AppColors.textMid),
          ),
        ],
      ),
    );
  }
}

/* =============================================================
   Barra de input
============================================================= */

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enviando,
    required this.onEnviar,
  });

  final TextEditingController controller;
  final bool enviando;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !enviando,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onEnviar(),
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                hintStyle:
                    const TextStyle(color: AppColors.textLight, fontSize: 14),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.blue, width: 1.4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 46,
            height: 46,
            child: ElevatedButton(
              onPressed: (controller.text.trim().isEmpty || enviando)
                  ? null
                  : onEnviar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: enviando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_outlined, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
