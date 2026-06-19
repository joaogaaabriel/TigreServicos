import 'package:app_workmatch/core/services/IaService.dart';
import 'package:app_workmatch/core/services/ServicoService.dart';
import 'package:flutter/material.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/core/theme/AppColors.dart';

class NovoServicoScreen extends StatefulWidget {
  const NovoServicoScreen({
    super.key,
    required this.user,
    required this.servicoService, // injetado — não mais estático
  });

  final UserModel user;
  final ServicoService servicoService;

  @override
  State<NovoServicoScreen> createState() => _NovoServicoScreenState();
}

class _NovoServicoScreenState extends State<NovoServicoScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool loading = false;
  bool publicando = false;

  Map<String, dynamic> dadosColetados = {};

  final List<Map<String, String>> mensagens = [
    {
      'autor': 'ia',
      'texto':
          'Olá! Sou a assistente do WorkMatch. Vou te ajudar a publicar seu serviço em poucos passos. Me conta: qual tipo de serviço você precisa?'
    }
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensagem() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || loading) return;

    setState(() {
      mensagens.add({'autor': 'usuario', 'texto': texto});
      loading = true;
    });

    _controller.clear();

    try {
      final historico = mensagens
          .map((m) => {
                'role': m['autor'] == 'usuario' ? 'user' : 'assistant',
                'content': m['texto'] ?? '',
              })
          .toList();

      final resposta = await AiService.enviarMensagem(historico);
      final dados = AiService.extrairDados(resposta);

      if (!mounted) return;

      if (dados != null) {
        setState(() {
          dadosColetados = dados;
          mensagens.add({
            'autor': 'ia',
            'texto':
                'Coletei todas as informações. Veja o resumo abaixo e confirme para publicar.',
          });
        });
      } else {
        setState(() => mensagens.add({'autor': 'ia', 'texto': resposta}));
      }
    } catch (e) {
      if (mounted) {
        setState(() => mensagens.add({
              'autor': 'ia',
              'texto': 'Erro ao processar mensagem. Tente novamente.',
            }));
      }
    } finally {
      if (mounted) setState(() => loading = false);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 300,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _publicarServico() async {
    if (dadosColetados.isEmpty) return;

    setState(() => publicando = true);

    try {
      await widget.servicoService.publicarServico(
        dados: dadosColetados,
        clienteId: widget.user.id,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço publicado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => publicando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Novo serviço'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Resumo — aparece quando a IA coletou os dados
          if (dadosColetados.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo do serviço',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Título: ${dadosColetados['titulo'] ?? ''}'),
                  Text(
                      'Especialidade: ${dadosColetados['especialidade'] ?? ''}'),
                  Text('Descrição: ${dadosColetados['descricao'] ?? ''}'),
                  Text('Cidade: ${dadosColetados['cidade'] ?? ''}'),
                  Text('Estado: ${dadosColetados['estado'] ?? ''}'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: publicando ? null : _publicarServico,
                      child: publicando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirmar e publicar'),
                    ),
                  ),
                ],
              ),
            ),

          // Chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                final msg = mensagens[index];
                final isUsuario = msg['autor'] == 'usuario';

                return Align(
                  alignment:
                      isUsuario ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isUsuario ? AppColors.blue : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['texto'] ?? '',
                      style: TextStyle(
                        color: isUsuario ? Colors.white : AppColors.navy,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 2,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviarMensagem(),
                      decoration: const InputDecoration(
                        hintText: 'Digite sua mensagem...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: loading ? null : _enviarMensagem,
                    icon: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
