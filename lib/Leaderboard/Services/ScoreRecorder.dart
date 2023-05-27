import 'package:iambored/Config/config.dart';
import 'package:iambored/Leaderboard/Model/GameData.dart';
import 'package:localstorage/localstorage.dart';

import '../Model/Score.dart';

late final LocalStorage scores;

Future<bool> initializeScoreRecorder() async {
  bool initialized = false;
  scores = LocalStorage('scores.json');
  initialized = await scores.ready;
  return initialized;
}

Future<void> recordScore(String game, double score) async {
  var gameScoreOrder = gameScoreOrderMap[game];
  await scores.ready;
  var data = scores.getItem(game);
  data ??= GameData(
      game: game,
      scores: [],
      bestScore: Score(
        id: 0,
        score: 0,
        timestamp: DateTime.now(),
      ),
      totalScore: 0,
    ).toJSONEncodable();

  GameData gameData = GameData.fromMap(data);

  // Add the score to the list of scores
  gameData.scores.add(Score(
    id: gameData.scores.length,
    score: score,
    timestamp: DateTime.now(),

  ));

  // Sort the scores
  gameData.scores.sort((a, b) => b.score.compareTo(a.score) == gameScoreOrder? 1 : -1);

  // Update the best score
  gameData.bestScore = gameData.scores[0];

  // Update the total score
  gameData.totalScore = gameData.scores.fold(0, (previousValue, element) => previousValue + element.score);

  // Save the data
  scores.setItem(game, gameData.toJSONEncodable());
}

Future<List<Score>> getScores(String game) async {
  await scores.ready;
  var data = scores.getItem(game);
  if (data == null) {
    return [];
  }
  GameData gameData = GameData.fromMap(data);
  return gameData.scores;
}

Future<Score> getBestScore(String game) async {
  await scores.ready;
  var data = scores.getItem(game);
  if (data == null) {
    return Score(
      id: 0,
      score: 0,
      timestamp: DateTime.now(),
    );
  }
  GameData gameData = GameData.fromMap(data);
  return gameData.bestScore;
}

Future<double> getAverageScore(String game) async {
  await scores.ready;
  var data = scores.getItem(game);
  if (data == null) {
    return 0;
  }
  GameData gameData = GameData.fromMap(data);
  var averageScore = gameData.totalScore / gameData.scores.length;
  // round to 4 decimal places
  averageScore = (averageScore * 10000).round() / 10000;
  return averageScore;
}

Future<int> getGamesPlayed(String game) async {
  await scores.ready;
  var data = scores.getItem(game);
  if (data == null) {
    return 0;
  }
  GameData gameData = GameData.fromMap(data);
  return gameData.scores.length;
}



