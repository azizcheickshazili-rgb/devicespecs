import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

/// Anneau circulaire animé, identique au tracé SVG de la maquette
/// (cercle de fond + cercle de progression avec bouts arrondis).
class DashboardRing extends StatelessWidget {
  const DashboardRing({
    super.key,
    required this.value,
    required this.centerValueText,
    required this.centerSubText,
    this.ringColor = Colors.white,
    this.size = 96,
    this.strokeWidth = 6.5,
  });

  final double value; // 0.0 - 1.0
  final String centerValueText;
  final String centerSubText;
  final Color ringColor;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) => CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                value: animatedValue,
                ringColor: ringColor,
                trackColor: DashboardColors.border,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerValueText, style: DashboardText.labelDataLg()),
              const SizedBox(height: 2),
              Text(
                centerSubText,
                textAlign: TextAlign.center,
                style: DashboardText.labelDataSm().copyWith(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14159265 / 2; // -90°
    final sweepAngle = 2 * 3.14159265 * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.trackColor != trackColor;
}
