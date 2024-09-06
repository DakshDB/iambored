import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../Leaderboard/Services/ScoreRecorder.dart';

class RecallRumble extends StatefulWidget {
  const RecallRumble({super.key});

  @override
  State<RecallRumble> createState() => _RecallRumbleState();
}

class _RecallRumbleState extends State<RecallRumble> with SingleTickerProviderStateMixin {
  bool _isStart = false;

  late Timer _timer;
  int _gameTime = 30;
  int _score = 0;
  int _streak = 1;
  int _currentImageIndex = 0;
  int _previousImageIndex = 0;
  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
  ];

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _checkAnswer(bool isMatch) {
    if (isMatch == (_colors[_currentImageIndex] == _colors[_previousImageIndex])) {
      _score += _streak;
      _streak++;
    } else {
      _streak = 1;
    }
    _previousImageIndex = _currentImageIndex;
    // Instead of have all colors same probability, we want to have the same color to appear more often than the other colors
    setState(() {
      _currentImageIndex = Random().nextInt(100) < 42 ? _currentImageIndex : Random().nextInt(_colors.length);
      _animationController.reset();
      _animationController.forward();
    });
  }

  void startGame() {
    setState(() {
      _isStart = true;
    });
    _gameTime = 30;
    _score = 0;
    _streak = 1;
    _currentImageIndex = Random().nextInt(_colors.length);
    _animationController.reset();
    _animationController.forward();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentImageIndex = 1; // Show the second image after one second
        _animationController.reset();
        _animationController.forward();
      });
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
    });
  }

  void endGame({bool ifRecordScore = true}) {
    _timer.cancel();
    setState(() {
      _isStart = false;
    });
    if (ifRecordScore) {
      recordScore("recall_rumble", _score.toDouble());
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
              'Recall Rumble',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Does the color match the previous color?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 16,
                  ),
            ),
            _isStart == true ? const SizedBox(height: 20) : const SizedBox(height: 0),
            _isStart == true
                ? Text(
                    "Timer: $_gameTime",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontSize: 18,
                        ),
                  )
                : const SizedBox(height: 0),
            const SizedBox(height: 20),
            Text(
              "Score: $_score",
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
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0), side: const BorderSide(color: Colors.black))),
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back'),
                  )
                : const SizedBox(height: 20),
            _isStart == true
                ? FadeTransition(
                    opacity: _animation,
                    child: Card(
                      elevation: 4,
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          key: ValueKey<int>(_currentImageIndex),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _colors[_currentImageIndex],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(height: 20),
            _isStart == true ? const SizedBox(height: 20) : const SizedBox(height: 0),
            _isStart == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 50),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () => _checkAnswer(true),
                        child: const Text('Yes'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 50),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () => _checkAnswer(false),
                        child: const Text('No'),
                      ),
                    ],
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
