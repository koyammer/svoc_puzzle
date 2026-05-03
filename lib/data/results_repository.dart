import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_result.dart';

class ResultsRepository {
  static const _key = 'game_results';

  static Future<List<GameResult>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final results = raw
        .map((s) => GameResult.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    results.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return results;
  }

  static Future<void> save(GameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(result.toJson()));
    if (raw.length > 200) raw.removeRange(0, raw.length - 200);
    await prefs.setStringList(_key, raw);
  }
}
