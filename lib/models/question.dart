class Question {
  final String id;
  final String sentence;
  final String translation;
  final int level;
  final String pattern;
  final List<String> tokens;
  final Map<String, List<String>> answer;

  const Question({
    required this.id,
    required this.sentence,
    required this.translation,
    required this.level,
    required this.pattern,
    required this.tokens,
    required this.answer,
  });

  String? roleFor(String token) {
    for (final entry in answer.entries) {
      if (entry.value.contains(token)) return entry.key;
    }
    return null;
  }
}
