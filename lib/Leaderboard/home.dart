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

  @override
  initState() {
    super.initState();
    getData('speed_clicker');
  }

  getData(String game) async {
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
      body: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: [
              SizedBox(
                width: width,
                height: height * 0.9,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Leaderboard',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    // Row of buttons for each game
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
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
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),

                    // Add separator line
                    Container(
                      height: 1,
                      width: width,
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
                              'Average Score',
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
                              averageScore.toString(),
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
                              'Best Score',
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
                              bestScore.score.toString(),
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
                              'Games Played',
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
                      width: width,
                      color: Colors.black,
                    ),
                    // Section to display the top 10 scores and paginate through the rest
                    // Table of scores
                    Expanded(
                      child: SizedBox(
                        width: width,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Rank',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Score',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Date',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontStyle: FontStyle.italic),
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text((index + 1).toString()),
                                      ],
                                    )),
                                    DataCell(Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(scores[index].score.toString()),
                                      ],
                                    )),
                                    DataCell(Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
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
              height: height * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Add separator line
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
            ),
            ],
          ),
        ),
      ),
    );
  }
}
