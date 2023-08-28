import 'dart:async';

import 'package:flutter/material.dart';

import '../../Leaderboard/Services/ScoreRecorder.dart';

class FocusOn extends StatefulWidget {
  const FocusOn({Key? key}) : super(key: key);

  @override
  State<FocusOn> createState() => _FocusOnState();
}

class _FocusOnState extends State<FocusOn> {
  bool _isStart = false;
  bool _isEnd = false;
  String _time = "0.0";

  Color _color = const Color(0xff000000);
  double _size = 40;
  double _sizeChange = 0.4;
  double _colorChange = 0.001;

  void _startTimer() {
    _isStart = true;
    _isEnd = false;
    _time = "0.0";
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_isEnd) {
        timer.cancel();
      } else {
        setState(() {
          _time = (double.parse(_time) + 0.02).toStringAsFixed(2);
          transform();
        });
      }
    });
  }

  void _endTimer() {
    setState(() {
      _color = const Color(0xff000000);
      _size = 40;
      _sizeChange = 0.4;
      _colorChange = 0.001;

      var score = double.parse(_time);
      // Save the score
      recordScore("focus", score.toDouble());

      _isEnd = true;
      _isStart = false;
    });
  }

  // Transformer : When the focus starts, a circle appears in the middle of the screen.
  // The circle changes color every 100 milliseconds and the size of the circle increases by 1 pixel every 100 milliseconds to a maximum of 60 pixels and decreases by 1 pixel every 100 milliseconds to a minimum of 10 pixels and keeps repeating this process.
  void transform() {
    _size += _sizeChange;
    if (_size > 80) {
      _sizeChange = -0.4;
    } else if (_size < 20) {
      _sizeChange = 0.4;
    }

    //  Transform color throughout the color spectrum
    _colorChange += 0.001;
    if (_colorChange > 1) {
      _colorChange = 0.001;
    }

    double hue = _colorChange * 360.0;
    _color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_isStart) {
          _endTimer();
        }
      },
      child: Center(
        child: _isStart
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                      children: [
                        Text(
                          'Focus ON',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$_time',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Container(
                        width: _size,
                        height: _size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _color,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Column(
                        children: [
                          Text('Focus ! Keep Looking At The Circle',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                          const SizedBox(height: 20),
                          Text('Tap the screen when you are done',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontSize: 16,
                                  )),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Focus ON',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  Text(
                    '$_time',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      _startTimer();
                    },
                    child: const Text('Start'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0), side: const BorderSide(color: Colors.black))),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
      ),
    ));
  }
}
