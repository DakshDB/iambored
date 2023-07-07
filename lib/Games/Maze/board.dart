import 'package:flutter/material.dart';

class Board extends StatefulWidget {
  Board(
      {Key? key,
      required this.grid,
      required this.rows,
      required this.columns,
      required this.start,
      required this.end,
      required this.currentPos,
      required this.path})
      : super(key: key);

  final int rows;
  final int columns;

  final Offset start;
  final Offset end;

  final Offset currentPos;
  final List<Offset> path;

  final List<List<int>> grid;

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<List<int>> grid = widget.grid;
    int N = 1;
    int S = 2;
    int E = 4;
    int W = 8;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // Board size is fixed
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(), left: BorderSide()),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: grid[0].length,
          ),
          itemBuilder: (BuildContext context, int index) {
            int x = index % grid[0].length;
            int y = index ~/ grid[0].length;
            int cell = grid[y][x];

            return Stack(
              children: [
                // Mark start and end
                Positioned.fill(
                  child: (x == widget.start.dx && y == widget.start.dy)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.green,
                          ),
                        )
                      : Container(),
                ),
                Positioned.fill(
                  child: (x == widget.end.dx && y == widget.end.dy)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.red,
                          ),
                        )
                      : Container(),
                ),
                // Mark current position
                Positioned.fill(
                  child: (x == widget.currentPos.dx && y == widget.currentPos.dy)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.blue,
                          ),
                        )
                      : Container(),
                ),
                // Mark path
                Positioned.fill(
                  child: widget.path.contains(Offset(x.toDouble(), y.toDouble()))
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.yellow,
                          ),
                        )
                      : Container(),
                ),
                // Draw walls
                Positioned.fill(
                  child: (cell == 0)
                      ? Container()
                      : Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: (cell & S != 0) ? BorderSide.none : const BorderSide(),
                              right: (cell & E != 0) ? BorderSide.none : const BorderSide(),
                              top: (cell & N != 0) ? BorderSide.none : const BorderSide(),
                              left: (cell & W != 0) ? BorderSide.none : const BorderSide(),
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
          itemCount: grid.length * grid[0].length,
        ),
      ),
    );
  }
}
