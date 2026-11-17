import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: AppColors.background),
        child: CustomPaint(painter: const _PaperPainter(), child: child),
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  const _PaperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = AppColors.divider.withValues(alpha: 0.32);
    final fiberPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.035)
      ..strokeWidth = 0.7;
    const spacing = 22.0;
    for (var y = 8.0; y < size.height; y += spacing) {
      final offset = ((y / spacing).round().isEven ? 0.0 : 11.0);
      for (var x = offset + 6.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.7, dotPaint);
      }
    }
    for (var i = 0; i < math.max(1, (size.height / 54).floor()); i++) {
      final y = 18.0 + i * 54.0;
      final start = ((i * 37) % math.max(1, size.width.toInt())).toDouble();
      final length = math.min(42.0, size.width - start);
      if (length > 8) {
        canvas.drawLine(
          Offset(start, y),
          Offset(start + length, y + 1.2),
          fiberPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PaperPainter oldDelegate) => false;
}
