import 'package:flutter/material.dart';
import 'package:app_workmatch/services/ServicoService.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/services/ServicoTab.dart';

class MeusServicosScreen extends StatefulWidget {
  final UserModel user;

  const MeusServicosScreen({super.key, required this.user});

  @override
  State<MeusServicosScreen> createState() => _MeusServicosScreenState();
}

class _MeusServicosScreenState extends State<MeusServicosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List servicos = [];
  Set avaliados = {};
  bool loading = true;

  final tabs = tabsCliente;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() => loading = true);

    try {
      final resServicos = await ServicoService.listarPorCliente(widget.user.id);

      setState(() {
        servicos = resServicos;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  List filtrar(int index) {
    final statuses = tabs[index].statuses;

    return servicos.where((s) => statuses.contains(s["status"])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Serviços"),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((t) => Tab(text: t.label)).toList(),
          onTap: (_) => setState(() {}),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: List.generate(tabs.length, (i) {
                final lista = filtrar(i);

                if (lista.isEmpty) {
                  return const Center(
                    child: Text("Nenhum serviço nesta categoria."),
                  );
                }

                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final s = lista[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(s["titulo"] ?? ""),
                        subtitle: Text(s["status"] ?? ""),
                        trailing: _statusBadge(s["status"]),
                      ),
                    );
                  },
                );
              }),
            ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "PUBLICADO":
        color = Colors.blue;
        break;
      case "NEGOCIANDO":
        color = Colors.orange;
        break;
      case "CONTRATADO":
      case "ANDAMENTO":
        color = Colors.green;
        break;
      case "FINALIZADO":
        color = Colors.grey;
        break;
      default:
        color = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
