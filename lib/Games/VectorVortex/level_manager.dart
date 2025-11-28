import 'models.dart';
import 'models.dart';
import 'level_generator.dart';

class LevelManager {
  static Level generateLevel(int index) {
    int levelNum = index + 1;

    // Grid Cycle (5 levels): 4, 5, 6, 7, 8
    // Fill Cycle (30 levels): 0.5, 0.6, 0.7, 0.8, 0.9, 1.0
    // Tier Cycle (30 levels): Increases base grid size by 1

    const int gridCycleLength = 5;
    const int fillCycleLength = 30; // 6 steps of 0.1 from 0.5 to 1.0

    int tier = (levelNum - 1) ~/ fillCycleLength;
    int levelInFillCycle = (levelNum - 1) % fillCycleLength;

    // Fill Calculation
    // Changes every 5 levels (gridCycleLength)
    int fillStep = levelInFillCycle ~/ gridCycleLength;
    double fillPercentage = 0.5 + (fillStep * 0.1);
    if (fillPercentage > 1.0) fillPercentage = 1.0;

    // Grid Size Calculation
    int gridStep = levelInFillCycle % gridCycleLength;
    List<int> baseGridSizes = [4, 5, 6, 7, 8];
    int baseSize = baseGridSizes[gridStep];

    // Final Grid Size = Base + Tier
    int size = baseSize + tier;

    // Difficulty Label
    List<String> labels = ["Easy", "Normal", "Hard", "Insane", "Nightmare"];
    String label = labels[gridStep];

    return LevelGenerator.generateLevel(
      id: levelNum,
      rows: size,
      cols: size,
      fillPercentage: fillPercentage,
      difficultyLabel: label,
    );
  }
}
