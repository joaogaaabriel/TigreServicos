import 'package:flutter/material.dart';
import 'package:app_workmatch/core/services/ServicoService.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/core/services/ServicoTab.dart';

class MeusServicosScreen extends StatefulWidget {
  const MeusServicosScreen({
    super.key,
    required this.user,
    required this.servicoService,
  });

  final UserModel user;
  final ServicoService servicoService; // injetado — não mais estático

  @override
  State<MeusServicosScreen> createState() => _MeusServicosScreenState();
}

class _MeusServicosScreenState extends State<MeusServicosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> servicos = [];
  bool loading = true;

  final tabs = tabsCliente;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => loading = true);
    try {
      final result =
          await widget.servicoService.listarPorCliente(widget.user.id);
      if (mounted) setState(() => servicos = result);
    } catch (e) {
      // erro silencioso — lista fica vazia
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<dynamic> _filtrar(int index) {
    final statuses = tabs[index].statuses;
    return servicos.where((s) => statuses.contains(s['status'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Serviços'),
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
                final lista = _filtrar(i);

                if (lista.isEmpty) {
                  return const Center(
                    child: Text('Nenhum serviço nesta categoria.'),
                  );
                }

                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final s = lista[index] as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(s['titulo'] ?? ''),
                        subtitle: Text(s['status'] ?? ''),
                        trailing: _statusBadge(s['status'] ?? ''),
                      ),
                    );
                  },
                );
              }),
            ),
    );
  }

  Widget _statusBadge(String status) {
    final Color color;
    switch (status) {
      case 'PUBLICADO':
        color = Colors.blue;
        break;
      case 'NEGOCIANDO':
        color = Colors.orange;
        break;
      case 'CONTRATADO':
      case 'ANDAMENTO':
        color = Colors.green;
        break;
      case 'FINALIZADO':
        color = Colors.grey;
        break;
      default:
        color = Colors.black54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
