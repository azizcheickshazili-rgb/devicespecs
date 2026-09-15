import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';
import 'dashboard_ring.dart';
import 'dashboard_stat_row.dart';

/// Carte "Batterie" — anneau + température + état de charge + santé
/// cellule, toutes valeurs réelles remontées du natif.
class BatteryCard extends StatelessWidget {
  const BatteryCard({super.key, required this.batteryInfo});

  final Map<String, dynamic> batteryInfo;

  @override
  Widget build(BuildContext context) {
    final int level = batteryInfo['level'] as int? ?? -1;
    final double temp = batteryInfo['temperatureCelsius'] as double? ?? -1;
    final String chargeState = batteryInfo['chargeState'] ?? 'Indisponible';
    final String cellHealth = batteryInfo['cellHealth'] ?? 'Indisponible';
    final bool available = level >= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bolt,
                    size: 16,
                    color: DashboardColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text('BATTERIE', style: DashboardText.labelDataSm()),
                ],
              ),
              Text(
                temp >= 0 ? '${temp.toStringAsFixed(0)}°C' : '--',
                style: DashboardText.labelDataMd(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          DashboardRing(
            value: available ? level / 100 : 0,
            centerValueText: available ? '$level%' : '--',
            centerSubText: chargeState.toUpperCase(),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: DashboardColors.border),
              ),
            ),
            child: Column(
              children: [
                DashboardStatRow(label: 'État de charge', value: chargeState),
                const SizedBox(height: 4),
                DashboardStatRow(label: 'Santé cellule', value: cellHealth),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
