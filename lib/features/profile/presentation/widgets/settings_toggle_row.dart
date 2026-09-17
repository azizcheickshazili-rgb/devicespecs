import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_colors.dart';

/// Ligne "titre + sous-titre à gauche / interrupteur à droite", reprise
/// de la maquette Profil (blanc = activé, gris = désactivé).
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DashboardText.body(
                  color: DashboardColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: DashboardText.body()),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
          activeTrackColor: Colors.white,
          inactiveThumbColor: DashboardColors.textMuted,
          inactiveTrackColor: DashboardColors.chipBackground,
        ),
      ],
    );
  }
}
