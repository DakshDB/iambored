import 'package:flutter/material.dart';

import '../../Leaderboard/Services/ScoreRecorder.dart';

class Bored extends StatefulWidget {
  const Bored({super.key});

  @override
  State<Bored> createState() => _BoredState();
}

class _BoredState extends State<Bored> {
  var count = 0;

  final List<String> _statements = [
    "Still here? Must be really exciting tapping that circle.",
    "Wow, you're back for more? The circle must be fascinating company.",
    "Newsflash: There's a whole world outside this circle, you know.",
    "Is the circle your new best friend? Maybe it's time to branch out.",
    "You're a tapping machine! ...At least you're keeping your finger muscles strong.",
    "Seriously? You're tapping that circle again?! Get a life!",
    "The circle isn't going anywhere! Maybe try exploring the app a bit more?",
    "ARRRGH! Enough with the circle already! It's not a magical portal to entertainment!",
    "Whoa, you're back! Did the circle tell you something new?",
    "Hey there, circle tapper extraordinaire! Didn't expect to see you so soon.",
    "Wow, another round of tapping? The circle must be keeping you on your toes!",
    "Sigh... fine, tap the circle again. But next time, try something different, okay?",
    "The circle appreciates your attention, I'm sure. But maybe give it a break for a while?",
    "Are we stuck in a tapping loop here? Maybe try shaking your phone to escape?"
  ];

  String _selectedStatement = "Still here? Must be really exciting tapping that circle.";

  tap() {
    // Change the statement every 10 taps, make it random
    if ((count + 1) % 10 == 0) {
      var random = _statements[0];
      _statements.shuffle();
      while (random == _statements[0]) {
        _statements.shuffle();
      }
      _selectedStatement = _statements[0];
    }
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bored',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the circle',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                _selectedStatement,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: GestureDetector(
              onTap: () {
                tap();
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
              ),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0), side: const BorderSide(color: Colors.black))),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () {
              recordScore("bored", count.toDouble());
              Navigator.pop(context);
            },
            child: const Text('Back'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ));
  }
}
