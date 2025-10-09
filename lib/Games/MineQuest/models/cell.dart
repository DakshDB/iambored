class Cell {
  bool isRevealed;
  bool isFlagged;
  bool isMine;
  bool isGem;
  int adjacentMines;

  Cell({
    this.isRevealed = false,
    this.isFlagged = false,
    this.isMine = false,
    this.isGem = false,
    this.adjacentMines = 0,
  });

  Cell copyWith({
    bool? isRevealed,
    bool? isFlagged,
    bool? isMine,
    bool? isGem,
    int? adjacentMines,
  }) {
    return Cell(
      isRevealed: isRevealed ?? this.isRevealed,
      isFlagged: isFlagged ?? this.isFlagged,
      isMine: isMine ?? this.isMine,
      isGem: isGem ?? this.isGem,
      adjacentMines: adjacentMines ?? this.adjacentMines,
    );
  }
}
