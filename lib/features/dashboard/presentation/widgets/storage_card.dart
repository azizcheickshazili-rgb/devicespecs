import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Carte "Stockage interne" — barre de progression, sans nom de bus
/// inventé (l'info n'est pas exposée par l'API Android publique).
class StorageCard extends StatelessWidget {
  const StorageCard({
    super.key,
    required this.storageInfo,
    required this.usageRatio,
  });

  final Map<String, dynamic> storageInfo;
  final double usageRatio;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return 'Indisponible';
    const gb = 1024 * 1024 * 1024;
    return '${(bytes / gb).toStringAsFixed(0)} Go';
  }

  @override
  Widget build(BuildContext context) {
    final total = storageInfo['totalBytes'] as int? ?? 0;
    final used = storageInfo['usedBytes'] as int? ?? 0;
    final free = storageInfo['freeBytes'] as int? ?? 0;
    final available = total > 0;
    final percent = (usageRatio * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DashboardColors.chipBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.storage,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stockage interne', style: DashboardText.headlineMd()),
                      Text(
                        'STOCKAGE PRINCIPAL',
                        style: DashboardText.labelDataSm(),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    available ? '$percent%' : '--',
                    style: DashboardText.labelDataMd(
                      weight: FontWeight.w600,
                    ).copyWith(fontSize: 14),
                  ),
                  Text('ALLOUÉ', style: DashboardText.labelDataSm()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: usageRatio),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: DashboardColors.border,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                available
                    ? '${_formatBytes(used)} utilisés sur ${_formatBytes(total)}'
                    : 'Indisponible',
                style: DashboardText.labelDataSm(),
              ),
              Text(
                available ? '${_formatBytes(free)} libres' : '',
                style: DashboardText.labelDataSm(
                  color: DashboardColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
