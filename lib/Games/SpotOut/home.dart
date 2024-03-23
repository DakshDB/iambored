import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';

class SpotOut extends StatefulWidget {
  const SpotOut({super.key});

  @override
  State<SpotOut> createState() => _SpotOutState();
}

class _ColorShape {
  double x;
  double y;
  BoxShape shape;
  Color color;

  _ColorShape(this.shape, this.x, this.y, this.color);
}

class _ColorShapeList {
  List<_ColorShape> colorShapes;

  _ColorShapeList(this.colorShapes);

  void add(_ColorShape colorShape) {
    colorShapes.add(colorShape);
  }

  void remove(_ColorShape colorShape) {
    colorShapes.remove(colorShape);
  }

  void clear() {
    colorShapes.clear();
  }

  bool contains(_ColorShape colorShape) {
    //   Check if the list contains a shape that satisfies the test
    return colorShapes.any((element) => element.shape == colorShape.shape && element.color == colorShape.color);
  }

  bool any(bool Function(_ColorShape) test) {
    return colorShapes.any(test);
  }

  int get length {
    return colorShapes.length;
  }

  _ColorShape operator [](int index) {
    return colorShapes[index];
  }

  @override
  String toString() {
    return colorShapes.toString();
  }
}

class _SpotOutState extends State<SpotOut> {
  int _score = 0;
  int _level = 1;

  bool _isGameStarted = false;
  bool _warmUp = false;

  _ColorShapeList shapes = _ColorShapeList([]);

  var timerDurationSeconds = 30;
  String startTimerString = '0.0';

  var warmUpDurationSeconds = 3;
  String warmUpTimerString = '0';

  var numberOfShapes = 7;
  var variety = 2;

  Timer gameTimer = Timer(Duration.zero, () {});
  Timer warmUpTimer = Timer(Duration.zero, () {});

  var radius = 40.0;

  List<Color> circleColors = [
    Colors.red[400]!,
    Colors.blue[400]!,
    Colors.green[400]!,
    Colors.yellow[400]!,
    Colors.purple[400]!,
    Colors.teal[400]!,
    Colors.indigo[400]!,
    Colors.amber[400]!,
    Colors.cyan[400]!,
    Colors.brown[400]!,
    Colors.grey[400]!,
    Colors.blueGrey[400]!,
    Colors.deepOrange[400]!,
    Colors.deepPurple[400]!,
    Colors.lightBlue[400]!,
    Colors.lightGreen[400]!,
    Colors.lime[400]!,
    Colors.orange[400]!,
    Colors.pink[400]!,
    Colors.amberAccent[400]!,
    Colors.blueAccent[400]!,
    Colors.cyanAccent[400]!,
    Colors.deepOrangeAccent[400]!,
    Colors.deepPurpleAccent[400]!,
    Colors.greenAccent[400]!,
    Colors.indigoAccent[400]!,
    Colors.lightBlueAccent[400]!,
    Colors.lightGreenAccent[400]!,
    Colors.limeAccent[400]!,
    Colors.orangeAccent[400]!,
    Colors.pinkAccent[400]!,
    Colors.purpleAccent[400]!,
    Colors.redAccent[400]!,
    Colors.tealAccent[400]!,
    Colors.yellowAccent[400]!,
  ];

  // Possible shapes
  var shapesList = [BoxShape.circle, BoxShape.rectangle];

  void _startGame() {
    setState(() {
      _score = 0;
      _level = 1;
      radius = 40.0;

      _isGameStarted = false;
      _warmUp = true;

      variety = 2;
      numberOfShapes = 7;

      // Reset the timers
      gameTimer.cancel();
      warmUpTimer.cancel();

      startTimerString = '0.0';
      timerDurationSeconds = 30;

      warmUpTimerString = '0';
      warmUpDurationSeconds = 3;

      shapes.clear();
    });
    _generateBlocks();
    _warmUpTimer();
  }

  _startTimer() {
    var msLeft = timerDurationSeconds * 1000;
    var milliseconds = const Duration(milliseconds: 10);

    setState(() {
      _isGameStarted = true;
    });

    Timer.periodic(milliseconds, (timer) {
      gameTimer = timer;
      setState(() {
        msLeft -= 50;
        startTimerString = (msLeft / 1000).toStringAsFixed(1).toString();
        if (msLeft <= 0) {
          timer.cancel();
          _gameOver();
        }
      });
    });
  }

  _warmUpTimer() {
    var msLeft = warmUpDurationSeconds * 1000;
    var milliseconds = const Duration(milliseconds: 25);

    Timer.periodic(milliseconds, (timer) {
      warmUpTimer = timer;
      setState(() {
        msLeft -= 50;
        warmUpTimerString = (msLeft / 1000).toStringAsFixed(0).toString();
        if (msLeft <= 0) {
          timer.cancel();
          _startTimer();
          _warmUp = false;
        }
      });
    });
  }

  _gameOver() {
    setState(() {
      _isGameStarted = false;
      startTimerString = '0.0';
      shapes.clear();

      // Cancel the timers
      gameTimer.cancel();
      warmUpTimer.cancel();

      // Save the score
      recordScore("spot_out", _score.toDouble());
    });
  }

  _nextLevel() {
    setState(() {
      _level++;
      // Increase the score based on the level & time left
      var roundScore = (timerDurationSeconds * _level * 0.01) + (_level * 0.1) + 1;
      _score += roundScore.toInt();

      _isGameStarted = false;
      _warmUp = true;

      // Increase the number of shapes
      if (_level % 3 == 0) {
        numberOfShapes++;
      }

      // Increase the variety of shapes
      if (_level % 5 == 0) {
        variety++;
      }

      // Decrease the radius of the shapes as the level increases
      radius = max(20.0, radius - 0.2);

      // Reset the timers
      gameTimer.cancel();
      warmUpTimer.cancel();

      startTimerString = '0.0';
      timerDurationSeconds = 30;

      warmUpTimerString = '0';
      warmUpDurationSeconds = 3;

      shapes.clear();
    });
    _generateBlocks();
    _warmUpTimer();
  }

  _generateBlocks() {
    shapes.clear();

    // List of possible shapes of size variety
    _ColorShapeList possibleShapes = _ColorShapeList([]);

    for (int i = 0; i < variety; i++) {
      var x = 0.0;
      var y = 0.0;
      var color = circleColors[i % circleColors.length];
      var shape = shapesList[i % shapesList.length];

      var random = Random();

      // Combination of shape and color already exists in the list, generate a new one
      int maxRetries = 10; // Set your maximum retries
      int retries = 0;

      do {
        shape = shapesList[random.nextInt(shapesList.length)];
        color = circleColors[random.nextInt(circleColors.length)];
        retries++;
        if (retries > maxRetries) {
          break;
        }
      } while (possibleShapes.contains(_ColorShape(shape, x, y, color)));

      // Add the shape to the list if it's not already present
      if (!possibleShapes.contains(_ColorShape(shape, x, y, color))) {
        possibleShapes.add(_ColorShape(shape, x, y, color));
      }
    }

    var random = Random();
    var oddOutShape = possibleShapes[random.nextInt(possibleShapes.length)];
    // Remove the odd one out from the list
    possibleShapes.remove(oddOutShape);

    // Add random positions for the odd one out
    //  Generate a random position for the number on the screen (but not too close to the edge or each other)
    double randomX;
    double randomY;

    int maxRetries = 10; // Set your maximum retries
    int retries = 0;

    do {
      randomX = (MediaQuery.of(context).size.width - 100 - radius) * (Random().nextDouble());
      randomY = (MediaQuery.of(context).size.height - 200 - radius) * (Random().nextDouble());
      retries++;
      if (retries > maxRetries) {
        break;
      }
    } while (shapes.any((element) => sqrt(pow(element.x - randomX, 2) + pow(element.y - randomY, 2)) < 100));

    oddOutShape.x = randomX;
    oddOutShape.y = randomY;

    shapes.add(oddOutShape);

    // Add the other shapes
    for (int i = 0; i < numberOfShapes - 1; i++) {
      //  Generate a random position for the number on the screen (but not too close to the edge or each other)
      int maxRetries = 10; // Set your maximum retries
      int retries = 0;

      do {
        randomX = (MediaQuery.of(context).size.width - 100 - radius) * (Random().nextDouble());
        randomY = (MediaQuery.of(context).size.height - 200 - radius) * (Random().nextDouble());
        retries++;
        if (retries > maxRetries) {
          break;
        }
      } while (shapes.any((element) => sqrt(pow(element.x - randomX, 2) + pow(element.y - randomY, 2)) < 100));

      var shape = possibleShapes[random.nextInt(possibleShapes.length)];

      var shapeToAdd = _ColorShape(shape.shape, randomX, randomY, shape.color);
      shapes.add(shapeToAdd);
    }

    //   Check if at least one shape is the odd one out
    if (!shapes.any((element) => _checkOddOneOut(element))) {
      _generateBlocks();
    }
  }

  bool _checkOddOneOut(_ColorShape shape) {
    // Check if the shape is the odd one out
    var frequency = 0;
    for (int i = 0; i < shapes.length; i++) {
      if (shapes[i].shape == shape.shape && shapes[i].color == shape.color) {
        frequency++;
      }
    }

    return frequency == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Timer and Score
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Timer: $startTimerString',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Level: $_level',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Score: $_score',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Warm up timer
              if (!_isGameStarted && _warmUp)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height - 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          warmUpTimerString,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // How to play
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Tap the odd one out',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Game area
              Stack(
                children: [
                  if (_isGameStarted)
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height - 150,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          // Place the numbers in random positions on the screen (but not too close to the edge or each other) in circles
                          for (int i = 0; i < shapes.length; i++)
                            Positioned(
                              left: shapes[i].x,
                              top: shapes[i].y,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    if (_checkOddOneOut(shapes[i])) {
                                      _nextLevel();
                                    }
                                  });
                                },
                                child: Container(
                                    width: radius,
                                    height: radius,
                                    decoration: BoxDecoration(
                                      color: shapes[i].color,
                                      shape: shapes[i].shape,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    )),
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (!_isGameStarted && !_warmUp)
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height - 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Spot Out',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 20),

                            // Score
                            Text(
                              'Score: $_score',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),

                            // Start Game button
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                ),
                              ),
                              onPressed: () {
                                if (kDebugMode) {
                                  print('Start Game');
                                }
                                setState(() {
                                  _startGame();
                                });
                              },
                              child: const Text('Start Game'),
                            ),
                            // Back button
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                    side: const BorderSide(color: Colors.black))),
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Back',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
