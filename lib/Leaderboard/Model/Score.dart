class Score {
  int id;
  double score;
  DateTime timestamp;

  Score({
    required this.id,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'timestamp': timestamp,
    };
  }

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      id: map['id'] ?? 0,
      score: map['score'] ?? 0,
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  toJSONEncodable() {
    Map<String, dynamic> m = {};

    m['id'] = id;
    m['score'] = score;
    m['timestamp'] = timestamp.toIso8601String();

    return m;
  }
}