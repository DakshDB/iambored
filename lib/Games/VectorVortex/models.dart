enum ArrowDirection { up, down, left, right }

class Arrow {
  final String id;
  final ArrowDirection direction;
  int row;
  int col;
  bool isExited;

  Arrow({
    required this.id,
    required this.direction,
    required this.row,
    required this.col,
    this.isExited = false,
  });

  Arrow copy() {
    return Arrow(
      id: id,
      direction: direction,
      row: row,
      col: col,
      isExited: isExited,
    );
  }
}

class Level {
  final int id;
  final int rows;
  final int cols;
  final List<Arrow> arrows;

  final String difficultyLabel;

  Level({
    required this.id,
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.difficultyLabel,
  });
}
