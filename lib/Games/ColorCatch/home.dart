import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';

class ColorCatch extends StatefulWidget {
  const ColorCatch({super.key});

  @override
  State<ColorCatch> createState() => _ColorCatchState();
}

class _ColorCatchState extends State<ColorCatch> {
  Timer? gameTimer;
  bool _isChecking = false;
  bool _isGameOver = false;

  double score = 0;

  var boardVisible = false;

  double ballY = 0.1; // Ball's initial position
  double ballSpeed = 0.005; // Ball's speed
  double lineY = 0.8; // Line's position

  _startGame() {
    setState(() {
      _isGameOver = false;
      _isChecking = false;
      score = 0;
      ballY = 0.1;
      ballSpeed = 0.005;
      boardVisible = true;
    });
    _startTimer();
  }

  _startTimer() {
    // 100 ms delay before allowing taps
    Future.delayed(const Duration(milliseconds: 100), () {
      gameTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        if (_isChecking) return;
        setState(() {
          ballY += ballSpeed;

          var ballHeight = 0.8 * MediaQuery.of(context).size.height * ballY;
          var lineHeight = 0.8 * MediaQuery.of(context).size.height * lineY;

          if (ballHeight > lineHeight + 5) {
            // If the ball has fallen off the screen
            _endGame();
          }
        });
      });
    });
  }

  _endGame() {
    if (_isGameOver) return;
    _isGameOver = true;

    gameTimer?.cancel();
    recordScore("color_catch", score.toDouble());
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        boardVisible = false;
      });
    });
  }

  _catchBall() {
    _isChecking = true;

    var ballHeight = 0.8 * MediaQuery.of(context).size.height * ballY;
    var lineHeight = 0.8 * MediaQuery.of(context).size.height * lineY;

    if (ballHeight + 50 < lineHeight) {
      _endGame();
      return;
    }

    if (ballHeight > lineHeight + 5) {
      _endGame();
      return;
    }

    double distance = ((ballHeight + 25) - (lineHeight + 2.5)).abs();
    distance = (distance * 100).round() / 100;
    var roundedScore = ((100 - distance) * 100) / 100;
    score += roundedScore;
    ballSpeed = ballSpeed * 1.025;
    _isChecking = false;
    setState(() {
      ballY = 0.1;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
            visible: !boardVisible,
            child: Column(
              children: [
                Text(
                  'Color Catch',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                // Instructions
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    'Tap the screen when the red ball is touching the black line.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 20),
                // Score
                Text(
                  'Score: ${score.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                // Start button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
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
          ),
          // Board
          Visibility(
              visible: boardVisible,
              child: Column(
                children: [
                  // Top bar with score and color to find and timer
                  SizedBox(
                    height: 0.2 * MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Color Catch',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        // Score
                        Text(
                          'Score: ${score.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  // Board
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _catchBall();
                    },
                    child: SizedBox(
                      height: 0.8 * MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: ballY * 0.8 * MediaQuery.of(context).size.height,
                            left: MediaQuery.of(context).size.width / 2 - 25,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: lineY * 0.8 * MediaQuery.of(context).size.height,
                            left: 0,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 5,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    ));
  }
}
