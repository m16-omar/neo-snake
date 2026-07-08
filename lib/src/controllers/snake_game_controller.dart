import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/snake_game_model.dart';

class SnakeGameController extends ChangeNotifier {
  final SnakeGameModel _model = SnakeGameModel();
  Timer? _timer;

  static const String _bestScoreKey = 'snakeBestScore';

  SnakeGameController() {
    _loadBestScore();
    reset();
  }

  // Getters to expose model state to View
  List<Point<int>> get snake => _model.snake;
  Point<int> get dir => _model.dir;
  Point<int> get apple => _model.apple;
  int get score => _model.score;
  int get bestScore => _model.bestScore;
  bool get isRunning => _model.isRunning;
  bool get isAlive => _model.isAlive;
  bool get isPaused => _model.isPaused;
  int get tickMs => _model.tickMs;
  int get cols => _model.cols;
  int get rows => _model.rows;

  @override
  void dispose() {
    _timer?.cancel();
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
    _model.tickMs = 130;
    _model.isAlive = true;
    _model.isRunning = false;
    _model.isPaused = false;
    placeApple();
    notifyListeners();
  }

  void placeApple() {
    final rand = Random();
    bool valid = false;
    while (!valid) {
      _model.apple = Point(
        rand.nextInt(_model.cols),
        rand.nextInt(_model.rows),
      );
      valid = !_model.snake.any((segment) => segment == _model.apple);
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
    }
    notifyListeners();
  }

  void startGame() {
    reset();
    _model.isRunning = true;
    notifyListeners();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _model.tickMs),
      (t) => _loop(),
    );
  }

  void _loop() {
    step();
    notifyListeners();
  }

  void step() {
    if (!_model.isAlive || _model.isPaused) return;

    _model.dir = _model.nextDir;
    final head = _model.snake.first;
    final newHead = Point(head.x + _model.dir.x, head.y + _model.dir.y);

    // Wall collision
    if (newHead.x < 0 ||
        newHead.x >= _model.cols ||
        newHead.y < 0 ||
        newHead.y >= _model.rows) {
      _gameOver();
      return;
    }

    // Self collision
    if (_model.snake.any((segment) => segment == newHead)) {
      _gameOver();
      return;
    }

    _model.snake.insert(0, newHead);

    // Eating apple
    if (newHead == _model.apple) {
      _model.score += 10;
      placeApple();
      // Speed up
      _model.tickMs = max(70, _model.tickMs - 2);
      _startTimer(); // Restart timer with new tick rate
    } else {
      _model.snake.removeLast();
    }
  }

  void _gameOver() {
    _model.isAlive = false;
    _model.isRunning = false;
    _model.isPaused = false;
    _timer?.cancel();
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
