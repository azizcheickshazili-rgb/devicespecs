import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Carte "Fréquence CPU" — sparkline de charge en direct (1s) + grille de
/// fréquences par groupe de cœurs, toutes valeurs réelles (lecture sysfs).
/// Aucun nom de puce n'est inventé (contrairement à la maquette qui
/// affichait "Tensor G3" à titre d'exemple).
class CpuCard extends StatelessWidget {
  const CpuCard({
    super.key,
    required this.cpuInfo,
    required this.loadHistory,
  });

  final Map<String, dynamic> cpuInfo;
  final List<double> loadHistory;

  @override
  Widget build(BuildContext context) {
    final cores = cpuInfo['cores'] as int? ?? 0;
    final loadPercent = cpuInfo['loadPercent'] as double? ?? -1;
    final frequencies =
        (cpuInfo['clusterFrequenciesGHz'] as List?)?.cast<double>() ??
        const <double>[];

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
                      Icons.developer_board,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fréquence CPU', style: DashboardText.headlineMd()),
                      Text(
                        cores > 0 ? '$cores CŒURS' : 'INDISPONIBLE',
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
                  loadPercent >= 0
                      ? '${loadPercent.toStringAsFixed(0)}%'
                      : '--',
                  style: DashboardText.labelDataSm(
                    color: DashboardColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            decoration: BoxDecoration(
              color: DashboardColors.sparklineBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DashboardColors.border),
            ),
            child: loadHistory.length < 2
                ? Center(
                    child: Text(
                      'Collecte en cours…',
                      style: DashboardText.labelDataSm(),
                    ),
                  )
                : CustomPaint(
                    size: Size.infinite,
                    painter: _SparklinePainter(values: loadHistory),
                  ),
          ),
          const SizedBox(height: 8),
          _FrequencyGrid(frequencies: frequencies),
        ],
      ),
    );
  }
}

class _FrequencyGrid extends StatelessWidget {
  const _FrequencyGrid({required this.frequencies});

  final List<double> frequencies;

  static const _labels = ['RAPIDE', 'INTERMÉDIAIRE', 'ÉCONOME'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final hasValue = i < frequencies.length;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: DashboardColors.chipBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: DashboardColors.border),
            ),
            child: Column(
              children: [
                Text(
                  _labels[i],
                  style: DashboardText.labelDataSm().copyWith(fontSize: 9),
                ),
                const SizedBox(height: 2),
                Text(
                  hasValue
                      ? '${frequencies[i].toStringAsFixed(2)} GHz'
                      : '--',
                  style: DashboardText.labelDataSm(
                    color: DashboardColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Sparkline dessinée à la main (aire dégradée + trait + point final),
/// même esprit visuel que le SVG de la maquette.
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxVal = 100.0;
    final stepX = size.width / (values.length - 1);

    final points = List.generate(values.length, (i) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxVal) * size.height;
      return Offset(x, y.clamp(0, size.height));
    });

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    canvas.drawCircle(points.last, 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values;
}
