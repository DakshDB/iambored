import 'package:flutter/material.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';
import 'models.dart';
import 'level_manager.dart';
import 'arrow_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentLevelIndex = 0;
  late Level _currentLevelData;

  // Game State
  List<Arrow> _activeArrows = [];
  Map<String, Offset> _visualOffsets = {}; // For bump animations
  Set<String> _collidingArrows = {}; // For color feedback
  int _hearts = 5;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _startLevel(_currentLevelIndex);
  }

  void _startLevel(int index) {
    setState(() {
      _currentLevelIndex = index;
      _currentLevelData = LevelManager.generateLevel(index);
      // Deep copy arrows to reset state
      _activeArrows = _currentLevelData.arrows.map((a) => a.copy()).toList();
      _visualOffsets.clear();
      _collidingArrows.clear();
      // _hearts = 5; // Hearts are global
      _isAnimating = false;
    });
  }

  void _handleArrowTap(Arrow arrow) async {
    if (_isAnimating || arrow.isExited) return;

    bool collision = _checkCollision(arrow);

    if (collision) {
      // Collision logic: Bump animation + Red Color
      setState(() {
        _hearts--;
        _collidingArrows.add(arrow.id);
        // Calculate bump offset based on direction
        double bumpAmount = 0.3;
        switch (arrow.direction) {
          case ArrowDirection.up:
            _visualOffsets[arrow.id] = Offset(0, -bumpAmount);
            break;
          case ArrowDirection.down:
            _visualOffsets[arrow.id] = Offset(0, bumpAmount);
            break;
          case ArrowDirection.left:
            _visualOffsets[arrow.id] = Offset(-bumpAmount, 0);
            break;
          case ArrowDirection.right:
            _visualOffsets[arrow.id] = Offset(bumpAmount, 0);
            break;
        }
      });

      // Wait for bump out (Faster: 70ms)
      await Future.delayed(const Duration(milliseconds: 70));

      // Return to original position and remove red color
      setState(() {
        _visualOffsets[arrow.id] = Offset.zero;
        _collidingArrows.remove(arrow.id);
      });

      if (_hearts <= 0) {
        // Wait for return animation to finish before navigating back
        await Future.delayed(const Duration(milliseconds: 70));
        if (mounted) {
          Navigator.pop(context, _currentLevelData.id);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Blocked!'), duration: Duration(milliseconds: 300)),
        );
      }
    } else {
      // Success logic
      setState(() {
        _isAnimating = true;
        arrow.isExited = true;
        // Move arrow off screen visually
        _moveArrowOffScreen(arrow);
      });

      // Wait for exit animation (Faster: 260ms)
      await Future.delayed(const Duration(milliseconds: 260));

      setState(() {
        _isAnimating = false;
        _activeArrows.removeWhere((a) => a.id == arrow.id);
      });

      if (_activeArrows.isEmpty) {
        _showLevelCompleteDialog();
      }
    }
  }

  void _moveArrowOffScreen(Arrow arrow) {
    // Update row/col to be just outside grid based on direction
    const int offset = 2;
    switch (arrow.direction) {
      case ArrowDirection.up:
        arrow.row = -offset;
        break;
      case ArrowDirection.down:
        arrow.row = _currentLevelData.rows + offset - 1;
        break;
      case ArrowDirection.left:
        arrow.col = -offset;
        break;
      case ArrowDirection.right:
        arrow.col = _currentLevelData.cols + offset - 1;
        break;
    }
  }

  bool _checkCollision(Arrow arrow) {
    for (var other in _activeArrows) {
      if (other.id == arrow.id || other.isExited) continue;

      switch (arrow.direction) {
        case ArrowDirection.up:
          if (other.col == arrow.col && other.row < arrow.row) return true;
          break;
        case ArrowDirection.down:
          if (other.col == arrow.col && other.row > arrow.row) return true;
          break;
        case ArrowDirection.left:
          if (other.row == arrow.row && other.col < arrow.col) return true;
          break;
        case ArrowDirection.right:
          if (other.row == arrow.row && other.col > arrow.col) return true;
          break;
      }
    }
    return false;
  }

  void _showLevelCompleteDialog() {
    // Record score (Highest Level Achieved)
    recordScore('vector_vortex', _currentLevelData.id.toDouble());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Complete!'),
        content: const Text('Great job!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startLevel(_currentLevelIndex + 1);
            },
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white, // Removed to use app theme
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with margin
            Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Title (Centered)
                    Column(
                      children: [
                        Text(
                          'Level ${_currentLevelData.id}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        Text(
                          _currentLevelData.difficultyLabel,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Hearts (Right Aligned)
                    Positioned(
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < _hearts
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Game Area
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double gridSize =
                        constraints.maxWidth < constraints.maxHeight
                            ? constraints.maxWidth
                            : constraints.maxHeight;
                    gridSize *= 0.8; // Padding

                    double cellSize = gridSize / _currentLevelData.cols;

                    // Recalculate cell size to fit both dimensions
                    double cellWidth = gridSize / _currentLevelData.cols;
                    double cellHeight = gridSize / _currentLevelData.rows;
                    cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

                    double gridWidth = cellSize * _currentLevelData.cols;
                    double gridHeight = cellSize * _currentLevelData.rows;

                    return SizedBox(
                      width: gridWidth,
                      height: gridHeight,
                      child: Stack(
                        clipBehavior: Clip.none, // Allow arrows to fly out
                        children: [
                          // Arrows
                          ..._activeArrows.map((arrow) {
                            // Apply visual offset if any
                            final offset =
                                _visualOffsets[arrow.id] ?? Offset.zero;
                            final isColliding =
                                _collidingArrows.contains(arrow.id);

                            return AnimatedPositioned(
                              key: ValueKey(arrow.id),
                              duration: arrow.isExited
                                  ? const Duration(
                                      milliseconds: 260) // Slower for exit
                                  : const Duration(
                                      milliseconds: 70), // Fast for bump
                              curve: arrow.isExited
                                  ? Curves.easeIn
                                  : Curves.bounceOut, // Curves
                              left: (arrow.col + offset.dx) * cellSize,
                              top: (arrow.row + offset.dy) * cellSize,
                              child: ArrowWidget(
                                arrow: arrow,
                                cellSize: cellSize,
                                color: isColliding ? Colors.red : Colors.black,
                                onTap: () => _handleArrowTap(arrow),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Back Button at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.black))),
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                  padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Back',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
