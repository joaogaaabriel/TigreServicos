import 'package:app_workmatch/core/services/ServicoService.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:app_workmatch/screens/MeusServicosScreen.dart';
import 'package:app_workmatch/screens/NovoServicoScreen.dart';
import 'package:app_workmatch/core/theme/AppColors.dart';
import 'package:flutter/material.dart';

class _StatusCard {
  final String label;
  final String emoji;
  final Color color;
  final String status;

  const _StatusCard({
    required this.label,
    required this.emoji,
    required this.color,
    required this.status,
  });
}

class _ComoFunciona {
  final String n;
  final IconData icon;
  final String title;
  final String desc;
  const _ComoFunciona(
      {required this.n,
      required this.icon,
      required this.title,
      required this.desc});
}

const _statusCards = [
  _StatusCard(
    label: 'Publicados',
    emoji: '📋',
    color: AppColors.blue,
    status: 'publicado',
  ),
  _StatusCard(
    label: 'Negociando',
    emoji: '💬',
    color: AppColors.warning,
    status: 'negociando',
  ),
  _StatusCard(
    label: 'Em andamento',
    emoji: '⚙️',
    color: Color(0xFF0EA5A0),
    status: 'andamento',
  ),
  _StatusCard(
    label: 'Concluídos',
    emoji: '✅',
    color: AppColors.success,
    status: 'concluido',
  ),
];

const _comoFunciona = [
  _ComoFunciona(
      n: '1',
      icon: Icons.smart_toy_outlined,
      title: 'Converse com a IA',
      desc:
          'Nossa IA coleta os detalhes do seu serviço por meio de uma conversa simples e natural.'),
  _ComoFunciona(
      n: '2',
      icon: Icons.auto_awesome_outlined,
      title: 'Publicação automática',
      desc:
          'A IA organiza as informações e publica para que profissionais qualificados se candidatem.'),
  _ComoFunciona(
      n: '3',
      icon: Icons.handshake_outlined,
      title: 'Negocie e contrate',
      desc:
          'Avalie os candidatos, negocie os detalhes e contrate o profissional ideal.'),
  _ComoFunciona(
      n: '4',
      icon: Icons.verified_outlined,
      title: 'Serviço concluído',
      desc:
          'Após a conclusão, avalie o profissional e ajude outros clientes a encontrar os melhores.'),
];

class HomeClienteScreen extends StatelessWidget {
  const HomeClienteScreen({
    super.key,
    required this.user,
    this.onNovoServico,
    this.onVerServicos,
    this.onVerServicosPorStatus,
    this.onLogout,
    required this.servicoService,
  });

  final UserModel user;
  final VoidCallback? onNovoServico;
  final VoidCallback? onVerServicos;
  final void Function(String status)? onVerServicosPorStatus;
  final Future<void> Function()? onLogout;
  final ServicoService servicoService;

  String get _primeiroNome {
    final partes = user.nome.trim().split(' ');
    return partes.isNotEmpty ? partes[0] : 'Cliente';
  }

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
            onPressed: onLogout == null
                ? null
                : () async {
                    await onLogout!();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Banner(
              primeiroNome: _primeiroNome,
              onNovoServico: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NovoServicoScreen(
                      user: user,
                      servicoService: servicoService,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _MeusServicos(
              onVerTodos: onVerServicos,
              onTap: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MeusServicosScreen(
                      user: user,
                      servicoService: servicoService,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _ComoFuncionaSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NovoServicoScreen(
                user: user,
                servicoService: servicoService,
              ),
            ),
          );
        },
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text(
          'Iniciar com IA',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Banner de boas-vindas ─────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  const _Banner({
    required this.primeiroNome,
    this.onNovoServico,
  });

  final String primeiroNome;
  final VoidCallback? onNovoServico;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navyDeep, Color(0xFF1A3A6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow — "Olá, Nome" sem emoji
          Text(
            'Olá, $primeiroNome',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Precisa de um\nprofissional?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Converse com nossa IA e publique\nseu serviço em minutos.',
            style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onNovoServico,
              icon: const Icon(Icons.smart_toy_outlined),
              label: const Text('Iniciar com IA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.navy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meus Serviços ─────────────────────────────────────────────────────────────

class _MeusServicos extends StatelessWidget {
  const _MeusServicos({this.onVerTodos, this.onTap});

  final VoidCallback? onVerTodos;
  final void Function(String status)? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Meus serviços',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            TextButton(
              onPressed: onVerTodos,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: _statusCards.map((card) {
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onTap?.call(card.status),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: card.color.withOpacity(0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.emoji,
                      style: const TextStyle(fontSize: 38),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      card.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StatusCardTile extends StatefulWidget {
  const _StatusCardTile({required this.card, this.onTap});
  final _StatusCard card;
  final VoidCallback? onTap;

  @override
  State<_StatusCardTile> createState() => _StatusCardTileState();
}

class _StatusCardTileState extends State<_StatusCardTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            top: BorderSide(color: widget.card.color, width: 3),
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
            bottom: BorderSide(color: AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.10 : 0.04),
              blurRadius: _hovered ? 12 : 4,
              offset: Offset(0, _hovered ? 4 : 1),
            ),
          ],
        ),
        transform: _hovered
            ? (Matrix4.identity()..translate(0.0, -2.0))
            : Matrix4.identity(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.card.emoji,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 12),
            Text(
              widget.card.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Como Funciona ─────────────────────────────────────────────────────────────

class _ComoFuncionaSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Como funciona',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.navy),
        ),
        const SizedBox(height: 12),
        ..._comoFunciona.map((item) => _ComoFuncionaTile(item: item)),
      ],
    );
  }
}

class _ComoFuncionaTile extends StatelessWidget {
  const _ComoFuncionaTile({required this.item});
  final _ComoFunciona item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone com badge de número — igual ao frontend
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.icon, color: AppColors.blue, size: 28),
              Positioned(
                top: -6,
                right: -8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      item.n,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMid,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
