import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../Leaderboard/Services/ScoreRecorder.dart';

class ReactRight extends StatefulWidget {
  const ReactRight({super.key});

  @override
  State<ReactRight> createState() => _ReactRightState();
}

class _ReactRightState extends State<ReactRight> with SingleTickerProviderStateMixin {
  bool _isStart = false;

  late Timer _timer;
  int _gameTime = 30;
  int _score = 0;
  int _streak = 1;

  // Happy Emojis
  final _happyEmojis = [
    "😀",
    "😃",
    "😄",
    "😁",
    "😆",
    "😊",
    "😇",
    "🙂",
  ];

  // Sad Emojis
  final _sadEmojis = [
    "😔",
    "😕",
    "🙁",
    "😣",
    "😖",
    "😫",
    "😩",
  ];

  var questions = {
    "is_even": "Is the number even?",
    "is_smiling": "Is the emoji smiling?",
  };

  var _currentEmoji = "😀";
  var _currentNumber = 0;
  var _currentQuestion = "is_even";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _checkAnswer(bool answer) {
    // Check the answer and update the score and streak
    if (_currentQuestion == "is_even") {
      if (_currentNumber % 2 == 0 && answer == true) {
        setState(() {
          _score += _streak;
          _streak++;
        });
      } else if (_currentNumber % 2 != 0 && answer == false) {
        setState(() {
          _score += _streak;
          _streak++;
        });
      } else {
        _streak = 1;
      }
    } else if (_currentQuestion == "is_smiling") {
      if (_happyEmojis.contains(_currentEmoji) && answer == true) {
        setState(() {
          _score += _streak;
          _streak++;
        });
      } else if (_sadEmojis.contains(_currentEmoji) && answer == false) {
        setState(() {
          _score += _streak;
          _streak++;
        });
      } else {
        _streak = 1;
      }
    }
    _nextQuestion();
  }

  void _nextQuestion() {
    // Update the current emoji and number
    setState(() {
      var isHappy = Random().nextInt(2);
      if (isHappy == 0) {
        _currentEmoji = _happyEmojis[Random().nextInt(_happyEmojis.length)];
      } else {
        _currentEmoji = _sadEmojis[Random().nextInt(_sadEmojis.length)];
      }

      // _current_number is a random number between 1 and 9
      _currentNumber = Random().nextInt(9) + 1;

      // _current_question is a random question from the list of questions
      _currentQuestion = questions.keys.elementAt(Random().nextInt(questions.length));
    });
  }

  void startGame() {
    setState(() {
      _isStart = true;
    });
    _gameTime = 30;
    _score = 0;
    _streak = 1;

    _nextQuestion();

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
  }

  void endGame({bool ifRecordScore = true}) {
    _timer.cancel();
    setState(() {
      _isStart = false;
    });
    if (ifRecordScore) {
      recordScore("react_right", _score.toDouble());
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
              'React Right',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
            ),

            _isStart == true ? const SizedBox(height: 20) : const SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isStart == true
                    ? Text(
                        "Timer: $_gameTime",
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontSize: 18,
                            ),
                      )
                    : const SizedBox(width: 0),
                _isStart == true ? const SizedBox(width: 40) : const SizedBox(width: 0),
                Text(
                  "Score: $_score",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontSize: 18,
                      ),
                ),
              ],
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

            // Add two cards
            // Above card is for first question and below card is for second question
            _isStart == true
                ? Column(
                    children: [
                      // If the question is "is_even" then show the question text
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 400 ? 380 : MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        child: Center(
                          child: Text(
                            _currentQuestion == "is_even" ? questions[_currentQuestion]! : "",
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                      // First question
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 400 ? 380 : MediaQuery.of(context).size.width * 0.8,
                        height: 80,
                        child: Card(
                          child: Center(
                            child: Text(
                              _currentQuestion == "is_even" ? "$_currentNumber $_currentEmoji" : "",
                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Second question
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 400 ? 380 : MediaQuery.of(context).size.width * 0.8,
                        height: 80,
                        child: Card(
                          child: Center(
                            child: Text(
                              _currentQuestion == "is_smiling" ? "$_currentNumber $_currentEmoji" : "",
                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      // If the question is "is_smiling" then show the question text
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 400 ? 380 : MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        child: Center(
                          child: Text(
                            _currentQuestion == "is_smiling" ? questions[_currentQuestion]! : "",
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(height: 0),

            // Add two buttons Yes and No
            _isStart == true ? const SizedBox(height: 20) : const SizedBox(height: 0),
            _isStart == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          _checkAnswer(true);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Yes',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          _checkAnswer(false);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
