import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/snake_game_model.dart';
import '../services/audio_service.dart';

class SnakeGameController extends ChangeNotifier {
  final SnakeGameModel _model = SnakeGameModel();
  Timer? _timer;
  Timer? _timeTrackerTimer;

  static const String _bestScoreKey = 'snakeBestScore';

  /// NUMBER OF APPLES THAT MUST BE EATEN TO COMPLETE A LEVEL.
  static const int applesPerLevel = 20;

  SnakeGameController() {
    _loadBestScore();
    reset();
  }

  // ── GETTERS ─────────────────────────────────────────────────────────────────
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

  // ── PERSISTENCE ─────────────────────────────────────────────────────────────
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
      debugPrint('Error loading best score: $e');
    }
  }

  Future<void> _saveBestScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bestScoreKey, _model.bestScore);
    } catch (e) {
      debugPrint('Error saving best score: $e');
    }
  }

  // ── SPEED CURVE ─────────────────────────────────────────────────────────────
  // LEVEL 1 → 600 MS (VERY SLOW, NEWCOMER-FRIENDLY)
  // LEVEL 5 → ~528 MS (STILL COMFORTABLE)
  // LEVEL 10 → ~438 MS
  // LEVEL 20 → ~258 MS (CHALLENGING)
  // LEVEL 30 → 80 MS (EXPERT)
  int _tickMsForLevel(int lvl) {
    return max(80, 600 - (lvl - 1) * 18);
  }

  // ── GAME LIFECYCLE ───────────────────────────────────────────────────────────
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
    _model.tickMs = _tickMsForLevel(1); // 600 MS
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
    // VERTICAL WALL TOP CENTER
    int midX = _model.cols ~/ 2;
    _model.obstacles.add(Point(midX, 2));
    _model.obstacles.add(Point(midX, 3));

    // HORIZONTAL WALL LOWER LEFT
    _model.obstacles.add(Point(2, _model.rows - 5));
    _model.obstacles.add(Point(3, _model.rows - 5));
    _model.obstacles.add(Point(4, _model.rows - 5));

    // SQUARE WALL MID RIGHT
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

  /// RESTART FROM THE LEVEL THE PLAYER WAS ON WHEN THEY DIED.
  /// SCORE RESETS BUT LEVEL + SPEED ARE PRESERVED.
  void restartAtCurrentLevel() {
    final savedLevel = _model.currentLevel;
    reset(); // RESETS EVERYTHING TO LEVEL 1
    // RESTORE LEVEL AND MATCHING SPEED
    _model.currentLevel = savedLevel;
    _model.tickMs = _tickMsForLevel(savedLevel);
    _model.isRunning = true;
    notifyListeners();
    _startTimer();
  }

  /// CALLED FROM THE UI WHEN THE PLAYER TAPS "NEXT LEVEL" IN THE POPUP.
  void advanceLevel() {
    _model.isLevelComplete = false;
    _model.currentLevel++;
    _model.foodEatenThisLevel = 0;
    _model.tickMs = _tickMsForLevel(_model.currentLevel);
    _model.isRunning = true;
    notifyListeners();
    _startTimer();
  }

  // ── TIMER ────────────────────────────────────────────────────────────────────
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

  // ── GAME STEP ────────────────────────────────────────────────────────────────
  void step() {
    if (!_model.isAlive || _model.isPaused || _model.isLevelComplete) return;

    _model.dir = _model.nextDir;
    final head = _model.snake.first;
    final newHead = Point(head.x + _model.dir.x, head.y + _model.dir.y);

    // WALL WRAP-AROUND
    final wrappedHead = Point(
      (newHead.x + _model.cols) % _model.cols,
      (newHead.y + _model.rows) % _model.rows,
    );

    // OBSTACLE COLLISION
    if (_model.obstacles.any((obs) => obs == wrappedHead)) {
      _gameOver();
      return;
    }

    // SELF COLLISION
    if (_model.snake.any((segment) => segment == wrappedHead)) {
      _gameOver();
      return;
    }

    _model.snake.insert(0, wrappedHead);

    // EATING APPLE
    if (_model.apples.contains(wrappedHead)) {
      _model.score += 10;
      _model.foodEaten += 1;
      _model.foodEatenThisLevel += 1;
      _model.apples.remove(wrappedHead);
      placeApples();

      // CHECK LEVEL COMPLETION (20 APPLES = LEVEL COMPLETE)
      if (_model.foodEatenThisLevel >= applesPerLevel) {
        _model.isLevelComplete = true;
        _timer?.cancel();
        _timeTrackerTimer?.cancel();
        if (_model.score > _model.bestScore) {
          _model.bestScore = _model.score;
          _saveBestScore();
        }
        // PLAY LEVEL UP SOUND
        AudioService.instance.playLevelUp();
      } else {
        // PLAY SIMPLE APPLE PICK SOUND
        AudioService.instance.playApple();
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
    // PLAY GAME OVER SOUND
    AudioService.instance.playGameOver();
  }

  void setDir(int x, int y) {
    if (!_model.isAlive || !_model.isRunning || _model.isPaused) return;
    // PREVENT 180 DEGREE TURNS
    if (_model.dir.x == -x && _model.dir.y == -y) return;
    if (_model.dir.x == x && _model.dir.y == y) return;
    _model.nextDir = Point(x, y);
  }
}
