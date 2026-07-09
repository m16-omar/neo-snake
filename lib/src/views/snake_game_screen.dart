// IGNORE_FOR_FILE: DEPRECATED_MEMBER_USE
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
    // RE-RENDER WHEN THE CONTROLLER STATE CHANGES
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

  // KEYBOARD EVENT HANDLER
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

  // TOUCH GESTURE SWIPING HANDLER
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
        _dragStart = current; // RESET TO ALLOW CHAIN-SWIPING
      }
    } else {
      if (dy.abs() > swipeThreshold) {
        _controller.setDir(0, dy > 0 ? 1 : -1);
        _dragStart = current; // RESET TO ALLOW CHAIN-SWIPING
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
          // LENGTH
          _buildTopBarItem(
            icon: Icons.gesture,
            iconColor: const Color(0xFF8BC34A),
            label: 'LENGTH',
            value: '${_controller.snake.length}',
            valueColor: const Color(0xFF8BC34A),
            monoStyle: monoStyle,
          ),
          _buildVerticalDivider(),
          // FOOD EATEN
          _buildTopBarItem(
            icon: Icons.apple,
            iconColor: const Color(0xFFE6402F),
            label: 'FOOD EATEN',
            value: '${_controller.foodEaten}',
            valueColor: const Color(0xFFE6402F),
            monoStyle: monoStyle,
          ),
          _buildVerticalDivider(),
          // TIME
          _buildTopBarItem(
            icon: Icons.access_time,
            iconColor: const Color(0xFF00BCD4),
            label: 'TIME',
            value: _formatTime(_controller.timeElapsedSec),
            valueColor: const Color(0xFF00BCD4),
            monoStyle: monoStyle,
          ),
          _buildVerticalDivider(),
          // BEST
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
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return Container(height: isTablet ? 28 : 20, width: 1, color: const Color(0x1A86E0C4));
  }

  Widget _buildTopBarItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    required TextStyle monoStyle,
  }) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: isTablet ? 20 : 16),
        SizedBox(width: isTablet ? 10 : 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: monoStyle.copyWith(
                color: const Color(0xFF5C8A63),
                fontSize: isTablet ? 11 : 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              value,
              style: monoStyle.copyWith(
                color: valueColor,
                fontSize: isTablet ? 16 : 12,
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
    bool compact = false,
  }) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final useCompact = compact && !isTablet;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 16.0 : 12.0,
        vertical: useCompact ? 1.5 : (isTablet ? 4.0 : 2.0),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 14.0 : 10.0,
        vertical: useCompact ? 3.0 : (isTablet ? 8.0 : 5.0),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF14241B),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0x2286E0C4), width: 1.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: useCompact ? 16 : (isTablet ? 24 : 20)),
          SizedBox(width: useCompact ? 8 : (isTablet ? 12 : 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF5C8A63),
                    fontSize: useCompact ? 8 : (isTablet ? 11 : 9),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: useCompact ? 12 : (isTablet ? 18 : 15),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
        // FIXED UI ABOVE THE D-PAD: 4 CARDS + PAUSE BUTTON + SPACERS
        // MEASURED ACTUAL ≈ 195PX, ADD HEADROOM TO PREVENT OVERFLOW
        final double fixedHeight = isTablet ? 300.0 : 220.0;
        final double remainingHeight =
            (constraints.maxHeight - fixedHeight).clamp(40.0, 220.0);
        // D-PAD CIRCLE DIAMETER = DPADSIZE × 3.4 — CAP TO AVOID OVERFLOW
        final double dpadSize = (remainingHeight / 3.4).clamp(22.0, isTablet ? 64.0 : 52.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSideCard(
              icon: Icons.emoji_events,
              iconColor: const Color(0xFFFFD700),
              label: 'BEST SCORE',
              value: '${_controller.bestScore}',
              valueColor: const Color(0xFFFFD700),
              compact: true,
            ),
            _buildSideCard(
              icon: Icons.bar_chart,
              iconColor: const Color(0xFF86E0C4),
              label: 'SCORE',
              value: '${_controller.score}',
              valueColor: const Color(0xFF86E0C4),
              compact: true,
            ),
            _buildSideCard(
              icon: Icons.apple,
              iconColor: const Color(0xFFE6402F),
              label: 'FOOD EATEN',
              value: '${_controller.foodEaten}',
              valueColor: const Color(0xFFE6402F),
              compact: true,
            ),
            _buildSideCard(
              icon: Icons.star,
              iconColor: const Color(0xFFFFD700),
              label: 'LEVEL',
              value: 'Level ${_controller.level}',
              valueColor: const Color(0xFF86E0C4),
              compact: true,
            ),
            const SizedBox(height: 6),
            _buildPauseButton(monoStyle, compact: true),
            const SizedBox(height: 6),
            // D-PAD GROWS TO FILL REMAINING SPACE
            _buildDpad(size: dpadSize),
          ],
        );
      },
    );
  }


  Widget _buildPauseButton(TextStyle monoStyle, {bool compact = false}) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final useCompact = compact && !isTablet;
    final isPaused = _controller.isPaused;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: useCompact ? 12.0 : (isTablet ? 16.0 : 16.0)),
      child: OutlinedButton.icon(
        onPressed: () {
          _controller.togglePause();
          _focusNode.requestFocus();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF14241B),
          side: const BorderSide(color: Color(0x3386E0C4), width: 1.5),
          padding: EdgeInsets.symmetric(vertical: useCompact ? 5.0 : (isTablet ? 14.0 : 10.0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        icon: Icon(
          isPaused ? Icons.play_arrow : Icons.pause,
          color: const Color(0xFF86E0C4),
          size: useCompact ? 14 : (isTablet ? 20 : 16),
        ),
        label: Text(
          isPaused ? 'RESUME' : 'PAUSE',
          style: monoStyle.copyWith(
            color: const Color(0xFF86E0C4),
            fontSize: useCompact ? 11 : (isTablet ? 15 : 13),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDpad({double size = 38.0}) {
    final double padSize = size * 3.4;
    final double centerOffset = (padSize - size) / 2;
    return Container(
      width: padSize,
      height: padSize,
      decoration: BoxDecoration(
        color: const Color(0xFF0F261B),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x3386E0C4), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // UP
          Positioned(
            top: 2,
            left: centerOffset,
            child: DpadButton(
              size: size,
              label: '▲',
              onTap: () => _controller.setDir(0, -1),
            ),
          ),
          // LEFT
          Positioned(
            left: 2,
            top: centerOffset,
            child: DpadButton(
              size: size,
              label: '◀',
              onTap: () => _controller.setDir(-1, 0),
            ),
          ),
          // DOWN
          Positioned(
            bottom: 2,
            left: centerOffset,
            child: DpadButton(
              size: size,
              label: '▼',
              onTap: () => _controller.setDir(0, 1),
            ),
          ),
          // RIGHT
          Positioned(
            right: 2,
            top: centerOffset,
            child: DpadButton(
              size: size,
              label: '▶',
              onTap: () => _controller.setDir(1, 0),
            ),
          ),
          // CENTER CAP DECORATION
          Center(
            child: Container(
              width: size * 0.5,
              height: size * 0.5,
              decoration: const BoxDecoration(
                color: Color(0xFF0D1912),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
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
              final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

              if (isLandscape) {
                availableHeight = constraints.maxHeight - 70.0;
                // USE ~72% OF TOTAL WIDTH (LEFT FLEX=7 OF 10) MINUS SMALL PADDING
                availableWidth = constraints.maxWidth * 0.72 - 24.0;
              } else {
                availableHeight = constraints.maxHeight - (isTablet ? 420.0 : 310.0);
                availableWidth = constraints.maxWidth - (isTablet ? 80.0 : 56.0); // 40 BASE + 2×8 BOARD MARGIN
              }

              final widthCellSize = availableWidth / _controller.cols;
              final heightCellSize = availableHeight / _controller.rows;
              final double maxCell = isLandscape 
                  ? (isTablet ? 45.0 : 26.0) 
                  : (isTablet ? 55.0 : 30.0);
              final cellSize = min(
                maxCell,
                min(widthCellSize, heightCellSize),
              ).clamp(12.0, maxCell);

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
                              level: _controller.level,
                            ),
                          ),
                        ),
                      ),

                      // READY / GAME OVER / PAUSED OVERLAYS
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
                                      } else if (_controller.isAlive) {
                                        // PLAY — FRESH START FROM LEVEL 1
                                        _controller.startGame();
                                      } else {
                                        // PLAY AGAIN — RESTART AT THE LEVEL THEY DIED ON
                                        _controller.restartAtCurrentLevel();
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

                      // ── LEVEL-COMPLETE POPUP ─────────────────────────────
                      if (_controller.isLevelComplete)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Container(
                              color: const Color(0xE0071810),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '🏆',
                                    style: TextStyle(fontSize: 42),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'LEVEL COMPLETE!',
                                    style: monoStyle.copyWith(
                                      color: const Color(0xFFFFD700),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x80FFD700),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'You ate 20 apples! 🍎×20',
                                    style: monoStyle.copyWith(
                                      color: const Color(0xFF8FC99A),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF14241B),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF86E0C4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Level ${_controller.level}  →  Level ${_controller.level + 1}',
                                      style: monoStyle.copyWith(
                                        color: const Color(0xFF86E0C4),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  ElevatedButton(
                                    onPressed: () {
                                      _controller.advanceLevel();
                                      _focusNode.requestFocus();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFD700),
                                      foregroundColor: const Color(0xFF0D1912),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                    ),
                                    child: Text(
                                      'NEXT LEVEL →',
                                      style: monoStyle.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
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
                    // LEFT COLUMN: BACK BUTTON + (TOP BAR + GAME BOARD)
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TOP BAR ROW (BACK BUTTON + STATS BAR)
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
                          // GAME BOARD
                          Expanded(child: Center(child: gameBoard)),
                        ],
                      ),
                    ),

                    // RIGHT COLUMN: SIDE PANEL
                    Expanded(flex: 3, child: _buildSidePanel(monoStyle)),
                  ],
                );
              } else {
                // PORTRAIT LAYOUT
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // ── ULTRA-COMPACT SINGLE-ROW HEADER ────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24.0 : 12.0,
                        vertical: isTablet ? 12.0 : 4.0,
                      ),
                      child: Row(
                        children: [
                          // BACK BUTTON (LEFT ANCHOR)
                          _buildBackButton(),
                          // STATS CENTRED IN REMAINING SPACE
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTopBarItem(
                                  icon: Icons.bar_chart,
                                  iconColor: const Color(0xFF86E0C4),
                                  label: 'SCORE',
                                  value: '${_controller.score}',
                                  valueColor: const Color(0xFF86E0C4),
                                  monoStyle: monoStyle,
                                ),
                                SizedBox(width: isTablet ? 16 : 6),
                                _buildVerticalDivider(),
                                SizedBox(width: isTablet ? 16 : 6),
                                _buildTopBarItem(
                                  icon: Icons.apple,
                                  iconColor: const Color(0xFFE6402F),
                                  label: 'FOOD',
                                  value: '${_controller.foodEaten}',
                                  valueColor: const Color(0xFFE6402F),
                                  monoStyle: monoStyle,
                                ),
                                SizedBox(width: isTablet ? 16 : 6),
                                _buildVerticalDivider(),
                                SizedBox(width: isTablet ? 16 : 6),
                                _buildTopBarItem(
                                  icon: Icons.star,
                                  iconColor: const Color(0xFFFFD700),
                                  label: 'LVL',
                                  value: '${_controller.level}',
                                  valueColor: const Color(0xFFFFD700),
                                  monoStyle: monoStyle,
                                ),
                                SizedBox(width: isTablet ? 16 : 6),
                                _buildVerticalDivider(),
                                SizedBox(width: isTablet ? 16 : 6),
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
                          ),
                          // BALANCING SPACER = BACK BUTTON WIDTH
                          const SizedBox(width: 38),
                        ],
                      ),
                    ),
                    // ── GAME BOARD ─────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 8.0),
                      child: gameBoard,
                    ),
                    SizedBox(height: isTablet ? 18 : 6),
                    // ── PAUSE BUTTON ─────────────────────────────────────
                    Center(
                      child: SizedBox(
                        width: isTablet ? 240 : 160,
                        child: _buildPauseButton(monoStyle, compact: true),
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 6),
                    // ── D-PAD ────────────────────────────────────────────
                    _buildDpad(size: isTablet ? 64.0 : 46.0),
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
