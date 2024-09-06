import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iambored/Games/WordHunt/words.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';

import 'animated_key.dart';

class WordHunt extends StatefulWidget {
  const WordHunt({super.key});

  @override
  State<WordHunt> createState() => _WordHuntState();
}

class _WordHuntState extends State<WordHunt> {
  int letters = 5;
  final int maxTries = 6;
  String targetWord = 'FLAME'; // Set the target word here.
  List<String> userGuesses = [];
  List<List<Color>> guessFeedback = [];
  double score = 0;

  bool _isGameStarted = false;
  String startTimerString = '0';
  String currentGuess = '';
  Timer gameTimer = Timer(Duration.zero, () {});

  String guessedWord = '';

  // Track the status of each letter on the virtual keyboard
  Map<String, Color> keyStatus = {
    'Q': Colors.grey,
    'W': Colors.grey,
    'E': Colors.grey,
    'R': Colors.grey,
    'T': Colors.grey,
    'Y': Colors.grey,
    'U': Colors.grey,
    'I': Colors.grey,
    'O': Colors.grey,
    'P': Colors.grey,
    'A': Colors.grey,
    'S': Colors.grey,
    'D': Colors.grey,
    'F': Colors.grey,
    'G': Colors.grey,
    'H': Colors.grey,
    'J': Colors.grey,
    'K': Colors.grey,
    'L': Colors.grey,
    'Z': Colors.grey,
    'X': Colors.grey,
    'C': Colors.grey,
    'V': Colors.grey,
    'B': Colors.grey,
    'N': Colors.grey,
    'M': Colors.grey,
  };

  // Clear the key colors
  void _clearKeyStatus() {
    setState(() {
      keyStatus = keyStatus.map((key, value) => MapEntry(key, Colors.grey));
    });
  }

  // Call this method to update key colors based on the guess result
  void _updateKeyStatus(String letter, Color color) {
    setState(() {
      keyStatus[letter] = color;
    });
  }

  _getRandWord() {
    var wordsList = words[letters];
    if (wordsList == null) {
      return;
    }
    targetWord = wordsList[Random().nextInt(wordsList.length)];
    targetWord = targetWord.toUpperCase();
  }

  void _startGame() {
    setState(() {
      _isGameStarted = true;
      userGuesses.clear();
      guessFeedback.clear();
      currentGuess = '';
      guessedWord = '';

      // Reset the timers
      gameTimer.cancel();
      startTimerString = '0';
      _clearKeyStatus();
      _getRandWord();
    });
    _startTimer();
  }

  void _startTimer() {
    var seconds = const Duration(seconds: 1);
    Timer.periodic(seconds, (timer) {
      gameTimer = timer;
      setState(() {
        startTimerString = (int.parse(startTimerString) + 1).toString();
      });
    });
  }

  double calculateScore(int maxTries, int triesTaken, String timeTaken) {
    int timeInSeconds = int.parse(timeTaken);
    double baseScore = (maxTries - triesTaken + 1).toDouble();
    double timeFactor = 1 / (sqrt(timeInSeconds + 1));

    return baseScore * 100 * timeFactor;
  }

  void _gameOver() {
    setState(() {
      gameTimer.cancel();
      if (guessedWord.isEmpty) {
        score = 0;
      } else {
        score = calculateScore(maxTries, userGuesses.length, startTimerString);
      }

      recordScore("word_hunt", score);

      _isGameStarted = false;
      startTimerString = '0';
    });
  }

  void _exitGame() {
    setState(() {
      _isGameStarted = false;
      startTimerString = '0';
      gameTimer.cancel();
    });
  }

  void _submitGuess() {
    if (currentGuess.length == targetWord.length) {
      List<Color> feedback = [];

      for (int i = 0; i < currentGuess.length; i++) {
        if (currentGuess[i] == targetWord[i]) {
          feedback.add(Colors.green);
          _updateKeyStatus(currentGuess[i], Colors.green);
        } else if (targetWord.contains(currentGuess[i])) {
          feedback.add(Colors.orange);
          if (keyStatus[currentGuess[i]] != Colors.green) {
            _updateKeyStatus(currentGuess[i], Colors.orange);
          }
        } else {
          feedback.add(Colors.grey);
          _updateKeyStatus(currentGuess[i], Colors.grey);
        }
      }
      setState(() {
        userGuesses.add(currentGuess);
        guessFeedback.add(feedback);
        currentGuess = '';
      });

      // If the user has guessed the word correctly
      if (userGuesses.last == targetWord) {
        guessedWord = targetWord;
        _gameOver();
      }

      // If the user has reached the maximum number of tries
      if (userGuesses.length == maxTries) {
        _gameOver();
      }
    }
  }

  void _onKeyTap(String letter) {
    if (currentGuess.length < targetWord.length) {
      setState(() {
        currentGuess += letter;
      });
    }
  }

  void _onBackspace() {
    if (currentGuess.isNotEmpty) {
      setState(() {
        currentGuess = currentGuess.substring(0, currentGuess.length - 1);
      });
    }
  }

  double _keyboardKeyWidth() {
    var width = MediaQuery.of(context).size.width;
    var keyWidth = width / 14;
    return min(keyWidth, 40);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Timer and Score
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Timer: $startTimerString',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Game Title
                    if (_isGameStarted)
                      const Text(
                        'Word Hunt',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_isGameStarted)
                      // Game Instructions
                      const Text(
                        'Hunt the word in 6 tries',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
                // Start Button and How to Play (If the game is not started)
                if (!_isGameStarted)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Word Hunt',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (guessedWord.isNotEmpty)
                        Text(
                          'Congratulations!\n You have guessed the word: $guessedWord in ${userGuesses.length} tries!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      if (guessedWord.isNotEmpty)
                        Text(
                          'Your score: ${score.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      if (guessedWord.isEmpty && userGuesses.length == maxTries)
                        Text(
                          'Game Over! The word was: $targetWord',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Try to guess the hidden word in 6 tries',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0), side: const BorderSide(color: Colors.black))),
                          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                          backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
                        ),
                        onPressed: _startGame,
                        child: const Text('Start', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                // Game UI
                if (_isGameStarted)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      // Guess Display
                      for (int i = 0; i < userGuesses.length; i++) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            targetWord.length,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Container(
                                width: 40,
                                height: 40,
                                color: guessFeedback[i][index],
                                child: Center(
                                  child: Text(
                                    userGuesses[i][index].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10), // Add space after each row
                      ],
                      const SizedBox(height: 20),

                      // Current Guess Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          targetWord.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey.shade300,
                              child: Center(
                                child: Text(
                                  index < currentGuess.length ? currentGuess[index].toUpperCase() : '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Empty Row for the tries left
                      for (int i = 0; i < maxTries - userGuesses.length - 1; i++) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            targetWord.length,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10), // Add space after each row
                      ],

                      const SizedBox(height: 20),

                      // Virtual Keyboard
                      for (var row in [
                        ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
                        ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
                        ['Z', 'X', 'C', 'V', 'B', 'N', 'M']
                      ])
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: row.map((letter) {
                            return AnimatedKey(
                              width: _keyboardKeyWidth(),
                              letter: letter,
                              color: keyStatus[letter]!,
                              onTap: _onKeyTap,
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 10),
                      // Backspace and Enter Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                    side: const BorderSide(color: Colors.black))),
                                backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                              ),
                              icon: const Icon(Icons.backspace),
                              onPressed: _onBackspace,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(0)),
                                shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                    side: const BorderSide(color: Colors.black))),
                                backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                              ),
                              onPressed: _submitGuess,
                              child: const Text('Enter'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0), side: const BorderSide(color: Colors.black))),
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: () {
                    // If the game is not started, go back to the home screen
                    if (_isGameStarted) {
                      _exitGame();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Back', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
