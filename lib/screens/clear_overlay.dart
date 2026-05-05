import 'dart:math';
import 'package:flutter/material.dart';
import '../services/sound_service.dart';

void showClearOverlay({
  required BuildContext context,
  required int score,
  required int correct,
  required int total,
  required VoidCallback onHome,
  required VoidCallback onRetry,
}) {
  SoundService.instance.playClear();
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (ctx, a1, a2) => _ClearOverlay(
      score: score,
      correct: correct,
      total: total,
      onHome: onHome,
      onRetry: onRetry,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _ClearOverlay extends StatefulWidget {
  final int score;
  final int correct;
  final int total;
  final VoidCallback onHome;
  final VoidCallback onRetry;

  const _ClearOverlay({
    required this.score,
    required this.correct,
    required this.total,
    required this.onHome,
    required this.onRetry,
  });

  @override
  State<_ClearOverlay> createState() => _ClearOverlayState();
}

class _ClearOverlayState extends State<_ClearOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _confettiCtrl;

  late final Animation<double> _bgFade;
  late final Animation<double> _trophyScale;
  late final Animation<double> _titleFade;
  late final Animation<double> _scoreValue;
  late final Animation<double> _starsFade;
  late final Animation<double> _buttonFade;

  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(48, (_) => _Particle.random());

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _bgFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
    );
    _trophyScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.05, 0.45, curve: Curves.elasticOut),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.28, 0.52, curve: Curves.easeOut),
    );
    _scoreValue = Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.32, 0.76, curve: Curves.easeOut),
      ),
    );
    _starsFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.58, 0.82, curve: Curves.easeOut),
    );
    _buttonFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.76, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  int get _stars {
    if (widget.correct == widget.total) return 3;
    if (widget.correct >= widget.total * 0.6) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([_mainCtrl, _confettiCtrl]),
        builder: (ctx, _) => Stack(
          children: [
            // Background
            Opacity(
              opacity: _bgFade.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A1040), Color(0xFF0B0620)],
                  ),
                ),
              ),
            ),

            // Confetti
            CustomPaint(
              size: Size.infinite,
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _confettiCtrl.value,
              ),
            ),

            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy
                      Transform.scale(
                        scale: _trophyScale.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFF9F1C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9F1C)
                                    .withValues(alpha: 0.55),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.emoji_events_rounded,
                              color: Colors.white, size: 54),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Title
                      Opacity(
                        opacity: _titleFade.value,
                        child: Column(
                          children: [
                            const Text(
                              '全問クリア！',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                      color: Colors.white38, blurRadius: 24)
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.correct} / ${widget.total} 問正解',
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Score card
                      Opacity(
                        opacity: _titleFade.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 44, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.14),
                                width: 1.5),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_scoreValue.value.round()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 62,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                '点',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Stars
                      Opacity(
                        opacity: _starsFade.value,
                        child: _StarsRow(
                            stars: _stars, animProgress: _starsFade.value),
                      ),
                      const SizedBox(height: 36),

                      // Buttons
                      Opacity(
                        opacity: _buttonFade.value,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(
                                      color: Colors.white30, width: 1.5),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  widget.onHome();
                                },
                                child: const Text('ホームへ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9F1C),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  widget.onRetry();
                                },
                                child: const Text('もう一度',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stars ────────────────────────────────────────────────────────────────────

class _StarsRow extends StatelessWidget {
  final int stars;
  final double animProgress;
  const _StarsRow({required this.stars, required this.animProgress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final threshold = i * 0.33;
        final raw = (animProgress - threshold) / 0.34;
        final t = raw.clamp(0.0, 1.0);
        final smooth = t * t * (3 - 2 * t);
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Transform.scale(
            scale: filled ? smooth : 1.0,
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 48,
              color: filled ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.2),
              shadows: filled
                  ? const [Shadow(color: Color(0xFFFFD700), blurRadius: 20)]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Confetti ─────────────────────────────────────────────────────────────────

class _Particle {
  final double x;
  final double y0;
  final double speed;
  final Color color;
  final double size;
  final bool isRect;
  final double rotSpeed;
  final double driftAmp;
  final double driftFreq;

  const _Particle({
    required this.x,
    required this.y0,
    required this.speed,
    required this.color,
    required this.size,
    required this.isRect,
    required this.rotSpeed,
    required this.driftAmp,
    required this.driftFreq,
  });

  static final _rng = Random();
  static const _palette = [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFFFF9F1C),
    Color(0xFFAB83FF),
    Color(0xFFFF69B4),
    Color(0xFF96CEB4),
  ];

  factory _Particle.random() => _Particle(
        x: _rng.nextDouble(),
        y0: -_rng.nextDouble() * 0.7,
        speed: 0.5 + _rng.nextDouble() * 0.85,
        color: _palette[_rng.nextInt(_palette.length)],
        size: 5.0 + _rng.nextDouble() * 7.0,
        isRect: _rng.nextBool(),
        rotSpeed: (_rng.nextDouble() - 0.5) * 7,
        driftAmp: 0.01 + _rng.nextDouble() * 0.025,
        driftFreq: 0.8 + _rng.nextDouble() * 1.5,
      );
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final rawY = p.y0 + p.speed * progress;
      final yFrac = (rawY % 1.0 + 1.0) % 1.0;
      final y = yFrac * size.height;
      final xDrift = p.driftAmp * sin(2 * pi * p.driftFreq * progress);
      final x = ((p.x + xDrift).clamp(0.0, 1.0)) * size.width;
      final rot = p.rotSpeed * progress * pi;

      paint.color = p.color.withValues(alpha: 0.88);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      if (p.isRect) {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.52),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
