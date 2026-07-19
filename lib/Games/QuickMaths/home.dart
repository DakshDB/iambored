import 'dart:async';

import 'package:flutter/material.dart';

import '../../Leaderboard/Services/ScoreRecorder.dart';
import 'question_generator.dart';

class QuickMaths extends StatefulWidget {
  const QuickMaths({super.key});

  @override
  State<QuickMaths> createState() => _QuickMathsState();
}

class _QuickMathsState extends State<QuickMaths> {
  bool _isStart = false;

  Timer? _timer;
  int _gameTime = 30;
  int _score = 0;
  int _streak = 1;
  int _questionsAnswered = 0;

  final QuestionGenerator _generator = QuestionGenerator();
  Question _current = const Question(text: '', isTrue: true);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkAnswer(bool answer) {
    if (_isStart == false) return;

    if (answer == _current.isTrue) {
      setState(() {
        _score += _streak;
        _streak++;
        _questionsAnswered++;
        _current = _generator.next(_questionsAnswered);
      });
    } else {
      // Sudden death - one wrong answer ends the run, but the score still counts.
      endGame();
    }
  }

  void startGame() {
    _gameTime = 30;
    _score = 0;
    _streak = 1;
    _questionsAnswered = 0;

    setState(() {
      _isStart = true;
      _current = _generator.next(_questionsAnswered);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameTime > 0) {
        setState(() {
          _gameTime--;
        });
      } else {
        endGame();
      }
    });
  }

  void endGame({bool ifRecordScore = true}) {
    _timer?.cancel();
    setState(() {
      _isStart = false;
    });
    if (ifRecordScore) {
      recordScore("quick_maths", _score.toDouble());
    } else {
      _score = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanEnd: (details) {
          if (_isStart == true) {
            const int sensitivity = 8;
            final velocity = details.velocity.pixelsPerSecond;
            // Horizontal only - swipe right for true, left for false.
            if (velocity.dx.abs() > velocity.dy.abs()) {
              if (velocity.dx > sensitivity) {
                _checkAnswer(true);
              } else if (velocity.dx < -sensitivity) {
                _checkAnswer(false);
              }
            }
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Quick Maths',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Is the equation correct?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 16,
                    ),
              ),
              _isStart == true
                  ? const SizedBox(height: 20)
                  : const SizedBox(height: 0),
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
              _isStart == true
                  ? Text(
                      "Streak: x$_streak",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey[700],
                          ),
                    )
                  : const SizedBox(height: 0),
              _isStart == false
                  ? const SizedBox(height: 40)
                  : const SizedBox(height: 0),
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
              _isStart == false
                  ? const SizedBox(height: 20)
                  : const SizedBox(height: 0),
              _isStart == false
                  ? ElevatedButton(
                      style: ButtonStyle(
                        shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                    side: const BorderSide(
                                        color: Colors.black))),
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Back'),
                    )
                  : const SizedBox(height: 20),
              const SizedBox(height: 20),
              _isStart == true
                  ? Card(
                      elevation: 4,
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 40.0),
                        child: SizedBox(
                          width: 220,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: Text(
                                key: ValueKey<int>(_questionsAnswered),
                                _current.text,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(height: 20),
              _isStart == true
                  ? const SizedBox(height: 20)
                  : const SizedBox(height: 0),
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
                          child: const Text('True'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(100, 50),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black,
                          ),
                          onPressed: () => _checkAnswer(false),
                          child: const Text('False'),
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
      ),
    );
  }
}
