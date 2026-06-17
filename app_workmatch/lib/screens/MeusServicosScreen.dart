import 'package:flutter/material.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/services/ServicoService.dart';
import 'package:app_workmatch/tigreservicos/core/theme/AppColors.dart';

class MeusServicosScreen extends StatefulWidget {
  final UserModel user;
  final String? statusInicial;

  const MeusServicosScreen({
    super.key,
    required this.user,
    this.statusInicial,
  });

  @override
  State<MeusServicosScreen> createState() => _MeusServicosScreenState();
}

class _MeusServicosScreenState extends State<MeusServicosScreen> {
  bool loading = true;

  List<dynamic> servicos = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    try {
      final response =
          await ServicoService.listarPorCliente(widget.user.id);

      setState(() {
        servicos = response;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Color corStatus(String status) {
    switch (status.toUpperCase()) {
      case "PUBLICADO":
        return Colors.blue;
      case "NEGOCIANDO":
        return Colors.orange;
      case "CONTRATADO":
        return Colors.green;
      case "ANDAMENTO":
        return Colors.teal;
      case "FINALIZADO":
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = widget.statusInicial == null
        ? servicos
        : servicos
            .where(
              (s) =>
                  (s["status"] ?? "")
                      .toString()
                      .toUpperCase() ==
                  widget.statusInicial!.toUpperCase(),
            )
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Meus Serviços"),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : lista.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhum serviço encontrado.",
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final servico = lista[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    servico["titulo"] ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: corStatus(
                                      servico["status"] ?? "",
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child: Text(
                                    servico["status"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              servico["especialidade"] ?? "",
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),

                            if (servico["cidade"] != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(
                                  top: 8,
                                ),
                                child: Text(
                                  "${servico["cidade"]} - ${servico["estado"] ?? ""}",
                                ),
                              ),

                            const SizedBox(height: 12),

                            Text(
                              servico["descricao"] ?? "",
                              maxLines: 3,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}