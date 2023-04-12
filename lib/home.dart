import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  double _circleSize = 0;
  double _circleOffsetTop = 0;
  double _circleOffsetLeft = 0;

  var guessX = 0.0;
  var guessY = 0.0;

  var blockX = 0.0;
  var blockY = 0.0;

  var height = 0.0;
  var width = 0.0;

  var counter = 3;

  var distance = 0.0;
  var maxDistance = 0.0;
  var score = 0;

  var totalRounds = 5;
  var currentRound = 0;

  var startButtonVisible = true;
  var timerVisible = false;
  var textVisible = false;
  var lineVisible = false;
  var guessVisible = false;
  var blockVisible = false;
  var tapEnabled = true;

  double vectorDistance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 200).animate(_controller!)
      ..addListener(() {
        setState(() {
          _circleSize = _animation!.value;
          _circleOffsetTop = -(_circleSize / 2);
          _circleOffsetLeft = -(_circleSize / 2);
        });
      });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  _onTapUp(TapUpDetails details) {
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    setState(() {
      guessVisible = true;
      vectorDistance = 0;
      guessX = x;
      guessY = y;
      startButtonVisible = false;
      timerVisible = true;
      textVisible = false;
      tapEnabled = false;
    });

    _controller!.reset();
    _countDown();
  }

  _getMaxDistance() {
    var x1 = 0.0;
    var y1 = 0.0;

    var x2 = MediaQuery.of(context).size.width;
    var y2 = MediaQuery.of(context).size.height;

    var a = x1 - x2;
    var b = y1 - y2;

    var c = sqrt(a * a + b * b);
    maxDistance = c;
  }

  _distanceBetweenPoints() {
    var x1 = guessX;
    var y1 = guessY;
    var x2 = blockX;
    var y2 = blockY;

    var a = x1 - x2;
    var b = y1 - y2;

    var c = sqrt(a * a + b * b);

    distance = c;
  }

  _getResult() {
    _distanceBetweenPoints();
    vectorDistance = distance;

    distance = (distance / maxDistance) * 10;

    score = score + (10 - distance.toInt());


    _animation =
        Tween<double>(begin: 0, end: vectorDistance * 2).animate(_controller!)
          ..addListener(() {
            setState(() {
              _circleSize = _animation!.value;
              _circleOffsetTop = -(_circleSize / 2);
              _circleOffsetLeft = -(_circleSize / 2);
            });
          });

    setState(() {
      timerVisible = false;
      lineVisible = true;
    });

    _controller!.forward();

    // wait for 1 second and then reset the round
    var duration = const Duration(seconds: 1);
    Timer(duration, _resetRound);
  }

  _moveToRandomPosition() {
    var random = Random();
    var ranX = random.nextInt(100);
    var ranY = random.nextInt(100);

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var x = ranX * width / 100;
    var y = ranY * height / 100;

    setState(() {
      blockX = x;
      blockY = y;
      blockVisible = true;
      _getResult();
    });
  }

  // countDown counter to zero seconds and then move the block to a random position
  _countDown() {
    var duration = const Duration(seconds: 1);
    Timer.periodic(duration, (Timer timer) {
      setState(() {
        if (counter < 1) {
          timer.cancel();
          _moveToRandomPosition();
          counter = 3;
        } else {
          counter = counter - 1;
        }
      });
    });
  }

  _resetRound() {
    setState(() {
      counter = 3;
      timerVisible = true;
    });
    var duration = const Duration(seconds: 1);
    Timer.periodic(duration, (Timer timer) {
      setState(() {
        if (counter < 1) {
          timer.cancel();
          if (currentRound < totalRounds) {
            currentRound = currentRound + 1;
            setState(() {
              timerVisible = false;
              textVisible = true;
              lineVisible = false;
              counter = 3;
              guessVisible = false;
              blockVisible = false;
              tapEnabled = true;
            });
          } else {
            setState(() {
              timerVisible = false;
              textVisible = false;
              lineVisible = false;
              counter = 3;
              guessVisible = false;
              blockVisible = false;
              startButtonVisible = true;

            });
          }


        } else {
          counter = counter - 1;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          lineVisible
              ? Positioned(
                  top: guessY + _circleOffsetTop + 8,
                  left: guessX + _circleOffsetLeft + 8,
                  child: Container(
                    width: _circleSize,
                    height: _circleSize,
                    decoration: const BoxDecoration(
                      color: Color(0x55464646),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : Container(),
          textVisible
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Guess the next position',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Container(),
          timerVisible
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      '$counter',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Round: $currentRound',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          blockVisible
              ? Positioned(
                  top: blockY,
                  left: blockX,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),

                  ),
                )
              : Container(),
          guessVisible
              ? Positioned(
                  top: guessY,
                  left: guessX,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),

                  ),
                )
              : Container(),
          tapEnabled? GestureDetector(
            onTapUp: (TapUpDetails details) => _onTapUp(details),
            child: Container(
              color: Colors.white10,
            ),
          ): Container(),
          startButtonVisible
              ? Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                      onPressed: () {
                        _getMaxDistance();
                        setState(() {
                          score = 0;
                          currentRound = 1;
                          textVisible = true;
                          startButtonVisible = false;
                          tapEnabled = true;
                        });
                      },
                      child: const Text("Start", style: TextStyle(fontWeight: FontWeight.bold ),),),
                )
              : Container(),
        ],
      ),
    );
  }
}
