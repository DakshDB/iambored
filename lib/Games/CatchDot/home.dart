import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';

class CatchDot extends StatefulWidget {
  const CatchDot({super.key});


  @override
  State<CatchDot> createState() => _CatchDotState();
}

class _CatchDotState extends State<CatchDot> {

  var blockX = 0.0;
  var blockY = 0.0;

  var height = 0.0;
  var width = 0.0;

  var timerDuration = 30;
  var currTimer = 30;

  // Dot speed is the frequency of the dot movement in milliseconds
  var dotSpeed = 650;

  var score = 0;

  var startButtonVisible = true;
  var timerVisible = false;
  var textVisible = false;
  var blockVisible = false;
  var tapEnabled = true;

  double vectorDistance = 0;

  _onTapUp(TapUpDetails details) {
      // If the tap is within the dot, increase the score
      // Calculate the distance between the tap and the dot
      vectorDistance = sqrt(pow(details.globalPosition.dx - blockX, 2) + pow(details.globalPosition.dy - blockY, 2));
      if (vectorDistance < 32) {
        setState(() {
          score++;
          blockVisible = false;
        });
      }

  }

  _moveToRandomPosition() {
    var random = Random();
    var ranX = random.nextInt(100);
    var ranY = random.nextInt(100);

    height = MediaQuery.of(context).size.height - 64;
    width = MediaQuery.of(context).size.width - 64;

    var x = ranX * width / 100 + 32;
    var y = ranY * height / 100 + 32;

    setState(() {
      blockX = x;
      blockY = y;
      blockVisible = true;
    });
  }

  _startTimer() {
    timerVisible = true;
    var timerPeriod = Duration(milliseconds: dotSpeed);
    Timer.periodic(
      timerPeriod,
          (Timer timer) {
        if (timer.tick >= timerDuration/(dotSpeed/1000)) {
          timer.cancel();
          setState(() {
            blockVisible = false;
            currTimer = (timerDuration -( timer.tick * (dotSpeed.toDouble() /1000))).toInt();
            textVisible = true;
            tapEnabled = false;
            startButtonVisible = true;
          });
          recordScore('catch_dot', score.toDouble());
        } else {
          setState(() {
            _moveToRandomPosition();
            currTimer = (timerDuration -( timer.tick * (dotSpeed.toDouble() /1000))).toInt();
          });
        }
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Timer: $currTimer',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          blockVisible
              ? Positioned(
                  top: blockY,
                  left: blockX,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : Container(),
          tapEnabled
              ? GestureDetector(
                  onTapUp: (TapUpDetails details) => _onTapUp(details),
                  child: Container(
                    color: Colors.white10,
                  ),
                )
              : Container(),
          startButtonVisible
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your score is $score',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _startTimer();
                            score = 0;
                            textVisible = true;
                            startButtonVisible = false;
                            tapEnabled = true;
                          });
                        },
                        child: const Text(
                          "Start",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Back button
                      ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  side: const BorderSide(color: Colors.black)
                              )
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Back', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
