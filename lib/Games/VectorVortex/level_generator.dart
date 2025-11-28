import 'dart:math';
import 'models.dart';

class LevelGenerator {
  static Level generateLevel({
    required int id,
    required int rows,
    required int cols,
    required String difficultyLabel,
    double fillPercentage = 0.7, // Target density
  }) {
    final random = Random();
    List<Arrow> placedArrows = [];
    Set<String> occupiedCells = {}; // "row,col" strings

    // Maximum attempts to fill the grid
    int maxArrows = (rows * cols * fillPercentage).floor();
    int attempts = 0;
    int maxAttempts = rows * cols * 5; // Heuristic limit

    while (placedArrows.length < maxArrows && attempts < maxAttempts) {
      attempts++;

      // 1. Find all valid candidates
      // A candidate is a (row, col, direction) such that:
      // - The cell is empty.
      // - The path to the edge in that direction is NOT blocked by any EXISTING arrow.
      //   (Note: In reverse logic, "existing" arrows are the ones that exit LATER.
      //    So the new arrow must be able to exit BEFORE them, meaning its path must be clear of them.)

      List<Arrow> candidates = [];

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (occupiedCells.contains("$r,$c")) continue;

          for (var dir in ArrowDirection.values) {
            if (_isPathClear(r, c, dir, rows, cols, placedArrows)) {
              candidates.add(Arrow(
                id: "${r}_${c}", // Temporary ID
                direction: dir,
                row: r,
                col: c,
              ));
            }
          }
        }
      }

      if (candidates.isEmpty) {
        // Cannot place any more arrows that can exit.
        // We might be done or stuck.
        break;
      }

      // 2. Pick a random candidate
      // Heuristic: Prefer candidates that are "blocked" by the edge rather than other arrows?
      // No, actually we want to create complexity.
      // Random is fine for now.
      Arrow chosen = candidates[random.nextInt(candidates.length)];

      // 3. Place it
      placedArrows.add(chosen);
      occupiedCells.add("${chosen.row},${chosen.col}");
    }

    // Assign proper IDs
    for (int i = 0; i < placedArrows.length; i++) {
      // We need to re-create the arrow because 'id' is final and we want simple numeric IDs
      // Actually, let's just keep the coordinate ID or assign a new one.
      // The game logic uses ID for collision check (ignore self).
      // Let's make sure IDs are unique.
    }

    return Level(
      id: id,
      rows: rows,
      cols: cols,
      arrows: placedArrows,
      difficultyLabel: difficultyLabel,
    );
  }

  static bool _isPathClear(
    int r,
    int c,
    ArrowDirection dir,
    int rows,
    int cols,
    List<Arrow> obstacles,
  ) {
    int currR = r;
    int currC = c;

    while (true) {
      // Move one step
      switch (dir) {
        case ArrowDirection.up:
          currR--;
          break;
        case ArrowDirection.down:
          currR++;
          break;
        case ArrowDirection.left:
          currC--;
          break;
        case ArrowDirection.right:
          currC++;
          break;
      }

      // Check bounds (Exit condition)
      if (currR < 0 || currR >= rows || currC < 0 || currC >= cols) {
        return true; // Path is clear to edge
      }

      // Check collision with obstacles
      for (var obstacle in obstacles) {
        if (obstacle.row == currR && obstacle.col == currC) {
          return false; // Blocked
        }
      }
    }
  }
}
