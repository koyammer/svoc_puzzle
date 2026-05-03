import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import '../data/results_repository.dart';
import '../models/game_result.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

class PatternGameScreen extends StatefulWidget {
  final List<Question> questions;
  final String levelName;
  final int level;

  const PatternGameScreen({
    super.key,
    required this.questions,
    required this.levelName,
    required this.level,
  });

  @override
  State<PatternGameScreen> createState() => _PatternGameScreenState();
}

class _PatternGameScreenState extends State<PatternGameScreen> {
  late final List<Question> _questions;
  int _questionIndex = 0;
  int _score = 0;
  int _combo = 0;
  int _correctCount = 0;
  String? _selectedChoice;
  bool _answered = false;
  late List<String> _choices;

  Question get _question => _questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _questions = [...widget.questions]..shuffle();
    _generateChoices();
  }

  void _generateChoices() {
    const l1Patterns = ['SV', 'SVC', 'SVO'];
    const allPatterns = ['SV', 'SVC', 'SVO', 'SVOO', 'SVOC'];
    final pool = _question.level == 1 ? l1Patterns : allPatterns;
    final correct = _question.pattern;
    final others = [...pool.where((p) => p != correct)]..shuffle();
    _choices = [correct, ...others.take(2)]..shuffle();
  }

  void _selectAnswer(String pattern) {
    if (_answered) return;
    final correct = pattern == _question.pattern;
    setState(() {
      _selectedChoice = pattern;
      _answered = true;
      if (correct) {
        _combo++;
        _score += 10 * _combo;
        _correctCount++;
      } else {
        _combo = 0;
      }
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_questionIndex < widget.questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedChoice = null;
        _answered = false;
        _generateChoices();
      });
    } else {
      _showFinishDialog();
    }
  }

  void _showFinishDialog() {
    unawaited(ResultsRepository.save(GameResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playedAt: DateTime.now(),
      mode: 'pattern',
      level: widget.level,
      score: _score,
      correct: _correctCount,
      total: _questions.length,
    )));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('全問クリア！',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: Color(0xFFFF9F1C), size: 56),
            const SizedBox(height: 12),
            Text(
              '$_score 点',
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF5576C)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('ホームへ'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _questions.shuffle();
                _questionIndex = 0;
                _score = 0;
                _combo = 0;
                _correctCount = 0;
                _selectedChoice = null;
                _answered = false;
                _generateChoices();
              });
            },
            child: const Text('もう一度'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _question;
    final progress = (_questionIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: GameAppBar(
        title: widget.levelName,
        gradient: AppTheme.patternGradient,
        progress: progress,
        questionIndex: _questionIndex,
        questionTotal: widget.questions.length,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GameScoreBar(
                score: _score,
                combo: _combo,
                iconColor: const Color(0xFFF5576C)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),
                    const Text(
                      'この英文の文型は？',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GameSentenceCard(
                        sentence: q.sentence,
                        shadowColor: const Color(0xFFF5576C)),
                    const SizedBox(height: 32),
                    if (_answered)
                      _FeedbackBanner(
                        correct: _selectedChoice == q.pattern,
                        correctPattern: q.pattern,
                        combo: _combo,
                      )
                    else
                      const Text(
                        '文型を選んでください',
                        style:
                            TextStyle(color: Colors.black38, fontSize: 13),
                      ),
                    const SizedBox(height: 28),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 14,
                      runSpacing: 14,
                      children: _choices.map((choice) {
                        _ChoiceState state;
                        if (_answered) {
                          if (choice == q.pattern) {
                            state = _ChoiceState.correct;
                          } else if (choice == _selectedChoice) {
                            state = _ChoiceState.wrong;
                          } else {
                            state = _ChoiceState.dimmed;
                          }
                        } else {
                          state = _ChoiceState.idle;
                        }
                        return _ChoiceButton(
                          pattern: choice,
                          state: state,
                          onTap:
                              _answered ? null : () => _selectAnswer(choice),
                        );
                      }).toList(),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────

class _FeedbackBanner extends StatelessWidget {
  final bool correct;
  final String correctPattern;
  final int combo;
  const _FeedbackBanner({
    required this.correct,
    required this.correctPattern,
    required this.combo,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: correct
            ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)])
            : const LinearGradient(
                colors: [Color(0xFFE63946), Color(0xFFC92A2A)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (correct ? const Color(0xFF10B981) : const Color(0xFFE63946))
                .withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            correct
                ? '正解！ $correctPattern${combo >= 2 ? "  🔥 $comboコンボ！" : ""}'
                : '不正解… 正解は $correctPattern',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChoiceState { idle, correct, wrong, dimmed }

class _ChoiceButton extends StatelessWidget {
  final String pattern;
  final _ChoiceState state;
  final VoidCallback? onTap;

  const _ChoiceButton({
    required this.pattern,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Decoration decoration;
    final Color textColor;

    switch (state) {
      case _ChoiceState.correct:
        decoration = BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        );
        textColor = Colors.white;
      case _ChoiceState.wrong:
        decoration = BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFE63946), Color(0xFFC92A2A)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE63946).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        );
        textColor = Colors.white;
      case _ChoiceState.dimmed:
        decoration = BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        );
        textColor = Colors.grey.shade400;
      case _ChoiceState.idle:
        decoration = BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        );
        textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        height: 72,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          pattern,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
