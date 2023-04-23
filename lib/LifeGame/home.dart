import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iambored/LifeGame/board.dart';

import 'config/rules.dart';
import 'models/rule.dart';

class LifeGame extends StatefulWidget {
  const LifeGame({super.key});

  @override
  State<LifeGame> createState() => _LifeGameState();
}

class _LifeGameState extends State<LifeGame> {
  Rule rule = rules[0];

  bool _initialized = false;

  int generations = 0;
  bool started = false;

  int rows = 64;
  int columns = 32;

  int maxRow = 72;
  int maxColumns = 72;

  int generationTime = 50;

  // Create a 2D array of bool to represent the cells of the game board specified by rows and columns
  List<List<bool>> cells = List.generate(
      64, (i) => List.generate(32, (i) => false),
      growable: false);

  // randomly generate the initial state of the game board
  void randomize() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        cells[i][j] = Random().nextBool();
      }
    }
  }


  void nextGeneration() {
    List<List<bool>> newCells = List.generate(
        rows, (i) => List.generate(columns, (i) => false),
        growable: false);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        // count the number of neighbors of the cell which has value true
        int count = countLiveNeighbors(i, j);
        // if the cell is alive
        if (cells[i][j]) {
          if (rule.survival.contains(count)) {
            newCells[i][j] = true;
          } else {
            newCells[i][j] = false;
          }
        } else {
          // if the cell is dead and has exactly b neighbors, it becomes a live cell
          if (rule.birth.contains(count)) {
            newCells[i][j] = true;
          }
        }
      }
    }

    setState(() {
      generations++;
      cells = newCells;
    });
  }

  int countLiveNeighbors(int i, int j) {
    int count = 0;
    for (int k = -1; k <= 1; k++) {
      for (int l = -1; l <= 1; l++) {
        if (k == 0 && l == 0) {
          continue;
        }
        if (i + k >= 0 &&
            i + k < rows &&
            j + l >= 0 &&
            j + l < columns &&
            cells[i + k][j + l]) {
          count++;
        }
      }
    }
    return count;
  }

  // start the game : calculate the next generation of the game board every n milliseconds until the reset button is pressed
  void startGame() {
    if (started) {
      Future.delayed(Duration(milliseconds: generationTime), () {
        nextGeneration();
        startGame();
      });
    }
  }

  // stop the game
  void stopGame() {
    setState(() {
      started = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      Size screenSize = MediaQuery.of(context).size;
      rows = (screenSize.height * 0.7 / 10).round();
      columns = (screenSize.width * 0.9 / 10).round();

      var ratio = rows / columns;

      columns = min(columns, maxColumns);
      rows = (columns * ratio).round();

      print("rows: $rows, columns: $columns");

      cells = List.generate(rows, (i) => List.generate(columns, (i) => false),
          growable: false);
      setState(() {
        randomize();
      });
      _initialized = true;
    }

    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: size.height * 0.01),
          // Title of the game
          SizedBox(
            height: size.height * 0.03,
            child: const Center(
                child: Text(
              'Life Game',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
          ),
          SizedBox(height: size.height * 0.01),
          // Game board
          Center(
            child: Board(cells: cells, rows: rows, columns: columns),
          ),
          SizedBox(height: size.height * 0.02),
          // Generation counter
          SizedBox(
            height: size.height * 0.04,
            child: Text('Generations: $generations'),
          ),
          // Rules
          SizedBox(
            height: size.height * 0.06,
            child: DropdownButton(
              value: rule.value,
              items: rules.map((Rule rule) {
                return DropdownMenuItem(
                  value: rule.value,
                  child: Text(rule.name),
                );
              }).toList(),
              onChanged: (Object? value) {
                setState(() {
                  rule = rules.firstWhere((rule) => rule.value == value);
                });
              },
            ),
          ),
          // Game control buttons
          SizedBox(
            height: size.height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reset Button
                SizedBox(
                  height: size.height * 0.04,
                  width: size.width * 0.25,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        generations = 0;
                        randomize();
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
                // Start Button
                SizedBox(
                  height: size.height * 0.04,
                  width: size.width * 0.25,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        started = true;
                      });
                      startGame();
                    },
                    child: const Text('Start'),
                  ),
                ),
                // Stop Button
                SizedBox(
                  height: size.height * 0.04,
                  width: size.width * 0.25,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      stopGame();
                    },
                    child: const Text('Stop'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: size.height * 0.04,
                  width: size.width * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const AlertDialog(
                          title: Text("How to play", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          content: Text(
                              "The Life games is played on a grid of cells, where each cell can be either alive or dead. "
                                  "At each step in time, the following transitions occur:\n\n"
                                  "1. Any live cell with surrounded by mentioned 'S' cells survives to the next generation.\n"
                                  "2. Any live cell with more or less than 'S' live neighbors dies, as if by underpopulation or overpopulation.\n"
                                  "3. Any dead cell with exactly 'B' live neighbors becomes a live cell, as if by reproduction.\n"
                              ),
                          actions: <Widget>[],
                        ),
                      );
                    },
                    child: const Text("How to play"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
