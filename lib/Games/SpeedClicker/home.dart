import 'dart:async';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';

class SpeedClicker extends StatefulWidget {
  const SpeedClicker({super.key});

  @override
  State<SpeedClicker> createState() => _SpeedClickerState();
}

class _SpeedClickerState extends State<SpeedClicker> {
  var startButtonVisible = true;
  var lightsVisible = false;

  var tapEnabled = false;

  var redLightVisible = false;
  var yellowLightVisible = false;
  var greenLightVisible = false;

  var stopwatchText = '0.000';

  var score = '0';

  Timer? gameTimer, redLightTimer, yellowLightTimer, greenLightTimer;

  _startGame() {
    setState(() {
      startButtonVisible = false;
      lightsVisible = true;
      redLightVisible = true;
      yellowLightVisible = false;
      greenLightVisible = false;
      stopwatchText = '0.00';
      tapEnabled = false;
      _startRedLight();
    });
  }

  _startTimer() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      setState(() {
        stopwatchText = (double.parse(stopwatchText) + 0.001).toStringAsFixed(3);
      });
    });
  }

  _startRedLight() {
    redLightTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        yellowLightVisible = true;
        _startYellowLight();
      });
    });
  }

  _startYellowLight() {
    yellowLightTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        greenLightVisible = true;
        tapEnabled = true;
        _startTimer();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        startButtonVisible
            ? Column(
                children: [
                  Text(
                    'Speed Clicker',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  // Score
                  Text(
                    'Score: $score',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
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
              )
            : Container(),
        lightsVisible
            ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Red light, Yellow light, Green light
                      Container(
                        margin: const EdgeInsets.all(10),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: redLightVisible ? Colors.red : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: yellowLightVisible ? Colors.yellow : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: greenLightVisible ? Colors.green : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  // Timer
                  Text(
                    stopwatchText,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  // Tap area
                  GestureDetector(
                    onTap: () {
                      if (tapEnabled) {
                        setState(() {
                          recordScore('speed_clicker', double.parse(stopwatchText));
                          lightsVisible = false;
                          startButtonVisible = true;
                          score = stopwatchText;
                          stopwatchText = '0.000';
                          tapEnabled = false;
                          gameTimer?.cancel();
                          redLightTimer?.cancel();
                          yellowLightTimer?.cancel();
                          greenLightTimer?.cancel();
                        });
                      } else {
                        CherryToast.warning(
                          title: const Text('Wait Wait Wait'),
                          description: const Text('You tapped too early! Wait for green light.'),
                          animationType: AnimationType.fromTop,
                          animationDuration: const Duration(milliseconds: 500),
                        ).show(context);
                        setState(() {
                          lightsVisible = false;
                          startButtonVisible = true;
                          score = "0";
                          stopwatchText = '0.000';
                          tapEnabled = false;
                          gameTimer?.cancel();
                          redLightTimer?.cancel();
                          yellowLightTimer?.cancel();
                          greenLightTimer?.cancel();
                        });
                      }
                    },
                    child: Container(
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.25,
                    ),
                  ),
                ],
              )
            : Container(),
      ]),
    ));
  }
}
