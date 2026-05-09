import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LevelSelectAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final LinearGradient gradient;

  const LevelSelectAppBar(
      {super.key, required this.title, required this.gradient});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
    );
  }
}

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final LinearGradient gradient;
  final double progress;
  final int questionIndex;
  final int questionTotal;

  const GameAppBar({
    super.key,
    required this.title,
    required this.gradient,
    required this.progress,
    required this.questionIndex,
    required this.questionTotal,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Q${questionIndex + 1} / $questionTotal',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: Column(
        children: [
          Expanded(
            child: Container(decoration: BoxDecoration(gradient: gradient)),
          ),
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }
}

class GameScoreBar extends StatelessWidget {
  final int score;
  final int combo;
  final Color iconColor;

  const GameScoreBar({
    super.key,
    required this.score,
    required this.combo,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.stars_rounded, color: iconColor, size: 20),
          const SizedBox(width: 6),
          Text(
            '$score',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const Text(
            ' 点',
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),
          const Spacer(),
          if (combo > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: AppTheme.comboGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9F1C).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$combo コンボ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class GameSentenceCard extends StatefulWidget {
  final String sentence;
  final Color shadowColor;
  final String? translation;

  const GameSentenceCard({
    super.key,
    required this.sentence,
    required this.shadowColor,
    this.translation,
  });

  @override
  State<GameSentenceCard> createState() => _GameSentenceCardState();
}

class _GameSentenceCardState extends State<GameSentenceCard> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            widget.sentence,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              height: 1.4,
            ),
          ),
        ),
        if (widget.translation != null) ...[
          const SizedBox(height: 8),
          Center(
            child: _TranslationButton(
              translation: widget.translation!,
              isShowing: _showTranslation,
              onTap: () => setState(() => _showTranslation = !_showTranslation),
            ),
          ),
        ],
      ],
    );
  }
}

class _TranslationButton extends StatelessWidget {
  final String translation;
  final bool isShowing;
  final VoidCallback onTap;

  const _TranslationButton({
    required this.translation,
    required this.isShowing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minWidth: 120),
        padding: EdgeInsets.symmetric(
          horizontal: isShowing ? 20 : 14,
          vertical: isShowing ? 11 : 7,
        ),
        decoration: BoxDecoration(
          color: isShowing
              ? Colors.black.withValues(alpha: 0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: isShowing
              ? Text(
                  translation,
                  key: const ValueKey('t'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                )
              : Row(
                  key: const ValueKey('b'),
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.translate_rounded,
                        size: 13, color: Colors.black38),
                    SizedBox(width: 5),
                    Text(
                      '日本語訳を見る',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
