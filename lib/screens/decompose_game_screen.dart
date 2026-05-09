import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import '../data/results_repository.dart';
import '../models/game_result.dart';
import '../models/question.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'clear_overlay.dart';
import 'shared_widgets.dart';

class _SlotState {
  final String role;
  final int index;
  String? filledToken;

  _SlotState({required this.role, required this.index});

  String get id => '${role}_$index';
  bool get isFilled => filledToken != null;
}

class DecomposeGameScreen extends StatefulWidget {
  final List<Question> questions;
  final String levelName;
  final int level;

  const DecomposeGameScreen({
    super.key,
    required this.questions,
    required this.levelName,
    required this.level,
  });

  @override
  State<DecomposeGameScreen> createState() => _DecomposeGameScreenState();
}

class _DecomposeGameScreenState extends State<DecomposeGameScreen> {
  late final List<Question> _questions;
  int _questionIndex = 0;
  String? _selectedToken;
  late List<_SlotState> _slots;
  late List<String> _shuffledTokens;
  final Map<String, bool> _slotError = {};
  int _mistakesOnQuestion = 0;
  int _score = 0;
  int _combo = 0;
  int _correctCount = 0;
  bool _questionComplete = false;
  int _lastPoints = 0;

  Question get _question => _questions[_questionIndex];
  bool get _allPlaced =>
      _slots.where((s) => s.isFilled).length == _shuffledTokens.length;

  @override
  void initState() {
    super.initState();
    _questions = [...widget.questions]..shuffle();
    _initQuestion();
  }

  void _initQuestion() {
    // Always show all 6 slots so the pattern is not revealed
    _slots = [
      _SlotState(role: 'S', index: 0),
      _SlotState(role: 'V', index: 0),
      _SlotState(role: 'O', index: 0),
      _SlotState(role: 'O', index: 1),
      _SlotState(role: 'C', index: 0),
      _SlotState(role: 'M', index: 0),
    ];
    _shuffledTokens = [..._question.tokens];
    _selectedToken = null;
    _slotError.clear();
    _mistakesOnQuestion = 0;
    _questionComplete = false;
    _lastPoints = 0;
  }

  void _tapWord(String token) {
    if (_questionComplete) return;
    SoundService.instance.playTap();
    final slot = _slots.where((s) => s.filledToken == token).firstOrNull;
    if (slot != null) {
      setState(() {
        slot.filledToken = null;
        _selectedToken = token;
      });
      return;
    }
    setState(() {
      _selectedToken = _selectedToken == token ? null : token;
    });
  }

  void _tapSlot(_SlotState slot) {
    if (_questionComplete) return;

    if (_selectedToken == null) {
      if (slot.isFilled) {
        SoundService.instance.playTap();
        setState(() {
          _selectedToken = slot.filledToken;
          slot.filledToken = null;
        });
      }
      return;
    }

    final token = _selectedToken!;
    if (slot.isFilled) return;

    SoundService.instance.playSlotFill();
    setState(() {
      slot.filledToken = token;
      _selectedToken = null;
    });
  }

  void _checkAnswers() {
    final incorrectIds = <String>[];

    for (final slot in _slots.where((s) => s.isFilled)) {
      if (_question.roleFor(slot.filledToken!) != slot.role) {
        incorrectIds.add(slot.id);
        _mistakesOnQuestion++;
      }
    }

    if (incorrectIds.isEmpty) {
      _completeQuestion();
      return;
    }

    SoundService.instance.playWrong();
    setState(() {
      for (final id in incorrectIds) {
        final slot = _slots.firstWhere((s) => s.id == id);
        _slotError[slot.id] = true;
        slot.filledToken = null;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _slotError.clear());
    });
  }

  void _completeQuestion() {
    SoundService.instance.playCorrect();
    setState(() {
      if (_mistakesOnQuestion == 0) {
        _combo++;
        _lastPoints = 10 * _combo;
        _correctCount++;
      } else {
        _lastPoints = 10;
        _combo = 0;
      }
      _score += _lastPoints;
      _questionComplete = true;
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
        _initQuestion();
      });
    } else {
      _showFinishDialog();
    }
  }

  void _showFinishDialog() {
    unawaited(ResultsRepository.save(GameResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playedAt: DateTime.now(),
      mode: 'decompose',
      level: widget.level,
      score: _score,
      correct: _correctCount,
      total: _questions.length,
    )));
    showClearOverlay(
      context: context,
      score: _score,
      correct: _correctCount,
      total: _questions.length,
      onHome: () => Navigator.of(context).pop(),
      onRetry: () => setState(() {
        _questionIndex = 0;
        _score = 0;
        _combo = 0;
        _correctCount = 0;
        _questions.shuffle();
        _initQuestion();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _question;
    final progress = (_questionIndex + 1) / _questions.length;
    final unplacedTokens =
        _shuffledTokens.where((t) => !_slots.any((s) => s.filledToken == t)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: GameAppBar(
        title: widget.levelName,
        gradient: AppTheme.decomposeGradient,
        progress: progress,
        questionIndex: _questionIndex,
        questionTotal: _questions.length,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GameScoreBar(
                score: _score,
                combo: _combo,
                iconColor: const Color(0xFF667EEA)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GameSentenceCard(
                        key: ValueKey(_questionIndex),
                        sentence: q.sentence,
                        shadowColor: const Color(0xFF667EEA),
                        translation: q.translation),
                    const SizedBox(height: 14),

                    if (_questionComplete)
                      _CompleteBanner(
                        perfect: _mistakesOnQuestion == 0,
                        points: _lastPoints,
                        combo: _combo,
                      )
                    else
                      _InstructionBadge(
                        selectedToken: _selectedToken,
                        allPlaced: _allPlaced,
                      ),

                    const SizedBox(height: 14),

                    // Slots
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: _slots
                          .map((slot) => _SlotBox(
                                slot: slot,
                                hasError: _slotError.containsKey(slot.id),
                                isActive: _selectedToken != null &&
                                    !_questionComplete,
                                allComplete: _questionComplete,
                                onTap: _questionComplete
                                    ? null
                                    : () => _tapSlot(slot),
                              ))
                          .toList(),
                    ),

                    const Spacer(),

                    if (!_questionComplete) ...[
                      // 確認ボタン（全部置いたら出現）
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _allPlaced
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Center(
                                  child: _ConfirmButton(
                                      onTap: _checkAnswers),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const _SectionLabel('単語バンク（順番はランダムです）'),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: unplacedTokens
                            .map((token) => _WordChip(
                                  token: token,
                                  selected: _selectedToken == token,
                                  onTap: () => _tapWord(token),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
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

// ─── Sub-widgets ─────────────────────────────────────────────

class _CompleteBanner extends StatelessWidget {
  final bool perfect;
  final int points;
  final int combo;
  const _CompleteBanner(
      {required this.perfect, required this.points, required this.combo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        gradient: perfect
            ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)])
            : const LinearGradient(
                colors: [Color(0xFF34D399), Color(0xFF10B981)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            perfect
                ? Icons.auto_awesome_rounded
                : Icons.check_circle_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  perfect ? 'パーフェクト！' : 'クリア！',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                Text(
                  '+$points 点${combo >= 2 ? "  🔥 $comboコンボ！" : ""}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionBadge extends StatelessWidget {
  final String? selectedToken;
  final bool allPlaced;
  const _InstructionBadge(
      {required this.selectedToken, required this.allPlaced});

  @override
  Widget build(BuildContext context) {
    if (allPlaced) {
      return Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded,
                  color: Color(0xFF10B981), size: 15),
              SizedBox(width: 6),
              Text(
                '全部置けた！↓ 確認ボタンで答え合わせ',
                style: TextStyle(
                  color: Color(0xFF059669),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (selectedToken != null) {
      return Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF4361EE).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF4361EE).withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.touch_app_rounded,
                  color: Color(0xFF4361EE), size: 15),
              const SizedBox(width: 6),
              Text(
                '"$selectedToken" を選択中 → スロットをタップ',
                style: const TextStyle(
                  color: Color(0xFF4361EE),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const Center(
      child: Text(
        '単語をタップして選択 → スロットに配置',
        style: TextStyle(color: Colors.black38, fontSize: 13),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ConfirmButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppTheme.decomposeGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4361EE).withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              '確認する',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: const Color(0xFF667EEA)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _SlotBox extends StatelessWidget {
  final _SlotState slot;
  final bool hasError;
  final bool isActive;
  final bool allComplete;
  final VoidCallback? onTap;

  const _SlotBox({
    required this.slot,
    required this.hasError,
    required this.isActive,
    required this.allComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = AppTheme.roleColor(slot.role);
    final lightColor = AppTheme.roleLightColor(slot.role);

    Color bgColor;
    Color borderColor;
    Color wordColor;
    bool showGlow = false;

    if (hasError) {
      bgColor = const Color(0xFFFFF0F0);
      borderColor = const Color(0xFFE63946);
      wordColor = const Color(0xFFE63946);
    } else if (allComplete && slot.isFilled) {
      bgColor = lightColor;
      borderColor = roleColor;
      wordColor = roleColor;
    } else if (slot.isFilled) {
      // 配置済み・未確認：ニュートラル
      bgColor = const Color(0xFFF5F7FF);
      borderColor = Colors.grey.shade300;
      wordColor = Colors.black87;
    } else if (isActive) {
      bgColor = lightColor.withValues(alpha: 0.4);
      borderColor = roleColor.withValues(alpha: 0.5);
      wordColor = roleColor;
      showGlow = true;
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey.shade200;
      wordColor = Colors.black26;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 78, minHeight: 66),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: roleColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : (allComplete && slot.isFilled)
                  ? [
                      BoxShadow(
                        color: roleColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: hasError
                    ? const Color(0xFFE63946)
                    : (allComplete && slot.isFilled)
                        ? roleColor
                        : roleColor.withValues(alpha: isActive ? 1.0 : 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                slot.role,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (slot.isFilled)
              Text(
                slot.filledToken!,
                style: TextStyle(
                  color: wordColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              )
            else
              Text(
                '   ',
                style: TextStyle(
                  color: borderColor.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String token;
  final bool selected;
  final VoidCallback onTap;

  const _WordChip({
    required this.token,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.decomposeGradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF667EEA).withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.07),
              blurRadius: selected ? 12 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          token,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
