import 'package:flutter/material.dart';
import 'package:iambored/Games/Alphabet/home.dart';
import 'package:iambored/Games/OrderOrder/home.dart';
import 'package:iambored/Games/Reflector/home.dart';

import 'Games/CatchDot/home.dart';
import 'Games/FindDot/home.dart';
import 'Games/Focus/home.dart';
import 'Games/LifeGame/home.dart';
import 'Games/SpeedClicker/home.dart';
import 'Games/SpotDot/home.dart';
import 'Games/Tapper/home.dart';
import 'Leaderboard/home.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, Widget> games = {
    'Life Game': const LifeGame(),
    'Spot Dot': const SpotDot(),
    'Catch Dot': const CatchDot(),
    'Speed Clicker': const SpeedClicker(),
    'Find Dot': const FindDot(),
    // 'Maze': const Maze(),
    'Reflector': const Reflector(),
    'Order Order': const OrderOrder(),
    'Focus': const FocusOn(),
    'Tapper': const Tapper(),
    'Alphabet': const Alphabet(),
  };

  @override
  Widget build(BuildContext context) {
    var gridCount = 2;
    if (MediaQuery.of(context).size.width < 400) {
      gridCount = 1;
    }

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              Text(
                'I am Bored',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: gridCount, // This specifies the number of columns
                  childAspectRatio: (1 / .35), // This specifies the aspect ratio of the grid items
                  mainAxisSpacing: 20, // This specifies the vertical spacing between the grid items
                  crossAxisSpacing: 20, // This specifies the horizontal spacing between the grid items
                  padding: const EdgeInsets.all(20), // This specifies the padding around the grid
                  shrinkWrap: true,
                  children: <Widget>[
                    for (var game in games.keys)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => games[game]!,
                            ),
                          );
                        },
                        child: Text(game),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0), side: const BorderSide(color: Colors.black))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Leaderboard(),
                    ),
                  );
                },
                child: const Text('Leaderboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),

              //   Add "DB" text to the bottom of the home page
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // Calculate the width of the 'DB - ' text
                  final textPainter = TextPainter(
                    text: TextSpan(text: ' DB ~ ', style: TextStyle(fontSize: 10)),
                    maxLines: 1,
                    textDirection: TextDirection.ltr,
                  )..layout(minWidth: 0, maxWidth: double.infinity);

                  // Calculate the number of repetitions needed to cover the screen width
                  final repetitions = (constraints.maxWidth * 0.85 / textPainter.width).floor();

                  // Generate the repeated text
                  String repeatedText = ' DB ~ ' * repetitions;
                  repeatedText = '~ ' + repeatedText;

                  return Text(
                    repeatedText,
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500, fontSize: 10),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
