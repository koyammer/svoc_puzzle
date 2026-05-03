import 'package:flutter/material.dart';
import '../models/question.dart';
import '../data/questions.dart';
import '../theme/app_theme.dart';
import 'decompose_game_screen.dart';
import 'pattern_game_screen.dart';
import 'shared_widgets.dart';

enum GameMode { decompose, pattern }

class LevelSelectScreen extends StatelessWidget {
  final GameMode mode;

  const LevelSelectScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final isDecompose = mode == GameMode.decompose;
    final gradient =
        isDecompose ? AppTheme.decomposeGradient : AppTheme.patternGradient;

    return Scaffold(
      appBar: LevelSelectAppBar(
        title: isDecompose ? '分解モード' : '文型判断モード',
        gradient: gradient,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'レベルを選んでください',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '下から順番に学習するのがおすすめです',
              style: TextStyle(color: Colors.black45, fontSize: 13),
            ),
            const SizedBox(height: 28),
            _LevelCard(
              number: '1',
              title: '基本文',
              description: 'SV / SVC / SVO の短い文',
              extra: '主語・動詞・目的語・補語の基本を習得',
              color: const Color(0xFF10B981),
              questionCount: level1Questions.length,
              onTap: () => _startGame(context, 1),
            ),
            const SizedBox(height: 14),
            _LevelCard(
              number: '2',
              title: '発展文',
              description: 'SVOO / SVOC の文',
              extra: 'O が2つある文、O と C の違いを学ぶ',
              color: const Color(0xFF4361EE),
              questionCount: level2Questions.length,
              onTap: () => _startGame(context, 2),
            ),
            const SizedBox(height: 14),
            _LevelCard(
              number: '3',
              title: '修飾語あり',
              description: 'M（修飾語）を含む文',
              extra: '時間・場所・頻度などの修飾語を見抜く',
              color: const Color(0xFF9B5DE5),
              questionCount: level3Questions.length,
              onTap: () => _startGame(context, 3),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, int level) {
    final questions = ([..._questionsForLevel(level)]..shuffle()).take(5).toList();
    final route = mode == GameMode.decompose
        ? MaterialPageRoute(
            builder: (_) => DecomposeGameScreen(
              questions: questions,
              levelName: 'Level $level',
              level: level,
            ),
          )
        : MaterialPageRoute(
            builder: (_) => PatternGameScreen(
              questions: questions,
              levelName: 'Level $level',
              level: level,
            ),
          );
    Navigator.push(context, route);
  }

  List<Question> _questionsForLevel(int level) => switch (level) {
        1 => level1Questions,
        2 => level2Questions,
        _ => level3Questions,
      };
}

class _LevelCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final String extra;
  final Color color;
  final int questionCount;
  final VoidCallback onTap;

  const _LevelCard({
    required this.number,
    required this.title,
    required this.description,
    required this.extra,
    required this.color,
    required this.questionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(width: 5, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          number,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '全$questionCount問 / 5問出題',
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              description,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              extra,
                              style: const TextStyle(
                                  color: Colors.black38, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, color: color, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


