import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Carte "Réseau" — SSID, débit de liaison réel (WifiManager), latence
/// mesurée par une connexion TCP courte vers la passerelle, adresse IP.
/// Pas de norme Wi-Fi inventée (la maquette affichait "Wi-Fi 7" à titre
/// d'exemple ; l'API Android publique n'expose pas cette information).
class NetworkCard extends StatelessWidget {
  const NetworkCard({super.key, required this.networkInfo});

  final Map<String, dynamic> networkInfo;

  @override
  Widget build(BuildContext context) {
    final ssid = networkInfo['ssid'] ?? 'Indisponible';
    final isConnected = networkInfo['isConnected'] as bool? ?? false;
    final linkSpeed = networkInfo['linkSpeedMbps'] as int? ?? -1;
    final latency = networkInfo['latencyMs'] as int? ?? -1;
    final ip = networkInfo['ipAddress'] ?? 'Indisponible';

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
                    child: const Icon(Icons.wifi, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Wi-Fi', style: DashboardText.headlineMd()),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isConnected
                                  ? Colors.white
                                  : DashboardColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isConnected ? 'Connecté · $ssid' : 'Déconnecté',
                        style: DashboardText.labelDataSm(),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: DashboardColors.chipBackground,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: DashboardColors.border),
                ),
                child: Text(
                  isConnected ? 'LIAISON ACTIVE' : 'HORS LIGNE',
                  style: DashboardText.labelDataSm(
                    color: DashboardColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _NetworkStat(
                  label: 'DÉBIT DE LIAISON',
                  value: linkSpeed >= 0 ? '$linkSpeed' : '--',
                  unit: 'Mbps',
                  footer: null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NetworkStat(
                  label: 'LATENCE PASSERELLE',
                  value: latency >= 0 ? '$latency' : '--',
                  unit: 'ms',
                  footer: ip,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetworkStat extends StatelessWidget {
  const _NetworkStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.footer,
  });

  final String label;
  final String value;
  final String unit;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: DashboardColors.chipBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DashboardText.labelDataSm().copyWith(fontSize: 9)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: DashboardText.labelDataLg(),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: DashboardText.labelDataSm().copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 4),
            Text(
              footer!,
              style: DashboardText.labelDataSm(),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
