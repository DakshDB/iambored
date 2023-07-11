import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';

class OrderOrder extends StatefulWidget {
  const OrderOrder({super.key});

  @override
  State<OrderOrder> createState() => _OrderOrderState();
}

class _NumberCircle {
  int number;
  double x;
  double y;
  double radius;
  Color color;

  _NumberCircle(this.number, this.x, this.y, this.radius, this.color);
}

class _NumberCircleList {
  List<_NumberCircle> numbers;

  _NumberCircleList(this.numbers);

  void add(_NumberCircle number) {
    numbers.add(number);
  }

  void remove(_NumberCircle number) {
    numbers.remove(number);
  }

  void clear() {
    numbers.clear();
  }

  bool contains(int number) {
    return numbers.any((element) => element.number == number);
  }

  bool any(bool Function(_NumberCircle) test) {
    return numbers.any(test);
  }

  int get length {
    return numbers.length;
  }

  _NumberCircle operator [](int index) {
    return numbers[index];
  }

  // smallestNumber returns the smallest number in the list
  int smallestNumber() {
    int smallestNumber = numbers[0].number;
    for (int i = 1; i < numbers.length; i++) {
      if (numbers[i].number < smallestNumber) {
        smallestNumber = numbers[i].number;
      }
    }
    return smallestNumber;
  }

  @override
  String toString() {
    return numbers.toString();
  }
}

class _OrderOrderState extends State<OrderOrder> {
  int _level = 1;
  int _score = 0;

  bool _isGameStarted = false;
  bool _warmUp = false;

  int numbersToOrder = 5;
  _NumberCircleList numbers = _NumberCircleList([]);

  int minNumber = 1;
  int maxNumber = 10;

  var timerDurationSeconds = 30;
  String startTimerString = '0.0';

  var warmUpDurationSeconds = 5;
  String warmUpTimerString = '0';

  Timer gameTimer = Timer(Duration.zero, () {});
  Timer warmUpTimer = Timer(Duration.zero, () {});

  var radius = 50.0;

  List<Color> circleColors = [
    Colors.red[100]!,
    Colors.blue[100]!,
    Colors.green[100]!,
    Colors.yellow[100]!,
    Colors.purple[100]!,
    Colors.orange[100]!,
    Colors.pink[100]!,
    Colors.teal[100]!,
    Colors.indigo[100]!,
    Colors.lime[100]!,
    Colors.amber[100]!,
    Colors.cyan[100]!,
    Colors.brown[100]!,
    Colors.grey[100]!,
    Colors.blueGrey[100]!,
  ];

  List<Color> colorLevel = [Colors.blueGrey[100]!];

  void _startGame() {
    setState(() {
      radius = _getRadius();

      _level = 1;
      _score = 0;

      _isGameStarted = false;
      _warmUp = true;

      // Reset the timers
      gameTimer.cancel();
      warmUpTimer.cancel();

      startTimerString = '0.0';
      timerDurationSeconds = 30;

      warmUpTimerString = '0';
      warmUpDurationSeconds = 5;

      numbersToOrder = 5;
      minNumber = 1;
      maxNumber = 10;

      numbers.clear();
    });
    _generateNumbers();
    _warmUpTimer();
  }

  _getRadius() {
    // Calculate the radius of the circles based on the screen size

    // For every 200 pixels in width, increase the radius by 10
    var radiusMultiplier = MediaQuery.of(context).size.width / 200;

    radius = 40 + (radiusMultiplier * 10);

    // Make sure the radius is not too big or too small
    if (radius > 120) {
      radius = 120;
    } else if (radius < 40) {
      radius = 40;
    }

    return radius;
  }

  _getColors() {
    // Update the colorLevel list with the colors for the current level
    colorLevel.clear();
    var colors = 1;
    // Increase the number of colors for each 3 levels
    colors = (_level / 3).ceil();

    // Fetch the random colors from the circleColors list
    var random = Random();
    for (var i = 0; i < colors; i++) {
      colorLevel.add(circleColors[random.nextInt(circleColors.length)]);
    }
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
      numbers.clear();

      // Cancel the timers
      gameTimer.cancel();
      warmUpTimer.cancel();

      // Save the score
      recordScore("order_order", _score.toDouble());
    });
  }

  _increaseLevel() {
    setState(() {
      _isGameStarted = false;
      // reset the timer
      gameTimer.cancel();
      warmUpTimer.cancel();

      timerDurationSeconds = 30;
      startTimerString = '0.0';

      warmUpTimerString = '0';
      warmUpDurationSeconds = 5;

      _level++;
      minNumber--;
      maxNumber++;

      if (_level % 3 == 0) {
        numbersToOrder++;
      }
    });
    _generateNumbers();
  }

  _nextLevel() {
    _increaseLevel();
    setState(() {
      _warmUp = true;
    });
    _warmUpTimer();
  }

  _generateNumbers() {
    numbers.clear();
    _getColors();

    // Generate numbersToOrder random numbers between minNumber and maxNumber
    for (int i = 0; i < numbersToOrder; i++) {
      // Generate a random number between minNumber and maxNumber (inclusive) which is not already in the list
      num randomNumber;
      do {
        randomNumber = minNumber + (maxNumber - minNumber) * (Random().nextDouble());
      } while (numbers.contains(randomNumber.toInt()));

      //  Generate a random position for the number on the screen (but not too close to the edge or each other)
      double randomX;
      double randomY;

      do {
        randomX = (MediaQuery.of(context).size.width - 100 - radius) * (Random().nextDouble());
        randomY = (MediaQuery.of(context).size.height - 200 - radius) * (Random().nextDouble());
      } while (numbers.any((element) => sqrt(pow(element.x - randomX, 2) + pow(element.y - randomY, 2)) < 100));

      Color randomColor = colorLevel[Random().nextInt(colorLevel.length)];
      numbers.add(_NumberCircle(randomNumber.toInt(), randomX, randomY, radius, randomColor));
    }

    if (kDebugMode) {
      print(numbers);
    }
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
                        'Level: $_level',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Timer: $startTimerString',
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
                            'Tap the numbers in order from smallest to largest.',
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
                          for (int i = 0; i < numbers.length; i++)
                            Positioned(
                              left: numbers[i].x,
                              top: numbers[i].y,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    // If the number is the least number in the list, remove it and increase the score
                                    if (numbers[i].number == numbers.smallestNumber()) {
                                      numbers.remove(numbers[i]);
                                      _score++;
                                    }
                                    if (numbers.length == 0) {
                                      _nextLevel();
                                    }
                                  });
                                },
                                child: Container(
                                  width: radius,
                                  height: radius,
                                  decoration: BoxDecoration(
                                    color: numbers[i].color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      numbers[i].number.toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
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
                              'Order Order',
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
