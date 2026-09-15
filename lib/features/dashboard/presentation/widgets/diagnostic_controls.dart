import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// "CONTRÔLE DU DIAGNOSTIC" — bouton plein (Analyse rapide) + bouton
/// outline (Test des capteurs), identiques à la maquette.
class DiagnosticControls extends StatelessWidget {
  const DiagnosticControls({
    super.key,
    required this.onQuickScan,
    required this.onSensorTest,
  });

  final VoidCallback onQuickScan;
  final VoidCallback onSensorTest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CONTRÔLE DU DIAGNOSTIC',
              style: DashboardText.labelDataSm().copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'TÉLÉMÉTRIE EN DIRECT (1S)',
              style: DashboardText.labelDataSm().copyWith(fontSize: 9),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DiagnosticButton(
                label: 'Analyse rapide',
                icon: Icons.radar,
                filled: true,
                onTap: onQuickScan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DiagnosticButton(
                label: 'Test des capteurs',
                icon: Icons.sensors,
                filled: false,
                onTap: onSensorTest,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DiagnosticButton extends StatelessWidget {
  const _DiagnosticButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? Colors.white : DashboardColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled
                ? null
                : Border.all(color: DashboardColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: filled ? Colors.black : DashboardColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: DashboardText.headlineMd(
                  color: filled ? Colors.black : Colors.white,
                ).copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
