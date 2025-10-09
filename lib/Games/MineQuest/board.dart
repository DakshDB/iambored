import 'package:flutter/material.dart';
import 'models/cell.dart';
import 'models/sector.dart';

class MineQuestBoard extends StatelessWidget {
  final Sector sector;
  final Function(int row, int col) onCellTap;
  final Function(int row, int col) onCellLongPress;
  final bool gameOver;

  const MineQuestBoard({
    super.key,
    required this.sector,
    required this.onCellTap,
    required this.onCellLongPress,
    this.gameOver = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cellSize = (screenWidth * 0.9) / Sector.gridSize;

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Sector.gridSize,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: Sector.gridSize * Sector.gridSize,
          itemBuilder: (context, index) {
            int row = index ~/ Sector.gridSize;
            int col = index % Sector.gridSize;
            Cell cell = sector.grid[row][col];

            return GestureDetector(
              onTap: () => onCellTap(row, col),
              onLongPress: () => onCellLongPress(row, col),
              child: _buildCell(cell, cellSize),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCell(Cell cell, double size) {
    // Revealed cell
    if (cell.isRevealed) {
      if (cell.isMine) {
        // Mine revealed (game over)
        return Container(
          decoration: BoxDecoration(
            color: Colors.red[400],
            border: Border.all(color: Colors.grey[400]!, width: 1),
          ),
          child: const Center(
            child: Icon(Icons.dangerous, color: Colors.white, size: 20),
          ),
        );
      } else {
        // Safe cell revealed
        Color bgColor = cell.isGem ? Colors.green[100]! : Colors.white;

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Center(
            child: _buildCellContent(cell),
          ),
        );
      }
    } else {
      // Unrevealed cell
      return Container(
        decoration: BoxDecoration(
          color: cell.isFlagged ? Colors.orange[100] : Colors.grey[300],
          border: Border.all(color: Colors.grey[400]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Center(
          child: cell.isFlagged
              ? const Icon(Icons.flag, color: Colors.red, size: 18)
              : null,
        ),
      );
    }
  }

  Widget _buildCellContent(Cell cell) {
    if (cell.isGem) {
      // Show gem icon
      return const Icon(Icons.diamond, color: Colors.green, size: 18);
    } else if (cell.adjacentMines > 0) {
      // Show number of adjacent mines
      return Text(
        '${cell.adjacentMines}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _getNumberColor(cell.adjacentMines),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _getNumberColor(int number) {
    switch (number) {
      case 1:
        return Colors.blue[700]!;
      case 2:
        return Colors.green[700]!;
      case 3:
        return Colors.red[700]!;
      case 4:
        return Colors.purple[700]!;
      case 5:
        return Colors.orange[700]!;
      case 6:
        return Colors.cyan[700]!;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey[700]!;
      default:
        return Colors.black;
    }
  }
}
