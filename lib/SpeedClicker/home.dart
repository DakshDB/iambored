import 'dart:async';

import 'package:flutter/material.dart';

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
        print("stopwatchText: $stopwatchText");
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                           foregroundColor: Colors.white, backgroundColor: Colors.black,
                         ),
                         onPressed: () {
    _startGame();
                         },
                         child: const Text('Start'),
                       ),
                     ],
                   )
                    : Container(),
                lightsVisible ?
                Column(
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
                            lightsVisible = false;
                            startButtonVisible = true;
                            score = stopwatchText;
                            stopwatchText = '0.000';
                            gameTimer?.cancel();
                            tapEnabled = false;
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

              ]
          ),
        )
    );


  }
  
}