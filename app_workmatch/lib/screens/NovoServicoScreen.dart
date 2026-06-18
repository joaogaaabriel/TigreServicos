import 'package:app_workmatch/services/IaService.dart';
import 'package:app_workmatch/services/ServicoService.dart';
import 'package:flutter/material.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/theme/AppColors.dart';

class NovoServicoScreen extends StatefulWidget {
  final UserModel user;

  const NovoServicoScreen({
    super.key,
    required this.user,
  });

  @override
  State<NovoServicoScreen> createState() => _NovoServicoScreenState();
}

class _NovoServicoScreenState extends State<NovoServicoScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool loading = false;
  bool publicando = false;

  Map<String, dynamic> dadosColetados = {};

  Future<void> _enviarMensagem() async {
    print("BOTAO ENVIAR CLICADO");
    if (_controller.text.trim().isEmpty || loading) {
      print("TEXTO VAZIO OU LOADING");
      return;
    }
    final texto = _controller.text.trim();
    print("MENSAGEM: $texto");

    setState(() {
      mensagens.add({
        "autor": "usuario",
        "texto": texto,
      });

      loading = true;
    });

    _controller.clear();

    try {
      final historico = mensagens.map((m) {
        return {
          "role": m["autor"] == "usuario" ? "user" : "assistant",
          "content": m["texto"] ?? "",
        };
      }).toList();

      print("ENVIANDO PARA IA...");
      final resposta = await AiService.enviarMensagem(historico);
      print("RESPOSTA IA:");
      print(resposta);

      final dados = AiService.extrairDados(resposta);

      if (dados != null) {
        setState(() {
          dadosColetados = dados;

          mensagens.add({
            "autor": "ia",
            "texto":
                "Coletei todas as informações. Veja o resumo abaixo e confirme para publicar."
          });
        });
      } else {
        setState(() {
          mensagens.add({
            "autor": "ia",
            "texto": resposta,
          });
        });
      }
    } catch (e) {
      print("ERRO IA:");
      setState(() {
        mensagens.add({
          "autor": "ia",
          "texto": "Erro ao processar mensagem. Tente novamente."
        });
      });
    } finally {
      setState(() {
        loading = false;
      });

      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 300,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      );
    }
  }

  final List<Map<String, String>> mensagens = [
    {
      "autor": "ia",
      "texto":
          "Olá! Sou a assistente do WorkMatch. Vou te ajudar a publicar seu serviço em poucos passos. Me conta: qual tipo de serviço você precisa?"
    }
  ];

  Future<void> _publicarServico() async {
    if (dadosColetados.isEmpty) return;

    setState(() {
      publicando = true;
    });

    try {
      await ServicoService.publicarServico(
        dados: dadosColetados,
        clienteId: widget.user.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Serviço publicado com sucesso!"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        publicando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Novo serviço"),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (dadosColetados.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    "Resumo do serviço",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text("Título: ${dadosColetados['titulo']}"),
                  Text("Especialidade: ${dadosColetados!['especialidade']}"),
                  Text("Descrição: ${dadosColetados!['descricao']}"),
                  Text("Cidade: ${dadosColetados!['cidade']}"),
                  Text("Estado: ${dadosColetados!['estado']}"),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _publicarServico,
                      child: publicando
                          ? const CircularProgressIndicator()
                          : const Text("Confirmar e publicar"),
                    ),
                  ),
                ],
              ),
            ),

          // Chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                final msg = mensagens[index];
                final usuario = msg["autor"] == "usuario";

                return Align(
                  alignment:
                      usuario ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: usuario ? AppColors.blue : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["texto"] ?? "",
                      style: TextStyle(
                        color: usuario ? Colors.white : AppColors.navy,
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
                      decoration: const InputDecoration(
                        hintText: "Digite sua mensagem...",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () async {
                      print("CLICOU NO ICONE");
                      await _enviarMensagem();
                    },
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
