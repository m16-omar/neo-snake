import 'dart:math';

class SnakeGameModel {
  int cols = 15;
  int rows = 20;

  List<Point<int>> snake = [];
  Point<int> dir = const Point(1, 0);
  Point<int> nextDir = const Point(1, 0);
  List<Point<int>> apples = [];
  List<Point<int>> obstacles = [];

  int score = 0;
  int bestScore = 0;
  int foodEaten = 0;
  int timeElapsedSec = 0;
  String speedMode = 'Medium';
  bool isRunning = false;
  bool isAlive = false;
  bool isPaused = false;
  int tickMs = 130;
}
