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
  double barWidth = 200;
  double barHeight = 10;
  double ballPositionX = 0;
  double ballPositionY = 0;
  double ballRadius = 10;
  double ballSpeedX = 3.5;
  double ballSpeedY = 3.5;
  double screenWidth = 0;
  double screenHeight = 0;
  bool isGameRunning = false;
  int score = 0;
  double difficulty = 1;

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

        barWidth = screenWidth / 3;

        barPositionY = screenHeight * 0.2;
        barPositionX = screenWidth / 2 - barWidth / 2;
      });
    });
  }

  void startGameLoop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isGameRunning) return;

      setState(() {
        // Move the ball : if the result takes the ball below the bar while the ball is within the left and right edges of the bar, round the ball position to the bar position
        if (ballPositionY + ballRadius + ballSpeedY >= screenHeight - barPositionY &&
            ballPositionX + ballRadius >= barPositionX &&
            ballPositionX - ballRadius <= barPositionX + barWidth) {
          ballPositionY = screenHeight - barPositionY - ballRadius;
        } else {
          ballPositionX += ballSpeedX;
          ballPositionY += ballSpeedY;
        }

        // Check ball collision with walls
        if (ballPositionX + ballRadius >= screenWidth || ballPositionX - ballRadius <= 0) {
          ballSpeedX *= -1; // Reverse the X direction
        }
        if (ballPositionY - ballRadius <= 0) {
          ballSpeedY *= -1; // Reverse the Y direction
        }

        // Check game over: ball falls below the bar position
        if (ballPositionY + ballRadius >= screenHeight - barPositionY) {
          gameOver();
        }

        // Check ball collision with the bar
        if (ballPositionY + ballRadius >=
                screenHeight - barHeight - barPositionY && // The ball is at the same level as the bar
            ballPositionY + ballRadius <= screenHeight - barPositionY && // The ball is not below the bar
            ballPositionX + ballRadius >= barPositionX &&
            ballPositionX - ballRadius <= barPositionX + barWidth) {
          increaseLevel();
          score += difficulty.toInt();
          ballSpeedY *= -1; // Reverse the Y direction
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

      barPositionX = screenWidth / 2 - barWidth / 2;
    });
  }

  void resetGame() {
    setState(() {
      score = 0;
      isGameRunning = true;
      ballPositionX = screenWidth / 2;
      ballPositionY = screenHeight / 5;

      // Reset ball speed based on difficulty
      switch (difficulty.round()) {
        case 1:
          ballSpeedX = 3.5;
          ballSpeedY = 3.5;
          barWidth = screenWidth / 3;
          break;
        case 2:
          ballSpeedX = 5.5;
          ballSpeedY = 5.5;
          barWidth = screenWidth / 4;
          break;
        case 3:
          ballSpeedX = 7.5;
          ballSpeedY = 7.5;
          barWidth = screenWidth / 5;
          break;
      }
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
                          // Slider to set the level of difficulty : Easy, Medium, Hard
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Difficulty',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Slider to set the level of difficulty : Easy, Medium, Hard : 1, 2, 3
                              SizedBox(
                                width: screenWidth > 600 ? 300 : screenWidth * 0.5,
                                child: Slider(
                                  activeColor: Colors.black,
                                  inactiveColor: Colors.grey,
                                  value: difficulty,
                                  min: 1,
                                  max: 3,
                                  divisions: 2,
                                  label: difficulty == 1
                                      ? 'Easy'
                                      : difficulty == 2
                                          ? 'Medium'
                                          : 'Hard',
                                  onChanged: (double value) {
                                    setState(() {
                                      difficulty = value;
                                      switch (difficulty.round()) {
                                        case 1:
                                          ballSpeedX = 3.5;
                                          ballSpeedY = 3.5;
                                          barWidth = screenWidth / 3;
                                          barPositionX = screenWidth / 2 - barWidth / 2;
                                          break;
                                        case 2:
                                          ballSpeedX = 5.5;
                                          ballSpeedY = 5.5;
                                          barWidth = screenWidth / 4;
                                          barPositionX = screenWidth / 2 - barWidth / 2;
                                          break;
                                        case 3:
                                          ballSpeedX = 7.5;
                                          ballSpeedY = 7.5;
                                          barWidth = screenWidth / 5;
                                          barPositionX = screenWidth / 2 - barWidth / 2;
                                          break;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
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
