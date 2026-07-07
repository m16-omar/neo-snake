// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/snake_game_controller.dart';
import '../models/snake_game_model.dart';
import 'widgets/snake_board_painter.dart';
import 'widgets/dpad_button.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  late final SnakeGameController _controller;
  final FocusNode _focusNode = FocusNode();
  Offset? _dragStart;

  @override
  void initState() {
    super.initState();
    _controller = SnakeGameController();
    // Re-render when the controller state changes
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  // Keyboard Event Handler
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
        _controller.setDir(0, -1);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowDown ||
          key == LogicalKeyboardKey.keyS) {
        _controller.setDir(0, 1);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.keyA) {
        _controller.setDir(-1, 0);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.keyD) {
        _controller.setDir(1, 0);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.space && !_controller.isRunning) {
        _controller.startGame();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // Touch Gesture Swiping Handler
  void _handlePanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;
    final current = details.localPosition;
    final dx = current.dx - _dragStart!.dx;
    final dy = current.dy - _dragStart!.dy;

    const double swipeThreshold = 20.0;
    if (dx.abs() > dy.abs()) {
      if (dx.abs() > swipeThreshold) {
        _controller.setDir(dx > 0 ? 1 : -1, 0);
        _dragStart = current; // Reset to allow chain-swiping
      }
    } else {
      if (dy.abs() > swipeThreshold) {
        _controller.setDir(0, dy > 0 ? 1 : -1);
        _dragStart = current; // Reset to allow chain-swiping
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragStart = null;
  }

  @override
  Widget build(BuildContext context) {
    const monoStyle = TextStyle(
      fontFamily: 'Courier',
      fontFamilyFallback: ['monospace'],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D1912),
      body: SafeArea(
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight - 260.0;
              final availableWidth = constraints.maxWidth - 40.0;
              final widthCellSize = availableWidth / SnakeGameModel.cols;
              final heightCellSize = availableHeight / SnakeGameModel.rows;
              final cellSize = min(
                26.0,
                min(widthCellSize, heightCellSize),
              ).clamp(12.0, 26.0);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // HUD
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: SizedBox(
                      width: min(
                        MediaQuery.of(context).size.width * 0.9,
                        SnakeGameModel.cols * cellSize + 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SCORE',
                                style: monoStyle.copyWith(
                                  color: const Color(0xFF5C8A63),
                                  fontSize: 11,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                '${_controller.score}',
                                style: monoStyle.copyWith(
                                  color: const Color(0xFFD4F7D4),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x6678DC8C),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'BEST',
                                style: monoStyle.copyWith(
                                  color: const Color(0xFF5C8A63),
                                  fontSize: 11,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                '${_controller.bestScore}',
                                style: monoStyle.copyWith(
                                  color: const Color(0xFFD4F7D4),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x6678DC8C),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Game Board Container
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.0),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF173324), Color(0xFF0F2318)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0xFF86E0C4),
                            spreadRadius: 3,
                            blurRadius: 0,
                          ),
                          const BoxShadow(
                            color: Color(0xFF0A1811),
                            spreadRadius: 1,
                            blurRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onPanStart: _handlePanStart,
                            onPanUpdate: _handlePanUpdate,
                            onPanEnd: _handlePanEnd,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: CustomPaint(
                                size: Size(
                                  SnakeGameModel.cols * cellSize,
                                  SnakeGameModel.rows * cellSize,
                                ),
                                painter: SnakeBoardPainter(
                                  snake: _controller.snake,
                                  apple: _controller.apple,
                                  dir: _controller.dir,
                                  cellSize: cellSize,
                                  cols: SnakeGameModel.cols,
                                  rows: SnakeGameModel.rows,
                                ),
                              ),
                            ),
                          ),

                          // Ready / Game Over Overlays
                          if (!_controller.isRunning)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  color: const Color(0xDC08140C),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _controller.isAlive
                                            ? 'READY?'
                                            : 'GAME OVER',
                                        style: monoStyle.copyWith(
                                          color: const Color(0xFFFF8A6B),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 3,
                                          shadows: const [
                                            Shadow(
                                              color: Color(0x80FF785A),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                        ),
                                        child: Text(
                                          _controller.isAlive
                                              ? 'Use arrow keys, swipe, or the pad below'
                                              : 'Score: ${_controller.score}${_controller.score >= _controller.bestScore && _controller.score > 0 ? '  •  new best!' : ''}',
                                          textAlign: TextAlign.center,
                                          style: monoStyle.copyWith(
                                            color: const Color(0xFF8FC99A),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      ElevatedButton(
                                        onPressed: () {
                                          _controller.startGame();
                                          _focusNode.requestFocus();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF86E0C4,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF0D2318,
                                          ),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 22,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _controller.isAlive
                                              ? 'PLAY'
                                              : 'PLAY AGAIN',
                                          style: monoStyle.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Gamepad D-pad controls
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 52),
                          DpadButton(
                            label: '▲',
                            onTap: () => _controller.setDir(0, -1),
                          ),
                          const SizedBox(width: 52),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DpadButton(
                            label: '◀',
                            onTap: () => _controller.setDir(-1, 0),
                          ),
                          const SizedBox(width: 6),
                          DpadButton(
                            label: '▼',
                            onTap: () => _controller.setDir(0, 1),
                          ),
                          const SizedBox(width: 6),
                          DpadButton(
                            label: '▶',
                            onTap: () => _controller.setDir(1, 0),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Hint
                  Text(
                    'arrow keys / WASD also work',
                    style: monoStyle.copyWith(
                      color: const Color(0xFF4D7256),
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
