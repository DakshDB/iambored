import 'package:flutter/material.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';

class Reflector extends StatefulWidget {
  const Reflector({Key? key}) : super(key: key);

  @override
  State<Reflector> createState() => _ReflectorState();
}

class _ReflectorState extends State<Reflector> {
  double barPositionX = 0;
  double barPositionY = 20;
  double barWidth = 100;
  double barHeight = 10;
  double ballPositionX = 0;
  double ballPositionY = 0;
  double ballRadius = 10;
  double ballSpeedX = 4;
  double ballSpeedY = 4;
  double screenWidth = 0;
  double screenHeight = 0;
  bool isGameRunning = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    ballPositionX = 1000;
    ballPositionY = 0;

    // Get screen size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenWidth = MediaQuery.of(context).size.width;
        screenHeight = MediaQuery.of(context).size.height;
        ballPositionX = screenWidth / 2;
        ballPositionY = screenHeight / 5;

        barPositionY = screenHeight * 0.2;
      });
    });
  }

  void startGameLoop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isGameRunning) return;

      setState(() {
        // Move the ball
        ballPositionX += ballSpeedX;
        ballPositionY += ballSpeedY;

        // Check ball collision with walls
        if (ballPositionX + ballRadius >= screenWidth || ballPositionX - ballRadius <= 0) {
          ballSpeedX *= -1; // Reverse the X direction
        }
        if (ballPositionY - ballRadius <= 0) {
          ballSpeedY *= -1; // Reverse the Y direction
        }

        // Check ball collision with the bar
        if (ballPositionY + ballRadius >= screenHeight - barHeight - barPositionY &&
            ballPositionX + ballRadius >= barPositionX &&
            ballPositionX - ballRadius <= barPositionX + barWidth) {
          increaseLevel();
          score++;
          ballSpeedY *= -1; // Reverse the Y direction
        }

        // Check game over : ball falls below the bar position
        if (ballPositionY + ballRadius >= screenHeight - barPositionY + barHeight) {
          gameOver();
        }
      });

      // Keep looping
      startGameLoop();
    });
  }

  void gameOver() {
    setState(() {
      isGameRunning = false;
      recordScore("reflector", score.toDouble());
    });
  }

  void resetGame() {
    setState(() {
      score = 0;
      isGameRunning = true;
      ballPositionX = screenWidth / 2;
      ballPositionY = screenHeight / 5;
      ballSpeedX = 4;
      ballSpeedY = 4;

      // Reset bar width
      barWidth = screenWidth / 3;
    });
    startGameLoop();
  }

  void moveBar(DragUpdateDetails details) {
    setState(() {
      barPositionX += details.delta.dx;

      // Limit the bar movement within the screen width
      if (barPositionX < 0) {
        barPositionX = 0;
      } else if (barPositionX > screenWidth - barWidth) {
        barPositionX = screenWidth - barWidth;
      }
    });
  }

  void increaseLevel() {
    setState(() {
      // Increase ball speed
      ballSpeedX *= 1.01;
      ballSpeedY *= 1.01;

      // Reduce bar width by 5%, if result is less than 3 * ball radius, set it to 2 * ball radius
      barWidth = (barWidth * 0.98).clamp(3 * ballRadius, double.infinity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: moveBar,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.0, color: Colors.black),
              left: BorderSide(width: 1.0, color: Colors.black),
              right: BorderSide(width: 1.0, color: Colors.black),
            ),
          ),
          child: Stack(
            children: [
              isGameRunning
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Score : $score',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
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
                              resetGame();
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
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  side: const BorderSide(color: Colors.black))),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child:
                                const Text('Back', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
              if (isGameRunning)
                Positioned(
                  top: ballPositionY - ballRadius,
                  left: ballPositionX - ballRadius,
                  child: Container(
                    width: ballRadius * 2,
                    height: ballRadius * 2,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                ),
              Positioned(
                bottom: barPositionY,
                left: barPositionX,
                child: Container(
                  width: barWidth,
                  height: barHeight,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
