import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';
import 'board.dart';
import 'models/sector.dart';

class MineQuest extends StatefulWidget {
  const MineQuest({super.key});

  @override
  State<MineQuest> createState() => _MineQuestState();
}

class _MineQuestState extends State<MineQuest> {
  late Sector currentSector;

  // Game state
  bool isTimedMode = false;
  bool gameStarted = false;
  bool gameOver = false;
  bool firstClick = true;

  // Score tracking
  int totalScore = 0;
  int sectorsCompleted = 0;
  int gemsCollected = 0;

  // Timer for timed mode
  Timer? gameTimer;
  int remainingSeconds = 60;
  static const int timerDuration = 60;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    currentSector = Sector(sectorX: 0, sectorY: 0);
    // Don't generate the sector yet, wait for first click
    setState(() {
      gameStarted = false;
      gameOver = false;
      firstClick = true;
      totalScore = 0;
      sectorsCompleted = 0;
      gemsCollected = 0;
      remainingSeconds = timerDuration;
    });
    gameTimer?.cancel();
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
    });

    if (isTimedMode) {
      _startTimer();
    }
  }

  void _startTimer() {
    gameTimer?.cancel();
    setState(() {
      remainingSeconds = timerDuration;
    });

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          _handleGameOver(false);
        }
      });
    });
  }

  void _handleCellTap(int row, int col) {
    if (gameOver ||
        currentSector.grid[row][col].isRevealed ||
        currentSector.grid[row][col].isFlagged) {
      return;
    }

    // First click - generate sector avoiding this cell
    if (firstClick) {
      currentSector.generate(safeRow: row, safeCol: col);
      setState(() {
        firstClick = false;
      });
      _startGame();
    }

    final cell = currentSector.grid[row][col];

    // Reveal the cell
    setState(() {
      cell.isRevealed = true;
    });

    // Check if mine was clicked
    if (cell.isMine) {
      _handleGameOver(true);
      return;
    }

    // Add score for revealed cell
    _addScore(10);

    // Check if gem was collected
    if (cell.isGem) {
      setState(() {
        gemsCollected++;
      });
      _addScore(50);
    }

    // If cell has no adjacent mines, reveal surrounding cells
    if (cell.adjacentMines == 0) {
      _floodFillReveal(row, col);
    }

    // Check if sector is completed
    if (currentSector.checkCompletion()) {
      _handleSectorCompletion();
    }
  }

  void _handleCellLongPress(int row, int col) {
    if (gameOver || currentSector.grid[row][col].isRevealed) {
      return;
    }

    setState(() {
      currentSector.grid[row][col].isFlagged =
          !currentSector.grid[row][col].isFlagged;
    });
  }

  void _floodFillReveal(int row, int col) {
    // Use BFS to reveal all connected cells with 0 adjacent mines
    List<List<int>> queue = [
      [row, col]
    ];
    Set<String> visited = {};

    while (queue.isNotEmpty) {
      var current = queue.removeAt(0);
      int r = current[0];
      int c = current[1];
      String key = '$r,$c';

      if (visited.contains(key)) continue;
      visited.add(key);

      // Check all 8 directions
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (i == 0 && j == 0) continue;

          int newRow = r + i;
          int newCol = c + j;

          if (newRow >= 0 &&
              newRow < Sector.gridSize &&
              newCol >= 0 &&
              newCol < Sector.gridSize) {
            var neighborCell = currentSector.grid[newRow][newCol];

            if (!neighborCell.isRevealed &&
                !neighborCell.isMine &&
                !neighborCell.isFlagged) {
              setState(() {
                neighborCell.isRevealed = true;
              });

              _addScore(10);

              // Check for gems
              if (neighborCell.isGem) {
                setState(() {
                  gemsCollected++;
                });
                _addScore(50);
              }

              // If this cell also has no adjacent mines, add to queue
              if (neighborCell.adjacentMines == 0) {
                queue.add([newRow, newCol]);
              }
            }
          }
        }
      }
    }
  }

  void _addScore(int points) {
    setState(() {
      totalScore += points;
    });
  }

  void _handleSectorCompletion() {
    gameTimer?.cancel();

    setState(() {
      sectorsCompleted++;
    });

    // Sector completion bonus
    int sectorBonus = 500;

    // Time bonus for timed mode
    int timeBonus = 0;
    if (isTimedMode) {
      timeBonus = remainingSeconds * 5;
      sectorBonus =
          (sectorBonus * 1.5).toInt(); // Higher multiplier for timed mode
    }

    _addScore(sectorBonus + timeBonus);

    // Show completion dialog
    _showSectorCompletionDialog();
  }

  void _showSectorCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Sector Complete!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sectors Completed: $sectorsCompleted'),
            Text('Total Score: $totalScore'),
            Text('Gems Collected: $gemsCollected'),
            const SizedBox(height: 10),
            const Text(
              'Continue to the next sector?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _continueToNextSector();
            },
            child: const Text('Continue'),
          ),
          ElevatedButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: const BorderSide(color: Colors.black),
                ),
              ),
              backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _endGame();
            },
            child: const Text('End Game'),
          ),
        ],
      ),
    );
  }

  void _continueToNextSector() {
    setState(() {
      currentSector = Sector(sectorX: sectorsCompleted, sectorY: 0);
      currentSector.generate();
      firstClick = false;
      remainingSeconds = timerDuration;
    });

    if (isTimedMode) {
      _startTimer();
    }
  }

  void _handleGameOver(bool hitMine) {
    gameTimer?.cancel();

    setState(() {
      gameOver = true;
      gameStarted = false;
    });

    // Record score
    recordScore('mine_quest', totalScore.toDouble());

    // Reveal all mines
    if (hitMine) {
      setState(() {
        for (int row = 0; row < Sector.gridSize; row++) {
          for (int col = 0; col < Sector.gridSize; col++) {
            if (currentSector.grid[row][col].isMine) {
              currentSector.grid[row][col].isRevealed = true;
            }
          }
        }
      });
    }

    // Show game over dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showGameOverDialog(hitMine);
      }
    });
  }

  void _showGameOverDialog(bool hitMine) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          hitMine ? 'Game Over!' : 'Time Up!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Final Score: $totalScore'),
            Text('Sectors Completed: $sectorsCompleted'),
            Text('Gems Collected: $gemsCollected'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _initializeGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _endGame() {
    recordScore('mine_quest', totalScore.toDouble());
    _initializeGame();
  }

  void _toggleMode() {
    if (!gameStarted) {
      setState(() {
        isTimedMode = !isTimedMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Mine Quest',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Stats Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Score', totalScore.toString()),
                  _buildStatItem('Sectors', sectorsCompleted.toString()),
                  _buildStatItem('Gems', gemsCollected.toString()),
                  if (isTimedMode && gameStarted)
                    _buildStatItem('Time', '${remainingSeconds}s'),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Mode indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isTimedMode ? Colors.orange[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isTimedMode ? 'TIMED MODE' : 'UNTIMED MODE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isTimedMode ? Colors.orange[900] : Colors.green[900],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Game Board
            Expanded(
              child: Center(
                child: MineQuestBoard(
                  sector: currentSector,
                  onCellTap: _handleCellTap,
                  onCellLongPress: _handleCellLongPress,
                  gameOver: gameOver,
                ),
              ),
            ),

            // Legend
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Icons.flag, 'Flag', Colors.red),
                  const SizedBox(width: 15),
                  _buildLegendItem(Icons.diamond, 'Gem', Colors.green),
                  const SizedBox(width: 15),
                  _buildLegendItem(Icons.dangerous, 'Mine', Colors.red[400]!),
                ],
              ),
            ),

            // Control Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mode Toggle
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  gameStarted ? Colors.grey : Colors.black,
                            ),
                            onPressed: gameStarted ? null : _toggleMode,
                            child: Text(
                              isTimedMode
                                  ? 'Switch to Untimed'
                                  : 'Switch to Timed',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      // New Game
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                            ),
                            onPressed: _initializeGame,
                            child: const Text('New Game'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                      ),
                      onPressed: () {
                        gameTimer?.cancel();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Back',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
