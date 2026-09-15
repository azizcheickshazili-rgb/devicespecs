import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Carte "Device Summary" — reprend exactement la maquette : icône +
/// nom de code appareil, modèle + version Android, build, pastille
/// de statut dérivée du niveau de batterie réel.
class DeviceSummaryCard extends StatelessWidget {
  const DeviceSummaryCard({
    super.key,
    required this.deviceInfo,
    required this.statusLabel,
    required this.batteryLevel,
  });

  final Map<String, dynamic> deviceInfo;
  final String statusLabel;
  final int batteryLevel;

  @override
  Widget build(BuildContext context) {
    final model = deviceInfo['model'] ?? 'Indisponible';
    final osVersion = deviceInfo['osVersion'] ?? 'Indisponible';
    final manufacturer = deviceInfo['manufacturer'] ?? 'Indisponible';
    final buildId = deviceInfo['buildId'] ?? 'Indisponible';
    final deviceCodeName = deviceInfo['deviceCodeName'] ?? 'Indisponible';
    final hasBattery = batteryLevel >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.smartphone,
                      size: 17,
                      color: DashboardColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'APPAREIL · $deviceCodeName'.toUpperCase(),
                      style: DashboardText.labelDataSm(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$model · Android $osVersion',
                  style: DashboardText.headlineMd(),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$manufacturer · Build $buildId',
                  style: DashboardText.labelDataSm(),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: DashboardColors.chipBackground,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: DashboardColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  hasBattery
                      ? '$statusLabel · $batteryLevel%'
                      : statusLabel,
                  style: DashboardText.labelDataSm(
                    color: DashboardColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
