import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';
import 'dashboard_ring.dart';
import 'dashboard_stat_row.dart';

/// Carte "Charge RAM" — anneau + RAM active + swap zRAM (valeurs réelles,
/// "Indisponible" si le swap n'est pas exposé par l'appareil).
class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.memoryInfo,
    required this.usageRatio,
  });

  final Map<String, dynamic> memoryInfo;
  final double usageRatio;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return 'Indisponible';
    const gb = 1024 * 1024 * 1024;
    return '${(bytes / gb).toStringAsFixed(1)} Go';
  }

  @override
  Widget build(BuildContext context) {
    final total = memoryInfo['totalRamBytes'] as int? ?? 0;
    final used = memoryInfo['usedRamBytes'] as int? ?? 0;
    final available = memoryInfo['availableRamBytes'] as int? ?? 0;
    final swapTotal = memoryInfo['swapTotalBytes'] as int? ?? -1;
    final percent = (usageRatio * 100).round();

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
                    Icons.memory,
                    size: 16,
                    color: DashboardColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text('CHARGE RAM', style: DashboardText.labelDataSm()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          DashboardRing(
            value: usageRatio,
            ringColor: DashboardColors.textSecondary,
            centerValueText: total > 0 ? '$percent%' : '--',
            centerSubText: total > 0
                ? '${_formatBytes(available)} DISPO'
                : 'INDISPONIBLE',
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: DashboardColors.border)),
            ),
            child: Column(
              children: [
                DashboardStatRow(
                  label: 'Actif',
                  value: total > 0
                      ? '${_formatBytes(used)} / ${_formatBytes(total)}'
                      : 'Indisponible',
                ),
                const SizedBox(height: 4),
                DashboardStatRow(
                  label: 'Swap zRAM',
                  value: swapTotal >= 0
                      ? _formatBytes(swapTotal)
                      : 'Indisponible',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
