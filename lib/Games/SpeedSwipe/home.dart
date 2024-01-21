import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../Leaderboard/Services/ScoreRecorder.dart';

class SpeedSwipe extends StatefulWidget {
  const SpeedSwipe({super.key});

  @override
  State<SpeedSwipe> createState() => _SpeedSwipeState();
}

class _SpeedSwipeState extends State<SpeedSwipe> with SingleTickerProviderStateMixin {
  bool _isStart = false;

  late Timer _timer;
  late Timer _roundTimer;
  int _gameTime = 30;
  int _score = 0;
  int _streak = 1;

  int _roundDurationMs = 1500;
  int _currentRoundDurationMs = 1500;

  List<String> moves = [
    "up",
    "down",
    "left",
    "right",
  ];

  String currentMove = "up";
  String currentMoveKey = "up";

  // late AnimationController _animationController;
  // late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // _animationController = AnimationController(
    //   duration: const Duration(milliseconds: 250),
    //   vsync: this,
    // );
    //
    // _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _timer.cancel();
    _roundTimer.cancel();
    // _animationController.dispose();
    super.dispose();
  }

  void _checkAnswer(String swipe) {
    if (swipe == currentMove) {
      setState(() {
        _currentRoundDurationMs = _roundDurationMs;
        _score += _streak;
        _streak++;
        currentMove = moves[Random().nextInt(moves.length)];
        currentMoveKey = currentMove + Random().nextInt(1000000).toString();

        print(currentMoveKey);
      });
      // _animationController.reset();
      // _animationController.forward();
    } else {
      endGame();
    }
  }

  void startGame() {
    setState(() {
      _isStart = true;
    });
    _gameTime = 30;
    _score = 0;
    _streak = 1;

    _currentRoundDurationMs = _roundDurationMs;

    currentMove = moves[Random().nextInt(moves.length)];
    currentMoveKey = currentMove + Random().nextInt(1000000).toString();

    // Start the game timer after another second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_gameTime > 0) {
          _gameTime--;
        } else {
          endGame();
        }
      });
    });

    // Start the round timer
    _roundTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_isStart == false) {
        timer.cancel();
      } else {
        setState(() {
          if (_currentRoundDurationMs > 0) {
            _currentRoundDurationMs -= 10;
          } else {
            endGame();
          }
        });
      }
    });
  }

  void endGame({bool ifRecordScore = true}) {
    _timer.cancel();
    _roundTimer.cancel();
    setState(() {
      _isStart = false;
    });
    if (ifRecordScore) {
      recordScore("speed_swipe", _score.toDouble());
    } else {
      _score = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Speed Swipe',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Swipe in the indicated direction',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 16,
                  ),
            ),
            _isStart == true ? const SizedBox(height: 20) : const SizedBox(height: 0),
            _isStart == true
                ? Text(
                    "Timer: " + _gameTime.toString(),
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontSize: 18,
                        ),
                  )
                : const SizedBox(height: 0),
            const SizedBox(height: 20),
            Text(
              "Score: " + _score.toString(),
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 18,
                  ),
            ),
            _isStart == false ? const SizedBox(height: 40) : const SizedBox(height: 0),
            _isStart == false
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      startGame();
                    },
                    child: const Text('Start'),
                  )
                : const SizedBox(height: 20),
            _isStart == false ? const SizedBox(height: 20) : const SizedBox(height: 0),
            _isStart == false
                ? ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0), side: const BorderSide(color: Colors.black))),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back'),
                  )
                : const SizedBox(height: 20),
            // Add a progress bar here for the round timer
            _isStart == true
                ? SizedBox(
                    height: 20,
                    width: MediaQuery.of(context).size.width > 400 ? 400 : MediaQuery.of(context).size.width,
                    child: LinearProgressIndicator(
                      value: _currentRoundDurationMs / _roundDurationMs,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const SizedBox(height: 20),

            _isStart == true
                ? GestureDetector(
                    onPanEnd: (details) {
                      // Note: Sensitivity is integer used when you don't want to mess up vertical drag
                      int sensitivity = 8;
                      if (details.velocity.pixelsPerSecond.dx.abs() > details.velocity.pixelsPerSecond.dy.abs()) {
                        // Horizontal swipe
                        if (details.velocity.pixelsPerSecond.dx > sensitivity) {
                          // Right Swipe
                          _checkAnswer("right");
                        } else if (details.velocity.pixelsPerSecond.dx < -sensitivity) {
                          //Left Swipe
                          _checkAnswer("left");
                        }
                      } else {
                        // Vertical swipe
                        if (details.velocity.pixelsPerSecond.dy > sensitivity) {
                          // Down Swipe
                          _checkAnswer("down");
                        } else if (details.velocity.pixelsPerSecond.dy < -sensitivity) {
                          // Up Swipe
                          _checkAnswer("up");
                        }
                      }
                    },
                    child: Card(
                      elevation: 4,
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Text(
                                key: ValueKey<String>(currentMoveKey),
                                currentMove.toUpperCase(),
                                style: Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(height: 20),
            const SizedBox(height: 40),
            _isStart == true
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      endGame(ifRecordScore: false);
                    },
                    child: const Text('End'),
                  )
                : const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
