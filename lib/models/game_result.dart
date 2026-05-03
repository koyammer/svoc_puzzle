class GameResult {
  final String id;
  final DateTime playedAt;
  final String mode; // 'decompose' | 'pattern'
  final int level;
  final int score;
  final int correct;
  final int total;

  const GameResult({
    required this.id,
    required this.playedAt,
    required this.mode,
    required this.level,
    required this.score,
    required this.correct,
    required this.total,
  });

  double get accuracy => total == 0 ? 0 : correct / total;

  Map<String, dynamic> toJson() => {
        'id': id,
        'playedAt': playedAt.toIso8601String(),
        'mode': mode,
        'level': level,
        'score': score,
        'correct': correct,
        'total': total,
      };

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
        id: json['id'] as String,
        playedAt: DateTime.parse(json['playedAt'] as String),
        mode: json['mode'] as String,
        level: json['level'] as int,
        score: json['score'] as int,
        correct: json['correct'] as int,
        total: json['total'] as int,
      );
}
