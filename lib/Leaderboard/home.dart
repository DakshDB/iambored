import 'package:flutter/material.dart';
import 'package:iambored/Leaderboard/Services/ScoreRecorder.dart';
import 'package:intl/intl.dart';

import 'Model/Score.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  var maxWidth = 700.0;
  var width = 700.0;
  var height = 500.0;
  Score bestScore = Score(id: 0, score: 0, timestamp: DateTime.now());
  var averageScore = 0.0;
  var gamesPlayed = 0;
  List<Score> scores = [];
  String selectedGame = 'bored';

  @override
  initState() {
    super.initState();
    getData(selectedGame);
  }

  getData(String game) async {
    selectedGame = game;
    List responses = await Future.wait([
      getScores(game),
      getAverageScore(game),
      getGamesPlayed(game),
      getBestScore(game)
    ]);
    setState(() {
      scores = responses[0];
      averageScore = responses[1];
      gamesPlayed = responses[2];
      bestScore = responses[3];
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (screenWidth < maxWidth) {
      width = screenWidth;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: height * 0.9,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Leaderboard',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                      ),
                      // Row of buttons for each game
                      const SizedBox(
                        height: 40,
                      ),
                      ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          scrollbars: false,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'bored';
                                  getData(game);
                                },
                                child: const Text('Bored'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'mine_quest';
                                  getData(game);
                                },
                                child: const Text('Mine Quest'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'word_hunt';
                                  getData(game);
                                },
                                child: const Text('Word Hunt'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'color_catch';
                                  getData(game);
                                },
                                child: const Text('Color Catch'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'spot_out';
                                  getData(game);
                                },
                                child: const Text('Spot Out'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'react_right';
                                  getData(game);
                                },
                                child: const Text('React Right'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'speed_swipe';
                                  getData(game);
                                },
                                child: const Text('Speed Swipe'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'recall_rumble';
                                  getData(game);
                                },
                                child: const Text('Recall Rumble'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'alphabet_order';
                                  getData(game);
                                },
                                child: const Text('Alphabet Order'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'tapper';
                                  getData(game);
                                },
                                child: const Text('Tapper'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'reflector';
                                  getData(game);
                                },
                                child: const Text('Reflector'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'order_order';
                                  getData(game);
                                },
                                child: const Text('Order Order'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'focus';
                                  getData(game);
                                },
                                child: const Text('Focus ON'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'speed_clicker';
                                  getData(game);
                                },
                                child: const Text('Speed Clicker'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'spot_dot';
                                  getData(game);
                                },
                                child: const Text('Spot Dot'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'catch_dot';
                                  getData(game);
                                },
                                child: const Text('Catch Dot'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'find_dot';
                                  getData(game);
                                },
                                child: const Text('Find Dot'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'perfect_cut';
                                  getData(game);
                                },
                                child: const Text('Perfect Cut'),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  var game = 'vector_vortex';
                                  getData(game);
                                },
                                child: const Text('Vector Vortex'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),

                      // Add separator line
                      Container(
                        height: 1,
                        color: Colors.black,
                      ),

                      // Selected game
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        selectedGame[0].toUpperCase() +
                            selectedGame.substring(1).replaceAll('_', ' '),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 1,
                        color: Colors.black,
                      ),

                      const SizedBox(
                        height: 40,
                      ),

                      // Section to display Best Scores, Average Scores, and Number of Games Played
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Average Score
                          Column(
                            children: [
                              Text(
                                'Average',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                averageScore.toStringAsFixed(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          // Best Score
                          Column(
                            children: [
                              Text(
                                'Best',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                bestScore.score.toStringAsFixed(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          // Games Played
                          Column(
                            children: [
                              Text(
                                'Games',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                gamesPlayed.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 40,
                      ),
                      // Add separator line
                      Container(
                        height: 1,
                        color: Colors.black,
                      ),
                      // Section to display the top 10 scores and paginate through the rest
                      // Table of scores
                      Expanded(
                        child: SizedBox(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const <DataColumn>[
                                  DataColumn(
                                    label: Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Rank',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Score',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Date',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                rows: List<DataRow>.generate(
                                  scores.length,
                                  (int index) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text((index + 1).toString()),
                                        ],
                                      )),
                                      DataCell(Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(scores[index]
                                              .score
                                              .toStringAsFixed(1)),
                                        ],
                                      )),
                                      DataCell(Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(DateFormat('dd-MM-yyyy / kk:mm')
                                              .format(scores[index].timestamp)),
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.05,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Add separator line
                      ElevatedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  side: const BorderSide(color: Colors.black))),
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Back',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
