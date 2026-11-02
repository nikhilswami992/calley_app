import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Custom multi-segment donut chart shown on Screen 08 (Active Dashboard).
class CallsDonutChart extends StatelessWidget {
  const CallsDonutChart({
    super.key,
    required this.pending,
    required this.done,
    required this.scheduled,
    this.size = 210,
  });

  final int pending;
  final int done;
  final int scheduled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutChartPainter(
          pending: pending,
          done: done,
          scheduled: scheduled,
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.pending,
    required this.done,
    required this.scheduled,
  });

  final int pending;
  final int done;
  final int scheduled;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.shortestSide / 2;

    // Subtle light-grey inner disc matching Figma Screen 08.
    final innerDiscPaint = Paint()
      ..color = const Color(0xFFF1F4F9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius * 0.56, innerDiscPaint);

    final total = (pending + done + scheduled).clamp(1, 1 << 30);
    // In Figma Screen 08 the blue segment sits on the right starting at the top
    // (-90 degrees), followed clockwise by purple (bottom-left) and orange
    // (top-left), with a slightly thicker stroke on the purple segment.
    const gapRadians = 0.055;
    final segments = [
      _Segment(
        value: done > 0 ? done.toDouble() : 22,
        color: AppColors.primary,
        strokeFactor: 0.25,
      ),
      _Segment(
        value: scheduled > 0 ? scheduled.toDouble() : 9,
        color: AppColors.schedule,
        strokeFactor: 0.30,
      ),
      _Segment(
        value: pending > 0 ? pending.toDouble() : 28,
        color: AppColors.pending,
        strokeFactor: 0.25,
      ),
    ];

    final sum = segments.fold<double>(
      0,
      (acc, s) => acc + (total > 0 ? s.value : 1),
    );

    var startAngle = -math.pi / 2 + gapRadians / 2;
    for (final s in segments) {
      final sweep = (s.value / sum) * (2 * math.pi) - gapRadians;
      if (sweep <= 0) continue;
      final strokeWidth = outerRadius * s.strokeFactor;
      final radius = outerRadius - strokeWidth / 2;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep + gapRadians;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.pending != pending ||
        oldDelegate.done != done ||
        oldDelegate.scheduled != scheduled;
  }
}

class _Segment {
  final double value;
  final Color color;
  final double strokeFactor;

  const _Segment({
    required this.value,
    required this.color,
    required this.strokeFactor,
  });
}
