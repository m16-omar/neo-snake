// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/snake_game_controller.dart';
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

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF14241B),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0x3386E0C4), width: 1.5),
        ),
        child: const Icon(Icons.arrow_back, color: Color(0xFF86E0C4), size: 18),
      ),
    );
  }

  Widget _buildTopBar(TextStyle monoStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1912),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0x1A86E0C4), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Length
          _buildTopBarItem(
            icon: Icons.gesture,
            iconColor: const Color(0xFF8BC34A),
            label: 'LENGTH',
            value: '${_controller.snake.length}',
            valueColor: const Color(0xFF8BC34A),
            monoStyle: monoStyle,
          ),
          _buildVerticalDivider(),
          // Food Eaten
          _buildTopBarItem(
            icon: Icons.apple,
            iconColor: const Color(0xFFE6402F),
            label: 'FOOD EATEN',
            value: '${_controller.foodEaten}',
            valueColor: const Color(0xFFE6402F),
            monoStyle: monoStyle,
          ),
          _buildVerticalDivider(),
          // Time
          _buildTopBarItem(
            icon: Icons.access_time,
            iconColor: const Color(0xFF00BCD4),
            label: 'TIME',
            value: _formatTime(_controller.timeElapsedSec),
            valueColor: const Color(0xFF00BCD4),
            monoStyle: monoStyle,
          ),
          _buildVerticalDivider(),
          // Best
          _buildTopBarItem(
            icon: Icons.emoji_events,
            iconColor: const Color(0xFFFFD700),
            label: 'BEST',
            value: '${_controller.bestScore}',
            valueColor: const Color(0xFFFFD700),
            monoStyle: monoStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 20, width: 1, color: const Color(0x1A86E0C4));
  }

  Widget _buildTopBarItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    required TextStyle monoStyle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: monoStyle.copyWith(
                color: const Color(0xFF5C8A63),
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              value,
              style: monoStyle.copyWith(
                color: valueColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSideCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color(0xFF14241B),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0x2286E0C4), width: 1.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF5C8A63),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildSidePanel(TextStyle monoStyle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSideCard(
          icon: Icons.emoji_events,
          iconColor: const Color(0xFFFFD700),
          label: 'BEST SCORE',
          value: '${_controller.bestScore}',
          valueColor: const Color(0xFFFFD700),
        ),
        _buildSideCard(
          icon: Icons.bar_chart,
          iconColor: const Color(0xFF86E0C4),
          label: 'SCORE',
          value: '${_controller.score}',
          valueColor: const Color(0xFF86E0C4),
        ),
        _buildSideCard(
          icon: Icons.apple,
          iconColor: const Color(0xFFE6402F),
          label: 'FOOD EATEN',
          value: '${_controller.foodEaten}',
          valueColor: const Color(0xFFE6402F),
        ),
        _buildSideCard(
          icon: Icons.star,
          iconColor: const Color(0xFFFFD700),
          label: 'LEVEL',
          value: 'Level ${_controller.level}',
          valueColor: const Color(0xFF86E0C4),
        ),
        const SizedBox(height: 6),
        _buildPauseButton(monoStyle),
        const SizedBox(height: 6),
        _buildDpad(size: 50.0),
      ],
    );
  }

  Widget _buildHUD(
    TextStyle monoStyle, {
    required double cellSize,
    required bool isLandscape,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: SizedBox(
        width: min(
          MediaQuery.of(context).size.width * 0.9,
          _controller.cols * cellSize + 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHUDItem(
              'SCORE',
              '${_controller.score}',
              monoStyle,
              CrossAxisAlignment.start,
            ),
            _buildHUDItem(
              'BEST',
              '${_controller.bestScore}',
              monoStyle,
              CrossAxisAlignment.end,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUDItem(
    String label,
    String value,
    TextStyle monoStyle,
    CrossAxisAlignment crossAxisAlignment,
  ) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: monoStyle.copyWith(
            color: const Color(0xFF5C8A63),
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
        Text(
          value,
          style: monoStyle.copyWith(
            color: const Color(0xFFD4F7D4),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(color: Color(0x6678DC8C), blurRadius: 6)],
          ),
        ),
      ],
    );
  }

  Widget _buildPauseButton(TextStyle monoStyle) {
    final isPaused = _controller.isPaused;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: OutlinedButton.icon(
        onPressed: () {
          _controller.togglePause();
          _focusNode.requestFocus();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF14241B),
          side: const BorderSide(color: Color(0x3386E0C4), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        icon: Icon(
          isPaused ? Icons.play_arrow : Icons.pause,
          color: const Color(0xFF86E0C4),
          size: 16,
        ),
        label: Text(
          isPaused ? 'RESUME' : 'PAUSE',
          style: monoStyle.copyWith(
            color: const Color(0xFF86E0C4),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDpad({double size = 52.0}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: size),
            DpadButton(
              size: size,
              label: '▲',
              onTap: () => _controller.setDir(0, -1),
            ),
            SizedBox(width: size),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DpadButton(
              size: size,
              label: '◀',
              onTap: () => _controller.setDir(-1, 0),
            ),
            const SizedBox(width: 6),
            DpadButton(
              size: size,
              label: '▼',
              onTap: () => _controller.setDir(0, 1),
            ),
            const SizedBox(width: 6),
            DpadButton(
              size: size,
              label: '▶',
              onTap: () => _controller.setDir(1, 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHint(TextStyle monoStyle) {
    return Text(
      'arrow keys / WASD also work',
      textAlign: TextAlign.center,
      style: monoStyle.copyWith(
        color: const Color(0xFF4D7256),
        fontSize: 11,
        letterSpacing: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const monoStyle = TextStyle(
      fontFamily: 'Courier',
      fontFamilyFallback: ['monospace'],
    );

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    _controller.updateOrientation(isLandscape);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1912),
      body: SafeArea(
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableHeight;
              final double availableWidth;

              if (isLandscape) {
                availableHeight = constraints.maxHeight - 70.0;
                availableWidth = constraints.maxWidth * 0.7 - 40.0;
              } else {
                availableHeight = constraints.maxHeight - 310.0;
                availableWidth = constraints.maxWidth - 40.0;
              }

              final widthCellSize = availableWidth / _controller.cols;
              final heightCellSize = availableHeight / _controller.rows;
              final cellSize = min(
                26.0,
                min(widthCellSize, heightCellSize),
              ).clamp(12.0, 26.0);

              final gameBoard = Center(
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
                              _controller.cols * cellSize,
                              _controller.rows * cellSize,
                            ),
                            painter: SnakeBoardPainter(
                              snake: _controller.snake,
                              apples: _controller.apples,
                              obstacles: _controller.obstacles,
                              dir: _controller.dir,
                              cellSize: cellSize,
                              cols: _controller.cols,
                              rows: _controller.rows,
                            ),
                          ),
                        ),
                      ),

                      // Ready / Game Over / Paused Overlays
                      if (!_controller.isRunning || _controller.isPaused)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Container(
                              color: const Color(0xDC08140C),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _controller.isPaused
                                        ? 'PAUSED'
                                        : (_controller.isAlive
                                              ? 'READY?'
                                              : 'GAME OVER'),
                                    style: monoStyle.copyWith(
                                      color: _controller.isPaused
                                          ? const Color(0xFF86E0C4)
                                          : const Color(0xFFFF8A6B),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3,
                                      shadows: [
                                        Shadow(
                                          color: _controller.isPaused
                                              ? const Color(0x8086E0C4)
                                              : const Color(0x80FF785A),
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
                                      _controller.isPaused
                                          ? 'Tap resume or the button to continue'
                                          : (_controller.isAlive
                                                ? 'Use arrow keys, swipe, or the pad below'
                                                : 'Score: ${_controller.score}${_controller.score >= _controller.bestScore && _controller.score > 0 ? '  •  new best!' : ''}'),
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
                                      if (_controller.isPaused) {
                                        _controller.togglePause();
                                      } else {
                                        _controller.startGame();
                                      }
                                      _focusNode.requestFocus();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF86E0C4),
                                      foregroundColor: const Color(0xFF0D2318),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      _controller.isPaused
                                          ? 'RESUME'
                                          : (_controller.isAlive
                                                ? 'PLAY'
                                                : 'PLAY AGAIN'),
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
              );

              if (isLandscape) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Back Button + (Top Bar + Game Board)
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar row (Back Button + Stats Bar)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                _buildBackButton(),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTopBar(monoStyle)),
                              ],
                            ),
                          ),
                          // Game Board
                          Expanded(child: Center(child: gameBoard)),
                        ],
                      ),
                    ),

                    // Right Column: Side Panel
                    Expanded(flex: 3, child: _buildSidePanel(monoStyle)),
                  ],
                );
              } else {
                // Portrait Layout
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Portrait Top Row (Back Button + Title)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBackButton(),
                          Text(
                            'NEON SNAKE',
                            style: monoStyle.copyWith(
                              color: const Color(0xFF86E0C4),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 38), // Balance spacing
                        ],
                      ),
                    ),
                    _buildHUD(
                      monoStyle,
                      cellSize: cellSize,
                      isLandscape: false,
                    ),
                    const SizedBox(height: 12),
                    gameBoard,
                    const SizedBox(height: 12),
                    _buildPauseButton(monoStyle),
                    const SizedBox(height: 12),
                    _buildDpad(),
                    const SizedBox(height: 10),
                    _buildHint(monoStyle),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
