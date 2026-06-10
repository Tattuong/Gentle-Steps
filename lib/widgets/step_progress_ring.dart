import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';

class StepProgressRing extends StatefulWidget {
  final int steps;
  final int goal;
  final double size;

  const StepProgressRing({
    super.key,
    required this.steps,
    required this.goal,
    this.size = 220,
  });

  @override
  State<StepProgressRing> createState() => _StepProgressRingState();
}

class _StepProgressRingState extends State<StepProgressRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void didUpdateWidget(StepProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps != widget.steps) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final progress = widget.goal == 0 ? 0.0 : (widget.steps / widget.goal).clamp(0.0, 1.0);
    final color = AppColors.progressColor(progress);
    final formatted = NumberFormat.decimalPattern().format(widget.steps);

    return ScaleTransition(
      scale: _scaleAnim,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _StepRingPainter(progress: progress, color: color, isDark: Theme.of(context).brightness == Brightness.dark),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  progress >= 1.0 ? '🎉' : '👟',
                  style: TextStyle(fontSize: widget.size * 0.14),
                ),
                const SizedBox(height: 4),
                Text(
                  formatted,
                  style: TextStyle(
                    fontSize: widget.size * 0.16,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    height: 1.1,
                  ),
                ),
                Text(
                  '/ ${NumberFormat.decimalPattern().format(widget.goal)}',
                  style: TextStyle(
                    fontSize: widget.size * 0.055,
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  _StepRingPainter({required this.progress, required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const stroke = 16.0;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.18 : 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final fgPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          colors: [color.withValues(alpha: 0.5), color, AppColors.secondary],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fgPaint,
      );
    }

    for (var i = 0; i < 8; i++) {
      final angle = (2 * math.pi / 8) * i - math.pi / 2;
      final dotCenter = Offset(
        center.dx + math.cos(angle) * (radius + 6),
        center.dy + math.sin(angle) * (radius + 6),
      );
      final dotPaint = Paint()
        ..color = color.withValues(alpha: 0.12 + progress * 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotCenter, 4 + progress * 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_StepRingPainter old) =>
      old.progress != progress || old.color != color || old.isDark != isDark;
}
