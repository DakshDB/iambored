import 'Score.dart';

class GameData {
  String game;
  List<Score> scores;
  Score bestScore;
  double totalScore;
  int scoreOrder = 1;

  GameData({
    required this.game,
    required this.scores,
    required this.bestScore,
    required this.totalScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'game': game,
      'scores': scores,
      'bestScore': bestScore,
      'totalScore': totalScore,
      'scoreOrder': scoreOrder,
    };
  }

  factory GameData.fromMap(Map<String, dynamic> map) {
    List<Score> scores = [];
    if (map['scores'] != null) {
      for (var score in map['scores']) {
        scores.add(Score.fromMap(score));
      }
    }

    Score bestScore = Score.fromMap(map['bestScore'] ?? {});
    double totalScore = map['totalScore'] ?? 0;

    return GameData(
      game: map['game'] ?? '',
      scores: scores,
      bestScore: bestScore,
      totalScore: totalScore,
    );
  }

  toJSON() {
    Map<String, dynamic> m = {};

    m['game'] = game;
    m['scores'] = scores.map((e) => e.toJSON()).toList();
    m['bestScore'] = bestScore.toJSON();
    m['totalScore'] = totalScore;

    return m;
  }
}
