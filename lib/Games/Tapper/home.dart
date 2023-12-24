import 'dart:async';

import 'package:flutter/material.dart';

import '../../Leaderboard/Services/ScoreRecorder.dart';

class Tapper extends StatefulWidget {
  const Tapper({super.key});

  @override
  State<Tapper> createState() => _TapperState();
}

class _TapperState extends State<Tapper> {
  bool _isStart = false;
  double _size = 50;

  String _time = "0.0";

  // sizeReducer : the size of the circle decreases by 1 pixel every 100 milliseconds to a minimum of 10 pixels
  void sizeReducer() {
    setState(() {
      _size--;
    });
  }

  // startSizeReducer : start sizeReducer
  void startSizeReducer() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_size <= 20 || _isStart == false || _size >= 100) {
        timer.cancel();
      } else {
        sizeReducer();
      }
    });
  }

  startGame() {
    setState(() {
      _isStart = true;
    });
    startSizeReducer();
    _time = "0.0";
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_isStart == false) {
        timer.cancel();
      } else {
        setState(() {
          _time = (double.parse(_time) + 0.02).toStringAsFixed(2);
        });
      }
    });
  }

  tap() {
    setState(() {
      _size++;
    });
    if (_size >= 100) {
      endGame();
    }
  }

  // endGame : end the game
  void endGame({bool ifRecordScore = true}) {
    setState(() {
      _isStart = false;
      _size = 50;
    });
    var score = double.parse(_time);
    // Save the score
    if (ifRecordScore) {
      recordScore("tapper", score.toDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tapper',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            _time,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: GestureDetector(
                onTap: () {
                  if (_isStart == true) tap();
                },
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      width: _size,
                      height: _size,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    ));
  }
}
