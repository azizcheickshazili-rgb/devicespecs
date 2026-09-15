import 'package:flutter/material.dart';

import 'theme_export.dart';

/// Ligne "label à gauche / valeur à droite" utilisée dans les footers
/// des cartes Batterie et RAM.
class DashboardStatRow extends StatelessWidget {
  const DashboardStatRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: DashboardText.body()),
        Text(
          value,
          style: DashboardText.labelDataSm(
            color: DashboardColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
