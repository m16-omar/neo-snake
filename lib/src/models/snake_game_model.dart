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
  int foodEatenThisLevel = 0; // RESETS EVERY LEVEL
  int currentLevel = 1;       // EXPLICIT LEVEL (NOT DERIVED)
  bool isLevelComplete = false; // TRUE WHEN 20 APPLES EATEN IN THIS LEVEL
  int timeElapsedSec = 0;
  bool isRunning = false;
  bool isAlive = false;
  bool isPaused = false;
  int tickMs = 600;
}
