import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Nav du bas identique à la maquette : Dashboard actif (blanc),
/// Specs et Profil au repos (gris muet), icônes Material.
class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    super.key,
    this.onSpecsTap,
    this.onProfileTap,
  });

  final VoidCallback? onSpecsTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: DashboardColors.background.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: DashboardColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: 'TABLEAU DE BORD',
            selected: true,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.memory,
            label: 'SPÉCS',
            selected: false,
            onTap: onSpecsTap ?? () {},
          ),
          _NavItem(
            icon: Icons.tune,
            label: 'PROFIL',
            selected: false,
            onTap: onProfileTap ?? () {},
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : DashboardColors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: DashboardText.labelDataSm(color: color).copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
