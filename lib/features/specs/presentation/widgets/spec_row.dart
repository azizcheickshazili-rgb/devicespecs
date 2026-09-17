import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_colors.dart';

/// Une ligne "libellé / valeur" dans l'accordéon Specs.
class SpecRow extends StatelessWidget {
  const SpecRow({
    super.key,
    required this.label,
    required this.value,
    this.shaded = false,
  });

  final String label;
  final String value;
  final bool shaded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: shaded
            ? DashboardColors.sparklineBg.withOpacity(0.6)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: DashboardText.body()),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: DashboardText.labelDataSm(
                color: DashboardColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
