import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/snake_game_model.dart';

class SnakeGameController extends ChangeNotifier {
  final SnakeGameModel _model = SnakeGameModel();
  Timer? _timer;
  Timer? _timeTrackerTimer;

  static const String _bestScoreKey = 'snakeBestScore';

  /// Number of apples that must be eaten to complete a level.
  static const int applesPerLevel = 20;

  SnakeGameController() {
    _loadBestScore();
    reset();
  }

  // ── Getters ─────────────────────────────────────────────────────────────────
  List<Point<int>> get snake => _model.snake;
  Point<int> get dir => _model.dir;
  List<Point<int>> get apples => _model.apples;
  List<Point<int>> get obstacles => _model.obstacles;
  int get score => _model.score;
  int get bestScore => _model.bestScore;
  int get foodEaten => _model.foodEaten;
  int get foodEatenThisLevel => _model.foodEatenThisLevel;
  int get timeElapsedSec => _model.timeElapsedSec;
  int get level => _model.currentLevel;
  bool get isRunning => _model.isRunning;
  bool get isAlive => _model.isAlive;
  bool get isPaused => _model.isPaused;
  bool get isLevelComplete => _model.isLevelComplete;
  int get tickMs => _model.tickMs;
  int get cols => _model.cols;
  int get rows => _model.rows;

  // ── Persistence ─────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _timer?.cancel();
    _timeTrackerTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBestScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _model.bestScore = prefs.getInt(_bestScoreKey) ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading best score: \$e');
    }
  }

  Future<void> _saveBestScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bestScoreKey, _model.bestScore);
    } catch (e) {
      debugPrint('Error saving best score: \$e');
    }
  }

  // ── Speed curve ─────────────────────────────────────────────────────────────
  // Level 1 → 600 ms (very slow, newcomer-friendly)
  // Level 5 → ~528 ms (still comfortable)
  // Level 10 → ~438 ms
  // Level 20 → ~258 ms (challenging)
  // Level 30 → 80 ms (expert)
  int _tickMsForLevel(int lvl) {
    return max(80, 600 - (lvl - 1) * 18);
  }

  // ── Game lifecycle ───────────────────────────────────────────────────────────
  void reset() {
    final startX = _model.cols ~/ 2;
    final startY = _model.rows ~/ 2;
    _model.snake = [
      Point(startX, startY),
      Point(startX - 1, startY),
      Point(startX - 2, startY),
    ];
    _model.dir = const Point(1, 0);
    _model.nextDir = const Point(1, 0);
    _model.score = 0;
    _model.foodEaten = 0;
    _model.foodEatenThisLevel = 0;
    _model.currentLevel = 1;
    _model.isLevelComplete = false;
    _model.timeElapsedSec = 0;
    _model.tickMs = _tickMsForLevel(1); // 600 ms
    _model.isAlive = true;
    _model.isRunning = false;
    _model.isPaused = false;
    _model.apples.clear();
    generateObstacles();
    placeApples();
    notifyListeners();
  }

  void generateObstacles() {
    _model.obstacles.clear();
    // Vertical wall top center
    int midX = _model.cols ~/ 2;
    _model.obstacles.add(Point(midX, 2));
    _model.obstacles.add(Point(midX, 3));

    // Horizontal wall lower left
    _model.obstacles.add(Point(2, _model.rows - 5));
    _model.obstacles.add(Point(3, _model.rows - 5));
    _model.obstacles.add(Point(4, _model.rows - 5));

    // Square wall mid right
    _model.obstacles.add(Point(_model.cols - 4, _model.rows ~/ 2));
    _model.obstacles.add(Point(_model.cols - 3, _model.rows ~/ 2));
    _model.obstacles.add(Point(_model.cols - 4, _model.rows ~/ 2 + 1));
    _model.obstacles.add(Point(_model.cols - 3, _model.rows ~/ 2 + 1));
  }

  void placeApples() {
    final rand = Random();
    while (_model.apples.length < 3) {
      Point<int> newApple;
      bool valid = false;
      int attempts = 0;
      while (!valid && attempts < 100) {
        newApple = Point(
          rand.nextInt(_model.cols),
          rand.nextInt(_model.rows),
        );
        valid = !_model.snake.any((segment) => segment == newApple) &&
            !_model.obstacles.any((obs) => obs == newApple) &&
            !_model.apples.any((a) => a == newApple);
        if (valid) {
          _model.apples.add(newApple);
        }
        attempts++;
      }
    }
  }

  void updateOrientation(bool isLandscape) {
    final newCols = isLandscape ? 20 : 15;
    final newRows = isLandscape ? 15 : 20;
    if (_model.cols != newCols || _model.rows != newRows) {
      _model.cols = newCols;
      _model.rows = newRows;
      reset();
    }
  }

  void togglePause() {
    if (!_model.isAlive || !_model.isRunning) return;
    if (_model.isPaused) {
      _model.isPaused = false;
      _startTimer();
    } else {
      _model.isPaused = true;
      _timer?.cancel();
      _timeTrackerTimer?.cancel();
    }
    notifyListeners();
  }

  void startGame() {
    reset();
    _model.isRunning = true;
    notifyListeners();
    _startTimer();
  }

  /// Called from the UI when the player taps "NEXT LEVEL" in the popup.
  void advanceLevel() {
    _model.isLevelComplete = false;
    _model.currentLevel++;
    _model.foodEatenThisLevel = 0;
    _model.tickMs = _tickMsForLevel(_model.currentLevel);
    _model.isRunning = true;
    notifyListeners();
    _startTimer();
  }

  // ── Timer ────────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _model.tickMs),
      (t) => _loop(),
    );

    _timeTrackerTimer?.cancel();
    _timeTrackerTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_model.isRunning && !_model.isPaused && _model.isAlive) {
        _model.timeElapsedSec++;
        notifyListeners();
      }
    });
  }

  void _loop() {
    step();
    notifyListeners();
  }

  // ── Game step ────────────────────────────────────────────────────────────────
  void step() {
    if (!_model.isAlive || _model.isPaused || _model.isLevelComplete) return;

    _model.dir = _model.nextDir;
    final head = _model.snake.first;
    final newHead = Point(head.x + _model.dir.x, head.y + _model.dir.y);

    // Wall wrap-around
    final wrappedHead = Point(
      (newHead.x + _model.cols) % _model.cols,
      (newHead.y + _model.rows) % _model.rows,
    );

    // Obstacle collision
    if (_model.obstacles.any((obs) => obs == wrappedHead)) {
      _gameOver();
      return;
    }

    // Self collision
    if (_model.snake.any((segment) => segment == wrappedHead)) {
      _gameOver();
      return;
    }

    _model.snake.insert(0, wrappedHead);

    // Eating apple
    if (_model.apples.contains(wrappedHead)) {
      _model.score += 10;
      _model.foodEaten += 1;
      _model.foodEatenThisLevel += 1;
      _model.apples.remove(wrappedHead);
      placeApples();

      // Check level completion (20 apples = level complete)
      if (_model.foodEatenThisLevel >= applesPerLevel) {
        _model.isLevelComplete = true;
        _timer?.cancel();
        _timeTrackerTimer?.cancel();
        if (_model.score > _model.bestScore) {
          _model.bestScore = _model.score;
          _saveBestScore();
        }
      }
    } else {
      _model.snake.removeLast();
    }
  }

  void _gameOver() {
    _model.isAlive = false;
    _model.isRunning = false;
    _model.isPaused = false;
    _timer?.cancel();
    _timeTrackerTimer?.cancel();
    if (_model.score > _model.bestScore) {
      _model.bestScore = _model.score;
      _saveBestScore();
    }
  }

  void setDir(int x, int y) {
    if (!_model.isAlive || !_model.isRunning || _model.isPaused) return;
    // Prevent 180 degree turns
    if (_model.dir.x == -x && _model.dir.y == -y) return;
    if (_model.dir.x == x && _model.dir.y == y) return;
    _model.nextDir = Point(x, y);
  }
}
