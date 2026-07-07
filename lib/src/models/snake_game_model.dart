import 'dart:math';

class SnakeGameModel {
  static const int cols = 15;
  static const int rows = 20;

  List<Point<int>> snake = [];
  Point<int> dir = const Point(1, 0);
  Point<int> nextDir = const Point(1, 0);
  Point<int> apple = const Point(0, 0);

  int score = 0;
  int bestScore = 0;
  bool isRunning = false;
  bool isAlive = false;
  int tickMs = 130;
}
