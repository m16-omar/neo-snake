// IGNORE_FOR_FILE: DEPRECATED_MEMBER_USE
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
  final int level;
  final Animation<double>? animation;
  final bool animationsEnabled;

  SnakeBoardPainter({
    required this.snake,
    required this.apples,
    required this.obstacles,
    required this.dir,
    required this.cellSize,
    required this.cols,
    required this.rows,
    required this.level,
    this.animation,
    required this.animationsEnabled,
  }) : super(repaint: animationsEnabled ? animation : null);

  @override
  void paint(Canvas canvas, Size size) {
    final animValue = animationsEnabled ? (animation?.value ?? 0.0) : 0.0;
    // 5 REPEATING THEMES BASED ON LEVEL
    final themeIndex = (level - 1) % 5;

    // 1. DRAW THEME-SPECIFIC BACKGROUND
    Color bgColor;
    switch (themeIndex) {
      case 0:
        bgColor = const Color(0xFF0F1E16); // DARK JUNGLE GREEN
        break;
      case 1:
        bgColor = const Color(0xFF1D0E0A); // DARK ARCADE RUST
        break;
      case 2:
        bgColor = const Color(0xFF070B16); // DEEP CYBER NIGHT
        break;
      case 3:
        bgColor = const Color(0xFF161619); // DARK CHARCOAL
        break;
      case 4:
        bgColor = const Color(0xFF10071A); // DEEP PURPLE GALAXY
        break;
      default:
        bgColor = const Color(0xFF16301F);
    }
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. DRAW THEME-SPECIFIC GRID LINES
    Color gridColor;
    switch (themeIndex) {
      case 0:
        gridColor = Colors.black.withOpacity(0.20);
        break;
      case 1:
        gridColor = const Color(0xFFE6402F).withOpacity(0.06);
        break;
      case 2:
        gridColor = const Color(0xFF00E5FF).withOpacity(0.06);
        break;
      case 3:
        gridColor = const Color(0xFFFFD700).withOpacity(0.06);
        break;
      case 4:
        gridColor = const Color(0xFFE040FB).withOpacity(0.06);
        break;
      default:
        gridColor = Colors.black.withOpacity(0.22);
    }
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (int c = 0; c <= cols; c++) {
      final x = c * cellSize + 0.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int r = 0; r <= rows; r++) {
      final y = r * cellSize + 0.5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. DRAW OBSTACLES WITH UNIQUE VISUALS PER THEME
    for (final obs in obstacles) {
      final px = obs.x * cellSize;
      final py = obs.y * cellSize;

      if (themeIndex == 0) {
        // THEME 0: CLASSIC STONE
        final stoneColor = const Color(0xFF757575);
        final stoneDark = const Color(0xFF424242);
        final stoneLight = const Color(0xFFBDBDBD);
        final rect = Rect.fromLTWH(px + 2, py + 2, cellSize - 4, cellSize - 4);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
        canvas.drawRRect(rrect, Paint()..color = stoneColor);
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = stoneDark
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        canvas.drawLine(
          Offset(px + 4, py + 4),
          Offset(px + cellSize - 4, py + 4),
          Paint()..color = stoneLight..strokeWidth = 1.0,
        );
        canvas.drawLine(
          Offset(px + 4, py + 4),
          Offset(px + 4, py + cellSize - 4),
          Paint()..color = stoneLight..strokeWidth = 1.0,
        );
      } else if (themeIndex == 1) {
        // THEME 1: RETRO BRICK
        final brickColor = const Color(0xFF9E3D2F);
        final brickBorder = const Color(0xFF4A1A13);
        final rect = Rect.fromLTWH(px + 1.5, py + 1.5, cellSize - 3, cellSize - 3);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
        canvas.drawRRect(rrect, Paint()..color = brickColor);
        final strokePaint = Paint()
          ..color = brickBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRRect(rrect, strokePaint);
        // CENTER MORTAR LINE
        canvas.drawLine(
          Offset(px + 1.5, py + cellSize / 2),
          Offset(px + cellSize - 1.5, py + cellSize / 2),
          strokePaint,
        );
        // SPLIT LINES
        canvas.drawLine(
          Offset(px + cellSize / 3, py + 1.5),
          Offset(px + cellSize / 3, py + cellSize / 2),
          strokePaint,
        );
        canvas.drawLine(
          Offset(px + 2 * cellSize / 3, py + cellSize / 2),
          Offset(px + 2 * cellSize / 3, py + cellSize - 1.5),
          strokePaint,
        );
      } else if (themeIndex == 2) {
        // THEME 2: NEON CYBER OUTLINE
        final neonColor = const Color(0xFF00E5FF);
        final rect = Rect.fromLTWH(px + 3, py + 3, cellSize - 6, cellSize - 6);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
        final pulseGlow = 0.08 + animValue * 0.08;
        canvas.drawRRect(rrect, Paint()..color = neonColor.withOpacity(pulseGlow));
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = neonColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
        final dotPulse = 1.6 + animValue * 1.0;
        canvas.drawCircle(
          Offset(px + cellSize / 2, py + cellSize / 2),
          dotPulse,
          Paint()..color = neonColor,
        );
      } else if (themeIndex == 3) {
        // THEME 3: HAZARD STRIPED (ANIMATED SCROLLING STRIPES)
        final yellowColor = const Color(0xFFFFD700);
        final blackColor = const Color(0xFF1E1E1E);
        final rect = Rect.fromLTWH(px + 1, py + 1, cellSize - 2, cellSize - 2);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
        canvas.drawRRect(rrect, Paint()..color = yellowColor);

        canvas.save();
        canvas.clipRRect(rrect);
        final stripePaint = Paint()
          ..color = blackColor
          ..strokeWidth = 3.0;
        // SHIFT STRIPES OVER TIME FOR A MOVING TAPE EFFECT
        final animShift = animValue * 8.0;
        for (double offset = -cellSize - 8.0 + animShift; offset < cellSize * 2; offset += 8.0) {
          canvas.drawLine(
            Offset(px + offset, py),
            Offset(px + offset + cellSize, py + cellSize),
            stripePaint,
          );
        }
        canvas.restore();

        canvas.drawRRect(
          rrect,
          Paint()
            ..color = blackColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      } else {
        // THEME 4: PURPLE GEM STAR
        final gemColor = const Color(0xFFD500F9);
        final gemDark = const Color(0xFF4A0072);
        final cx = px + cellSize / 2;
        final cy = py + cellSize / 2;
        final r = cellSize / 2 - 2;

        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r, cy)
          ..close();
        canvas.drawPath(path, Paint()..color = gemColor);
        canvas.drawPath(
          path,
          Paint()
            ..color = gemDark
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        // ANIMATE THE REFLECTION TO SHIMMER SLIGHTLY
        final shimmer = sin(animValue * pi * 2) * 1.2;
        canvas.drawCircle(
          Offset(cx - 2 + shimmer, cy - 2 + shimmer),
          1.8,
          Paint()..color = Colors.white.withOpacity(0.8),
        );
      }
    }

    // 4. DRAW APPLES (ANIMATED PULSING SCALE)
    for (final apple in apples) {
      final cx = (apple.x + 0.5) * cellSize;
      final cy = (apple.y + 0.5) * cellSize;
      // CONTINUOUS APPLE SCALE PULSE
      final pulse = 1.0 + sin(animValue * pi * 2) * 0.08;
      final r = cellSize * 0.36 * pulse;

      // RED BODY
      final applePaint = Paint()..color = const Color(0xFFE6402F);
      canvas.drawCircle(Offset(cx, cy), r, applePaint);

      // REFLECTION
      final reflectionPaint = Paint()..color = Colors.white.withOpacity(0.25);
      canvas.drawCircle(
        Offset(cx - r * 0.35, cy - r * 0.4),
        r * 0.3,
        reflectionPaint,
      );

      // STEM
      final stemPaint = Paint()
        ..color = const Color(0xFF3A7A3A)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx, cy - r),
        Offset(cx + 1, cy - r - 5 * pulse),
        stemPaint,
      );

      // LEAF
      canvas.save();
      canvas.translate(cx + 4, cy - r - 5 * pulse);
      canvas.rotate(-0.6);
      final leafPaint = Paint()..color = const Color(0xFF4CAF50);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 8.0 * pulse, height: 4.8 * pulse),
        leafPaint,
      );
      canvas.restore();
    }

    // 5. DRAW SNAKE WITH DYNAMIC SCALING AND SHAPES (SLIM/BEADED/DIAMOND)
    for (int i = snake.length - 1; i >= 0; i--) {
      final seg = snake[i];
      final px = seg.x * cellSize;
      final py = seg.y * cellSize;
      final isHead = i == 0;

      double pad;
      if (themeIndex == 0) {
        pad = isHead ? 1.0 : 2.0; // CLASSIC CHUNKY
      } else if (themeIndex == 1) {
        pad = isHead ? 2.5 : 3.5; // SLIM NEON
      } else if (themeIndex == 2) {
        pad = isHead ? 3.0 : 5.0; // CYBER DOTS (VERY THIN/TINY SNAKE)
      } else if (themeIndex == 3) {
        pad = isHead ? 1.5 : 2.5; // MEDIUM DIAMOND
      } else {
        pad = isHead ? 2.8 : 4.8; // BEADED / DOTTED
      }

      final rect = Rect.fromLTWH(
        px + pad,
        py + pad,
        cellSize - pad * 2,
        cellSize - pad * 2,
      );

      switch (themeIndex) {
        case 0:
          // CLASSIC GREEN
          final fillPaint = Paint()
            ..color = isHead ? const Color(0xFF9CCC55) : const Color(0xFF8BC34A);
          final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(7));
          canvas.drawRRect(rrect, fillPaint);
          if (!isHead) {
            final strokePaint = Paint()
              ..color = const Color(0xFF6EA037)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4;
            canvas.drawRRect(rrect, strokePaint);

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
              canvas.drawRRect(
                scaleRRect,
                Paint()..color = Colors.white.withOpacity(0.10),
              );
            }
          }
          break;

        case 1:
          // SLIM NEON ORANGE (TINY SNAKE)
          final fillPaint = Paint()
            ..color = isHead ? const Color(0xFFFF9100) : const Color(0xFFFF3D00);
          final cx = px + cellSize / 2;
          final cy = py + cellSize / 2;
          final r = (cellSize - pad * 2) / 2;
          if (isHead) {
            canvas.drawCircle(
              Offset(cx, cy),
              r + 1.2,
              Paint()..color = const Color(0xFFFF9100).withOpacity(0.35),
            );
          }
          canvas.drawCircle(Offset(cx, cy), r, fillPaint);
          break;

        case 2:
          // CYBER NEON PINK DOTS
          final fillPaint = Paint()
            ..color = isHead ? const Color(0xFFFF4081) : const Color(0xFFF50057);
          final cx = px + cellSize / 2;
          final cy = py + cellSize / 2;
          final w = (cellSize - pad * 2) / 2;
          final path = Path()
            ..moveTo(cx, cy - w)
            ..lineTo(cx + w, cy)
            ..lineTo(cx, cy + w)
            ..lineTo(cx - w, cy)
            ..close();
          canvas.drawPath(
            path,
            Paint()..color = const Color(0xFFF50057).withOpacity(0.3),
          );
          canvas.drawPath(path, fillPaint);
          break;

        case 3:
          // GOLDEN SCALE
          final fillPaint = Paint()
            ..color = isHead ? const Color(0xFFFFEA00) : const Color(0xFFFFC400);
          final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
          canvas.drawRRect(rrect, fillPaint);
          if (!isHead) {
            canvas.drawRRect(
              rrect,
              Paint()
                ..color = const Color(0xFFB58A00)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0,
            );
          }
          break;

        case 4:
          // PURPLE BEADED / DOTTED
          final fillPaint = Paint()
            ..color = isHead ? const Color(0xFFE040FB) : const Color(0xFFD500F9);
          final cx = px + cellSize / 2;
          final cy = py + cellSize / 2;
          final r = (cellSize - pad * 2) / 2;
          canvas.drawCircle(Offset(cx, cy), r, fillPaint);
          if (!isHead) {
            canvas.drawCircle(
              Offset(cx, cy),
              r * 0.4,
              Paint()..color = const Color(0xFFFFFFFF).withOpacity(0.7),
            );
          }
          break;
      }
    }

    // 6. DRAW HEAD EYES
    if (snake.isNotEmpty) {
      final head = snake.first;
      final hx = (head.x + 0.5) * cellSize;
      final hy = (head.y + 0.5) * cellSize;
      final off = cellSize * 0.16;
      final fwd = cellSize * 0.12;

      double ex1, ey1, ex2, ey2;
      if (dir.x == 1) {
        ex1 = hx + fwd;
        ey1 = hy - off;
        ex2 = hx + fwd;
        ey2 = hy + off;
      } else if (dir.x == -1) {
        ex1 = hx - fwd;
        ey1 = hy - off;
        ex2 = hx - fwd;
        ey2 = hy + off;
      } else if (dir.y == -1) {
        ex1 = hx - off;
        ey1 = hy - fwd;
        ex2 = hx + off;
        ey2 = hy - fwd;
      } else {
        ex1 = hx - off;
        ey1 = hy + fwd;
        ex2 = hx + off;
        ey2 = hy + fwd;
      }

      // EYE & PUPIL COLORS MATCH THEME
      Color eyeColor;
      Color pupilColor = Colors.white;
      switch (themeIndex) {
        case 0:
          eyeColor = const Color(0xFF1B3A1B);
          break;
        case 1:
          eyeColor = const Color(0xFF4A0000);
          break;
        case 2:
          eyeColor = const Color(0xFF0D1B2A);
          pupilColor = const Color(0xFF00FFCC);
          break;
        case 3:
          eyeColor = const Color(0xFF3E2723);
          break;
        case 4:
          eyeColor = const Color(0xFF2A0D2E);
          break;
        default:
          eyeColor = const Color(0xFF1B3A1B);
      }

      final eyePaint = Paint()..color = eyeColor;
      final pupilPaint = Paint()..color = pupilColor;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex1, ey1), width: 5.2, height: 6.8),
        eyePaint,
      );
      canvas.drawCircle(Offset(ex1 - 0.6, ey1 - 1.0), 0.9, pupilPaint);

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
        oldDelegate.cellSize != cellSize ||
        oldDelegate.level != level;
  }
}
