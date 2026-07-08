// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeBoardPainter extends CustomPainter {
  final List<Point<int>> snake;
  final List<Point<int>> apples;
  final List<Point<int>> obstacles;
  final Point<int> dir;
  final double cellSize;
  final int cols;
  final int rows;

  SnakeBoardPainter({
    required this.snake,
    required this.apples,
    required this.obstacles,
    required this.dir,
    required this.cellSize,
    required this.cols,
    required this.rows,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Background
    final bgPaint = Paint()..color = const Color(0xFF16301F);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw Grid Lines
    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.22)
      ..strokeWidth = 1.0;

    for (int c = 0; c <= cols; c++) {
      final x = c * cellSize + 0.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int r = 0; r <= rows; r++) {
      final y = r * cellSize + 0.5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw Obstacles
    final stoneColor = const Color(0xFF757575);
    final stoneDark = const Color(0xFF424242);
    final stoneLight = const Color(0xFFBDBDBD);
    for (final obs in obstacles) {
      final px = obs.x * cellSize;
      final py = obs.y * cellSize;
      final pad = 2.0;
      final rect = Rect.fromLTWH(
        px + pad,
        py + pad,
        cellSize - pad * 2,
        cellSize - pad * 2,
      );
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));

      final stonePaint = Paint()..color = stoneColor;
      canvas.drawRRect(rrect, stonePaint);

      // Dark border
      final strokePaint = Paint()
        ..color = stoneDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(rrect, strokePaint);

      // Light bevel highlights
      final linePaint = Paint()
        ..color = stoneLight
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(px + pad + 2, py + pad + 2),
        Offset(px + cellSize - pad - 2, py + pad + 2),
        linePaint,
      );
      canvas.drawLine(
        Offset(px + pad + 2, py + pad + 2),
        Offset(px + pad + 2, py + cellSize - pad - 2),
        linePaint,
      );
    }

    // Draw Apples
    for (final apple in apples) {
      final cx = (apple.x + 0.5) * cellSize;
      final cy = (apple.y + 0.5) * cellSize;
      final r = cellSize * 0.36;

      // Red body
      final applePaint = Paint()..color = const Color(0xFFE6402F);
      canvas.drawCircle(Offset(cx, cy), r, applePaint);

      // Reflection
      final reflectionPaint = Paint()..color = Colors.white.withOpacity(0.25);
      canvas.drawCircle(
        Offset(cx - r * 0.35, cy - r * 0.4),
        r * 0.3,
        reflectionPaint,
      );

      // Stem
      final stemPaint = Paint()
        ..color = const Color(0xFF3A7A3A)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx, cy - r),
        Offset(cx + 1, cy - r - 5),
        stemPaint,
      );

      // Leaf
      canvas.save();
      canvas.translate(cx + 4, cy - r - 5);
      canvas.rotate(-0.6);
      final leafPaint = Paint()..color = const Color(0xFF4CAF50);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 8.0, height: 4.8),
        leafPaint,
      );
      canvas.restore();
    }

    // Draw Snake
    const bodyColor = Color(0xFF8BC34A);
    const bodyDark = Color(0xFF6EA037);
    const headColor = Color(0xFF9CCC55);

    for (int i = snake.length - 1; i >= 0; i--) {
      final seg = snake[i];
      final px = seg.x * cellSize;
      final py = seg.y * cellSize;
      final isHead = i == 0;
      final pad = isHead ? 1.0 : 2.0;

      final rect = Rect.fromLTWH(
        px + pad,
        py + pad,
        cellSize - pad * 2,
        cellSize - pad * 2,
      );
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(7));

      final fillPaint = Paint()..color = isHead ? headColor : bodyColor;
      canvas.drawRRect(rrect, fillPaint);

      if (!isHead) {
        final strokePaint = Paint()
          ..color = bodyDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        canvas.drawRRect(rrect, strokePaint);

        // Highlight scales
        if (i % 2 == 0) {
          final scalePad = pad + 3.0;
          final scaleRect = Rect.fromLTWH(
            px + scalePad,
            py + scalePad,
            cellSize - pad * 2 - 6,
            (cellSize - pad * 2 - 6) / 2,
          );
          final scaleRRect = RRect.fromRectAndRadius(
            scaleRect,
            const Radius.circular(3),
          );
          final scalePaint = Paint()..color = Colors.white.withOpacity(0.10);
          canvas.drawRRect(scaleRRect, scalePaint);
        }
      }
    }

    // Draw Head Eyes
    if (snake.isNotEmpty) {
      final head = snake.first;
      final hx = (head.x + 0.5) * cellSize;
      final hy = (head.y + 0.5) * cellSize;
      final off = cellSize * 0.16;
      final fwd = cellSize * 0.12;

      double ex1, ey1, ex2, ey2;
      if (dir.x == 1) {
        // Right
        ex1 = hx + fwd;
        ey1 = hy - off;
        ex2 = hx + fwd;
        ey2 = hy + off;
      } else if (dir.x == -1) {
        // Left
        ex1 = hx - fwd;
        ey1 = hy - off;
        ex2 = hx - fwd;
        ey2 = hy + off;
      } else if (dir.y == -1) {
        // Up
        ex1 = hx - off;
        ey1 = hy - fwd;
        ex2 = hx + off;
        ey2 = hy - fwd;
      } else {
        // Down
        ex1 = hx - off;
        ey1 = hy + fwd;
        ex2 = hx + off;
        ey2 = hy + fwd;
      }

      final eyePaint = Paint()..color = const Color(0xFF1B3A1B);
      final pupilPaint = Paint()..color = Colors.white;

      // Draw eye 1
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex1, ey1), width: 5.2, height: 6.8),
        eyePaint,
      );
      canvas.drawCircle(Offset(ex1 - 0.6, ey1 - 1.0), 0.9, pupilPaint);

      // Draw eye 2
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex2, ey2), width: 5.2, height: 6.8),
        eyePaint,
      );
      canvas.drawCircle(Offset(ex2 - 0.6, ey2 - 1.0), 0.9, pupilPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SnakeBoardPainter oldDelegate) {
    return oldDelegate.snake != snake ||
        oldDelegate.apples != apples ||
        oldDelegate.obstacles != obstacles ||
        oldDelegate.dir != dir ||
        oldDelegate.cellSize != cellSize;
  }
}
