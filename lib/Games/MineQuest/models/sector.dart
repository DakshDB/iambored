import 'dart:math';
import 'cell.dart';

class Sector {
  static const int gridSize = 8;
  static const int mineCount = 8;
  static const double gemProbability = 0.10; // 15% of safe cells

  List<List<Cell>> grid;
  int sectorX;
  int sectorY;
  bool isCompleted;

  Sector({
    required this.sectorX,
    required this.sectorY,
    this.isCompleted = false,
  }) : grid = List.generate(
          gridSize,
          (i) => List.generate(gridSize, (j) => Cell()),
        );

  // Generate mines and gems for the sector
  void generate({int? safeRow, int? safeCol}) {
    _placeMines(safeRow: safeRow, safeCol: safeCol);
    _placeGems();
    _calculateAdjacentMines();
  }

  // Place mines randomly, avoiding the safe cell
  void _placeMines({int? safeRow, int? safeCol}) {
    final random = Random();
    int minesPlaced = 0;

    while (minesPlaced < mineCount) {
      int row = random.nextInt(gridSize);
      int col = random.nextInt(gridSize);

      // Avoid the safe cell and already placed mines
      if ((safeRow != null &&
              safeCol != null &&
              row == safeRow &&
              col == safeCol) ||
          grid[row][col].isMine) {
        continue;
      }

      grid[row][col].isMine = true;
      minesPlaced++;
    }
  }

  // Place gems on safe cells
  void _placeGems() {
    final random = Random();

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        // Only place gems on non-mine cells
        if (!grid[row][col].isMine && random.nextDouble() < gemProbability) {
          grid[row][col].isGem = true;
        }
      }
    }
  }

  // Calculate adjacent mine count for each cell
  void _calculateAdjacentMines() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (!grid[row][col].isMine) {
          grid[row][col].adjacentMines = _countAdjacentMines(row, col);
        }
      }
    }
  }

  // Count mines in adjacent cells
  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue;

        int newRow = row + i;
        int newCol = col + j;

        if (newRow >= 0 &&
            newRow < gridSize &&
            newCol >= 0 &&
            newCol < gridSize &&
            grid[newRow][newCol].isMine) {
          count++;
        }
      }
    }
    return count;
  }

  // Check if sector is completed (all non-mine cells revealed)
  bool checkCompletion() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        // If there's a non-mine cell that's not revealed, sector is not complete
        if (!grid[row][col].isMine && !grid[row][col].isRevealed) {
          return false;
        }
      }
    }
    isCompleted = true;
    return true;
  }

  // Count revealed cells
  int getRevealedCellsCount() {
    int count = 0;
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col].isRevealed) {
          count++;
        }
      }
    }
    return count;
  }

  // Count collected gems
  int getCollectedGemsCount() {
    int count = 0;
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col].isGem && grid[row][col].isRevealed) {
          count++;
        }
      }
    }
    return count;
  }

  // Reset the sector
  void reset() {
    grid = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) => Cell()),
    );
    isCompleted = false;
  }
}
