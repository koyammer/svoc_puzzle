import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'how_to_use_screen.dart';
import 'level_select_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.homeGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                _buildHeader(),
                const Spacer(flex: 3),
                _ModeCard(
                  icon: Icons.extension_rounded,
                  title: '分解モード',
                  subtitle: '単語を S / V / O / C / M に分類しよう',
                  gradient: AppTheme.decomposeGradient,
                  onTap: () {
                    SoundService.instance.playNavigation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LevelSelectScreen(mode: GameMode.decompose),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _ModeCard(
                  icon: Icons.flash_on_rounded,
                  title: '文型判断モード',
                  subtitle: '英文の文型を瞬時に見抜こう',
                  gradient: AppTheme.patternGradient,
                  onTap: () {
                    SoundService.instance.playNavigation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LevelSelectScreen(mode: GameMode.pattern),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SubButton(
                        icon: Icons.help_outline_rounded,
                        label: '使い方',
                        onTap: () {
                          SoundService.instance.playNavigation();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HowToUseScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SubButton(
                        icon: Icons.history_rounded,
                        label: 'プレイ履歴',
                        onTap: () {
                          SoundService.instance.playNavigation();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReportScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(22),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.5),
          ),
          child: const Icon(Icons.extension_rounded,
              color: Colors.white, size: 38),
        ),
        const SizedBox(height: 20),
        const Text(
          'SVOC',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 52,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'パ ズ ル',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 10,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _RolePill('S', '主語'),
            _RolePill('V', '動詞'),
            _RolePill('O', '目的語'),
            _RolePill('C', '補語'),
            _RolePill('M', '修飾語'),
          ],
        ),
      ],
    );
  }
}

class _RolePill extends StatelessWidget {
  final String label;
  final String jp;
  const _RolePill(this.label, this.jp);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          Text(
            jp,
            style: const TextStyle(color: Colors.white54, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _SubButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SubButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white60, size: 17),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  color: Colors.white70, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}
