import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iambored/Games/Maze/board.dart';

class Maze extends StatefulWidget {
  const Maze({super.key});

  @override
  State<Maze> createState() => _MazeState();
}

class _MazeState extends State<Maze> {
  // Focus nodes need to be disposed.
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // The node used to request the keyboard focus.
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.requestFocus();
    super.initState();
  }

  bool _initialized = false;

  int rows = 32;
  int columns = 32;

  int maxRow = 32;
  int maxColumns = 32;

  int N = 1;
  int S = 2;
  int E = 4;
  int W = 8;

  var start = const Offset(0, 0);
  var end = const Offset(0, 0);

  var currentPos = const Offset(0, 0);
  List<Offset> path = [];

  var grid = List.generate(64, (i) => List.generate(32, (i) => 0), growable: false);

  void generateMaze() {
    var width = columns;
    var height = rows;
    grid = List.generate(height, (i) => List.generate(width, (i) => 0), growable: false);

    var n = 1;
    var s = 2;
    var e = 4;
    var w = 8;

    var dx = {e: 1, w: -1, n: 0, s: 0};
    var dy = {e: 0, w: 0, n: -1, s: 1};

    var opposite = {e: w, w: e, n: s, s: n};

    void recursiveBacktracking(int cx, int cy) {
      var directions = [n, s, e, w];
      directions.shuffle();

      for (var dir in directions) {
        var nx = cx + dx[dir]!;
        var ny = cy + dy[dir]!;

        if (nx >= 0 && ny >= 0 && nx < width && ny < height && grid[ny][nx] == 0) {
          grid[cy][cx] |= dir;
          grid[ny][nx] |= opposite[dir]!;
          recursiveBacktracking(nx, ny);
        }
      }
    }

    recursiveBacktracking(0, 0);

    // Set start and end points
    grid[0][0] |= n;

    // Close the end of the maze
    grid[height - 1][width - 1] &= ~s;

    // Set the start and end points
    start = const Offset(0, 0);
    end = Offset(width - 1, height - 1);
  }

  // Create a 2D array of bool to represent the cells of the game board specified by rows and columns
  List<List<bool>> cells = List.generate(64, (i) => List.generate(32, (i) => false), growable: false);

  // randomly generate the initial state of the game board
  void randomize() {
    path = [];
    currentPos = start;
    generateMaze();
  }

  // Handles the key events from the RawKeyboardListener and update the
// _message.
  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    setState(() {
      if (event.physicalKey == PhysicalKeyboardKey.keyW) {
        up();
      } else if (event.physicalKey == PhysicalKeyboardKey.keyS) {
        down();
      } else if (event.physicalKey == PhysicalKeyboardKey.keyD) {
        right();
      } else if (event.physicalKey == PhysicalKeyboardKey.keyA) {
        left();
      }
    });
    return KeyEventResult.handled;
  }

  // right button
  void right() {
    setState(() {
      // Move the player right if exists and there is no right wall in current cell and no left wall in the cell on the right
      if (currentPos.dx < columns - 1 &&
          (grid[currentPos.dy.toInt()][currentPos.dx.toInt()] & E != 0) &&
          (grid[currentPos.dy.toInt()][currentPos.dx.toInt() + 1] & W != 0)) {
        currentPos = Offset(currentPos.dx + 1, currentPos.dy);
        path.add(currentPos);
      }
    });
  }

  // left button
  void left() {
    setState(() {
      // Move the player left if exists and there is no left wall in current cell and no right wall in the cell on the left
      if (currentPos.dx > 0 &&
          (grid[currentPos.dy.toInt()][currentPos.dx.toInt()] & W != 0) &&
          (grid[currentPos.dy.toInt()][currentPos.dx.toInt() - 1] & E != 0)) {
        currentPos = Offset(currentPos.dx - 1, currentPos.dy);
        path.add(currentPos);
      }
    });
  }

  // up button
  void up() {
    setState(() {
      // Move the player up if exists and there is no upper wall and no lower wall in the cell above
      if (currentPos.dy > 0 &&
          (grid[currentPos.dy.toInt()][currentPos.dx.toInt()] & N != 0) &&
          (grid[currentPos.dy.toInt() - 1][currentPos.dx.toInt()] & S != 0)) {
        currentPos = Offset(currentPos.dx, currentPos.dy - 1);
        path.add(currentPos);
      }
    });
  }

  // down button
  void down() {
    setState(() {
      // Move the player down exists and there is no down wall in current cell and no up wall in the cell below
      if (currentPos.dy < rows - 1 &&
          (grid[currentPos.dy.toInt()][currentPos.dx.toInt()] & S != 0) &&
          (grid[currentPos.dy.toInt() + 1][currentPos.dx.toInt()] & N != 0)) {
        currentPos = Offset(currentPos.dx, currentPos.dy + 1);
        path.add(currentPos);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      Size screenSize = MediaQuery.of(context).size;
      rows = (screenSize.height * 0.4 / 20).round();
      columns = (screenSize.width * 0.6 / 20).round();

      var ratio = rows / columns;

      columns = min(columns, maxColumns);
      rows = (columns * ratio).round();

      cells = List.generate(rows, (i) => List.generate(columns, (i) => false), growable: false);
      setState(() {
        randomize();
      });
      _initialized = true;
    }

    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: Column(
          children: <Widget>[
            SizedBox(height: size.height * 0.01),
            // Title of the game
            SizedBox(
              height: size.height * 0.03,
              child: const Center(
                  child: Text(
                'Solve the Maze',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
            ),
            SizedBox(height: size.height * 0.01),

            // Game board
            Board(grid: grid, rows: rows, columns: columns, start: start, end: end, currentPos: currentPos, path: path),

            SizedBox(height: size.height * 0.02),

            // Game control buttons
            SizedBox(
              height: size.height * 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Moving buttons (up, down, left, right)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      up();
                    },
                    child: const Text('Up'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      down();
                    },
                    child: const Text('Down'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      left();
                    },
                    child: const Text('Left'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      right();
                    },
                    child: const Text('Right'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        randomize();
                      });
                    },
                    child: const Text('Reset'),
                  ),
                  // Back button
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0), side: const BorderSide(color: Colors.black))),
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
