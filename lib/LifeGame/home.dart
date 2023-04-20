import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iambored/LifeGame/board.dart';

class LifeGame extends StatefulWidget {
  const LifeGame({super.key});


  @override
  State<LifeGame> createState() => _LifeGameState();
}

class _LifeGameState extends State<LifeGame> {

  bool _initialized = false;

  int generations = 0;
  bool started = false;

  int rows = 64;
  int columns = 32;

  int generationTime = 50;

  // Create a 2D array of bool to represent the cells of the game board specified by rows and columns
  List<List<bool>> cells = List.generate(64, (i) => List.generate(32, (i) => false), growable: false);

  // randomly generate the initial state of the game board
  void randomize() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        cells[i][j] = Random().nextBool();
      }
    }
  }

  List<int> ud = [ 0 ,1];
  List<int> od = [  4 ,5, 6 ,7];
  List<int> s = [ 2 , 3];
  List<int> b = [ 3];

  // next generation
  // Any live cell with either of ud neighbors dies, as if by underpopulation
  // Any live cell with either of od neighbors dies, as if by overpopulation.
  // Any live cell with either of s neighbors survives.
  // Any dead cell with exactly b neighbors becomes a live cell, as if by reproduction.
  void nextGeneration() {
    List<List<bool>> newCells = List.generate(rows, (i) => List.generate(columns, (i) => false), growable: false);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        // count the number of neighbors of the cell which has value true
        int count = countLiveNeighbors(i, j);
        // if the cell is alive
        if (cells[i][j]) {
          // if the cell has either of ud neighbors, it dies
          if (ud.contains(count)) {
            newCells[i][j] = false;
          }
          // if the cell has either of od neighbors, it dies
          else if (od.contains(count)) {
            newCells[i][j] = false;
          }
          // if the cell has either of s neighbors, it survives
          else if (s.contains(count)) {
            newCells[i][j] = true;
          }
        } else {
          // if the cell is dead and has exactly b neighbors, it becomes a live cell
          if (b.contains(count)) {
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
        if (i + k >= 0 && i + k < rows && j + l >= 0 && j + l < columns && cells[i + k][j + l]) {
          count++;
        }
      }
    }
    return count;
  }

  // start the game : calculate the next generation of the game board every n milliseconds until the reset button is pressed
  void startGame() {
    if (started){
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
      cells = List.generate(rows, (i) => List.generate(columns, (i) => false), growable: false);

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
          SizedBox(height: size.height * 0.03, child: const Center(child: Text('Life Game', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),),
          SizedBox(height: size.height * 0.01),
          Center(
            child: Board(cells: cells, rows: rows, columns: columns),
          ),
          SizedBox(height: size.height * 0.02),
          // Reset Button
          SizedBox(
            height: size.height * 0.18,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.04,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.black,
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
                SizedBox(height: size.height * 0.005),
                // Stop Button
               SizedBox(
                height: size.height * 0.04,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    stopGame();
                  },
                  child: const Text('Stop'),
                ),
               ),
                SizedBox(height: size.height * 0.005),
                // Start Button
                SizedBox(
                height: size.height * 0.04,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.black,
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
                SizedBox(height: size.height * 0.005),
                SizedBox(
                  height: size.height * 0.04,
                  child: Text('Generations: $generations'),
                )
              ],
            ),
          )

        ],
      ),
    );
  }


}

