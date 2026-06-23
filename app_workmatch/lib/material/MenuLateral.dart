import 'package:app_workmatch/core/theme/AppColors.dart';
import 'package:app_workmatch/model/UserModel.dart';
import 'package:flutter/material.dart';

/// Item de navegação — equivalente aos NAV_CLIENTE / NAV_PROFISSIONAL do React
class _NavItem {
  const _NavItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

// Equivalente ao NAV_CLIENTE do React
const _navCliente = [
  _NavItem(label: 'Início', icon: Icons.home_outlined),
  _NavItem(label: 'Meus serviços', icon: Icons.assignment_outlined),
  _NavItem(label: 'Meu perfil', icon: Icons.person_outline),
  _NavItem(label: 'Suporte', icon: Icons.chat_bubble_outline),
];

// Equivalente ao NAV_PROFISSIONAL do React
const _navProfissional = [
  _NavItem(label: 'Publicações', icon: Icons.home_outlined),
  _NavItem(label: 'Meus serviços', icon: Icons.assignment_outlined),
  _NavItem(label: 'Meu perfil', icon: Icons.person_outline),
  _NavItem(label: 'Suporte', icon: Icons.chat_bubble_outline),
];

/// Drawer de navegação lateral.
///
/// Uso — adicione ao Scaffold:
/// ```dart
/// Scaffold(
///   drawer: MenuLateral(
///     user: user,
///     itemAtivo: 0,           // índice do item ativo
///     onNavegar: (index) { }, // callback de navegação
///     onLogout: () { },
///   ),
///   appBar: AppBar(
///     leading: Builder(
///       builder: (ctx) => IconButton(
///         icon: const Icon(Icons.menu),
///         onPressed: () => Scaffold.of(ctx).openDrawer(),
///       ),
///     ),
///   ),
/// )
/// ```
class MenuLateral extends StatelessWidget {
  const MenuLateral({
    super.key,
    required this.user,
    required this.itemAtivo,
    required this.onNavegar,
    required this.onLogout,
  });

  final UserModel user;
  final int itemAtivo;
  final void Function(int index) onNavegar;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final isProfissional = user.isProfissional;
    final navItems = isProfissional ? _navProfissional : _navCliente;
    final inicial = user.nome.isNotEmpty ? user.nome[0].toUpperCase() : 'U';

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // ── Cabeçalho — igual ao wm-drawer__header ──────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              color: AppColors.navy,
              child: Column(
                children: [
                  // Avatar com inicial
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.yellow,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        inicial,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isProfissional
                            ? Icons.construction_outlined
                            : Icons.person_outline,
                        size: 13,
                        color: Colors.white60,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isProfissional ? 'Profissional' : 'Cliente',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Navegação — equivalente ao wm-drawer__nav ────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      'NAVEGAÇÃO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...List.generate(navItems.length, (i) {
                    final item = navItems[i];
                    final ativo = itemAtivo == i;
                    return _NavTile(
                      label: item.label,
                      icon: item.icon,
                      ativo: ativo,
                      onTap: () {
                        Navigator.of(context).pop(); // fecha o drawer
                        onNavegar(i);
                      },
                    );
                  }),
                ],
              ),
            ),

            // ── Footer — botão sair ──────────────────────────────────────
            const Divider(height: 1, color: AppColors.border),
            InkWell(
              onTap: () async {
                Navigator.of(context).pop();
                await onLogout();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Sair da conta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.ativo,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ativo ? AppColors.navy.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: ativo ? AppColors.navy : AppColors.textMid,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
                color: ativo ? AppColors.navy : AppColors.textMid,
              ),
            ),
            if (ativo) ...[
              const Spacer(),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
