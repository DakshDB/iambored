import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../Leaderboard/Services/ScoreRecorder.dart';

class Dot {
  double x;
  double y;
  Color color;
  bool found = false;

  Dot(this.x, this.y, this.color);
}

class FindDot extends StatefulWidget {
  const FindDot({super.key});


  @override
  State<FindDot> createState() => _FindDotState();
}

class _FindDotState extends State<FindDot> {
  var height = 0.0;
  var width = 0.0;

  var boardWidth = 0.0;
  var boardHeight = 0.0;

  var tapAllowed = false;

  var colorToFind = Colors.red;
  var score = 0;
  var timerString = '0.0';
  var timerDurationSeconds = 10;

  var startTimer = false;
  var startTimerString = '0.0';
  var startTimerDurationSeconds = 3;
  var startTimerVisible = false;

  var startButtonVisible = true;
  var boardVisible = false;

  var dotSize = 32.0;
  var minDotSize = 20.0;

  List<Dot> dots = [];

  List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.purple, Colors.orange, Colors.grey];


  _getRandomColor() {
    var random = Random();
    return colors[random.nextInt(colors.length)];
  }

  // Create list of dots at random positions on the screen
  _createDots() {
    var height = boardHeight;
    var width =  boardWidth;

    var area = height * width;

    var numDots = 100 * colors.length;
    dotSize = sqrt(area / numDots);

    if (dotSize < minDotSize) {
      dotSize = minDotSize;
    }

    for (var i = 0; i < numDots; i++) {
      _createDot();
    }
  }

  _createDot() {
    var random = Random();
    var ranX = random.nextInt(100);
    var ranY = random.nextInt(100);

    var x = ranX * boardWidth / 100  + dotSize/2;
    var y = ranY * boardHeight / 100 + dotSize / 2;

    // Check if dot is too close to another dot
    if (dots.any((dot) => (dot.x - x).abs() < dotSize && (dot.y - y).abs() < dotSize)) {
      return;
    }
    // Check if dot is too close to the edge of the screen
    if (x < dotSize/2 || x > boardWidth - dotSize || y < dotSize/2 || y > boardHeight - dotSize) {
      return;
    }

    dots.add(Dot(x, y, _getRandomColor()));
  }

  _startGame() {
    _createDots();
    colorToFind = _getRandomColor();

    setState(() {
      score = 0;
      startButtonVisible = false;
      boardVisible = true;
      startTimerVisible = true;
    });
    _startStartTimer();
  }

  _dotFound(Dot dot) {
    if (dot.color == colorToFind) {
      dot.found = true;
      score++;
    }
  }

  _startStartTimer() {
    var msLeft = startTimerDurationSeconds * 1000;
    var milliseconds = const Duration(milliseconds: 10);


    Timer.periodic(milliseconds, (timer) {
      setState(() {
        msLeft -= 50;
        startTimerString = (msLeft / 1000).toStringAsFixed(1).toString();
        if (msLeft <= 0) {
          timer.cancel();
          _startTimer();
        }
      });
    });

  }

  _startTimer() {
    // 100 ms delay before allowing taps
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        tapAllowed = true;
        startTimerVisible = false;
      });
      var msLeft = timerDurationSeconds * 1000;
      var milliseconds = const Duration(milliseconds: 100);


      Timer.periodic(milliseconds, (timer) {
        setState(() {
          msLeft -= 100;
          timerString = (msLeft / 1000).toStringAsFixed(1).toString();
          if (msLeft <= 0) {
            timer.cancel();
            _endGame();
          }
        });
      });
    });


  }

  _endGame() {
    // Add 1 second pause before showing the start button
    recordScore("find_dot", score.toDouble());
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        startButtonVisible = true;
        boardVisible = false;
        dots = [];
        timerString = '0.00';
      });
    });

  }


  
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    boardWidth = width * 0.99;
    boardHeight = height * 0.9;

    return Scaffold(
      body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: startButtonVisible,
              child: Column(
                children: [
                  Text(
                    'Find Dot',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  // Score
                  Text(
                    'Score: $score',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  // Start button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                        _startGame();
                    },
                    child: const Text('Start'),
                  ),
                  const SizedBox(height: 20),
                  // Back button
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              side: const BorderSide(color: Colors.black)
                          )
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            // Board
            Visibility(
              visible: boardVisible,
              child: Column(
                children: [
                  // Top bar with score and color to find and timer
                  SizedBox(
                    height: height - boardHeight,
                    width: boardWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Score
                        Text(
                          'Score: $score',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        // Color to find
                         Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Find all the ',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            !startTimerVisible ? Container(
                              width: dotSize,
                              height: dotSize,
                              decoration: BoxDecoration(
                                color: colorToFind,
                                shape: BoxShape.circle,
                              ),
                            ) :
                            // Start timer
                            Text(
                              startTimerString,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        // Timer
                        Text(
                          'Time: $timerString',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: boardHeight,
                      width: boardWidth,
                      child: Stack(
                        children: dots.map((dot) {
                          return Visibility(
                            visible: !dot.found,
                            child: Positioned(
                              left: dot.x,
                              top: dot.y,
                              child: GestureDetector(
                                onTap: () {
                                  if (!tapAllowed) {
                                    return;
                                  }
                                  setState(() {
                                    _dotFound(dot);
                                  });
                                },
                                child: Container(
                                  width: dotSize,
                                  height: dotSize,
                                  decoration: BoxDecoration(
                                    color: dot.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
            ),
                ],
              )
            ),
          ],
        ),   )
    );
  }
}
