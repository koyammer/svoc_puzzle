import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF4158D0),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.homeGradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.extension_rounded,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SVOCパズル',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'バージョン 1.0.0',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              _Section(
                title: 'このアプリについて',
                child: const Text(
                  'SVOCパズルは、英語の文法構造（SVOC）をゲーム感覚で学べる学習アプリです。\n\n'
                  '分解モードでは単語を正しい役割のスロットへ配置し、文型判断モードでは英文の文型を素早く見抜く力を鍛えます。\n\n'
                  '4段階のレベルと連続正解コンボで、楽しく・継続して学習できます。',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
              ),
              _Section(
                title: 'プライバシーポリシー',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PrivacyRow(
                      icon: Icons.storage_rounded,
                      text: 'プレイ履歴はお使いの端末内にのみ保存されます。',
                    ),
                    const SizedBox(height: 10),
                    _PrivacyRow(
                      icon: Icons.cloud_off_rounded,
                      text: '個人情報・プレイデータを外部サーバーへ送信することは一切ありません。',
                    ),
                    const SizedBox(height: 10),
                    _PrivacyRow(
                      icon: Icons.analytics_outlined,
                      text: '広告・アクセス解析・トラッキングは使用していません。',
                    ),
                    const SizedBox(height: 10),
                    _PrivacyRow(
                      icon: Icons.no_accounts_rounded,
                      text: 'アカウント登録や個人情報の入力は不要です。',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color(0xFF1A1040),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PrivacyRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF667EEA)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
