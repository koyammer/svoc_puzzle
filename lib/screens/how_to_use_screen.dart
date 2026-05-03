import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: LevelSelectAppBar(
        title: '使い方',
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF4158D0), Color(0xFF764BA2)],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: const [
          _RolesSection(),
          SizedBox(height: 24),
          _ModeSection(
            icon: Icons.extension_rounded,
            title: '分解モード',
            gradient: AppTheme.decomposeGradient,
            steps: [
              _Step(
                number: '1',
                title: '英文を読む',
                description: '画面上部に英文が表示されます。意味と構造をよく考えましょう。',
              ),
              _Step(
                number: '2',
                title: '単語を選んでスロットに配置',
                description: '単語バンクの単語をタップして選択し、S・V・O・O・C・M のスロットにタップして配置します。',
              ),
              _Step(
                number: '3',
                title: '使わないスロットは空のまま',
                description: '文型に応じて不要なスロットは空のまま残します。どのスロットが必要かを自分で判断することがポイントです。',
              ),
              _Step(
                number: '4',
                title: '確認ボタンで答え合わせ',
                description: '全ての単語を配置したら「確認する」ボタンが現れます。タップすると一括で正誤判定されます。間違った単語は赤く光って戻ってきます。',
              ),
            ],
          ),
          SizedBox(height: 24),
          _ModeSection(
            icon: Icons.flash_on_rounded,
            title: '文型判断モード',
            gradient: AppTheme.patternGradient,
            steps: [
              _Step(
                number: '1',
                title: '英文を読む',
                description: '画面に英文が表示されます。文の構造を素早く分析しましょう。',
              ),
              _Step(
                number: '2',
                title: '文型を3択から選ぶ',
                description: 'SV・SVC・SVO・SVOO・SVOC の中から正しい文型をタップして選びます。',
              ),
              _Step(
                number: '3',
                title: '即座にフィードバック',
                description: '正解は緑、不正解は赤で表示されます。自動で次の問題へ進みます。',
              ),
            ],
          ),
          SizedBox(height: 24),
          _ScoreSection(),
          SizedBox(height: 24),
          _LevelSection(),
        ],
      ),
    );
  }
}

// ─── 文の要素セクション ────────────────────────────────────────

class _RolesSection extends StatelessWidget {
  const _RolesSection();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.school_rounded,
            title: '文の要素（SVOCM）とは',
            color: Color(0xFF4158D0),
          ),
          const SizedBox(height: 14),
          const _RoleRow('S', '主語', 'Subject', '動作や状態の主体。', Color(0xFF4361EE)),
          const _RoleRow('V', '動詞', 'Verb', '動作や状態を表す。', Color(0xFFE63946)),
          const _RoleRow('O', '目的語', 'Object', '動詞の対象となるもの。', Color(0xFF10B981)),
          const _RoleRow('C', '補語', 'Complement', 'S や O の状態・性質を説明する。', Color(0xFFFF9F1C)),
          const _RoleRow('M', '修飾語', 'Modifier', '時間・場所・頻度などを表す。', Color(0xFF9B5DE5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '例：She gave me a book yesterday.\n'
              '  S=She　V=gave　O=me, a book　M=yesterday',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleRow extends StatelessWidget {
  final String label;
  final String jp;
  final String en;
  final String desc;
  final Color color;
  const _RoleRow(this.label, this.jp, this.en, this.desc, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$jp（$en）',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── モードセクション ─────────────────────────────────────────

class _ModeSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final LinearGradient gradient;
  final List<_Step> steps;

  const _ModeSection({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.map((step) => _StepRow(step: step, gradient: gradient)),
        ],
      ),
    );
  }
}

class _Step {
  final String number;
  final String title;
  final String description;
  const _Step({
    required this.number,
    required this.title,
    required this.description,
  });
}

class _StepRow extends StatelessWidget {
  final _Step step;
  final LinearGradient gradient;
  const _StepRow({required this.step, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Text(
              step.number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.5,
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

// ─── スコアセクション ─────────────────────────────────────────

class _ScoreSection extends StatelessWidget {
  const _ScoreSection();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.stars_rounded,
            title: 'スコアとコンボ',
            color: Color(0xFFFF9F1C),
          ),
          const SizedBox(height: 14),
          const Text(
            '正解すると連続コンボが積み上がり、得点が倍増します。',
            style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ComboItem('1連続', '10点', const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _ComboItem('2連続', '20点', const Color(0xFFFF9F1C)),
              const SizedBox(width: 8),
              _ComboItem('3連続', '30点', const Color(0xFFE63946)),
              const SizedBox(width: 8),
              _ComboItem('n連続', '10×n点', const Color(0xFF9B5DE5)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFDFA0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFFFF9F1C), size: 15),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '分解モードはミスなし完答、文型判断モードは初回正解でコンボが続きます。',
                    style: TextStyle(color: Color(0xFFB36A00), fontSize: 11),
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

class _ComboItem extends StatelessWidget {
  final String label;
  final String score;
  final Color color;
  const _ComboItem(this.label, this.score, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              score,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.black45, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── レベルセクション ─────────────────────────────────────────

class _LevelSection extends StatelessWidget {
  const _LevelSection();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.bar_chart_rounded,
            title: 'レベルについて',
            color: Color(0xFF4361EE),
          ),
          const SizedBox(height: 14),
          const _LevelRow(
            number: '1',
            title: '基本文',
            desc: 'SV / SVC / SVO の短い文',
            color: Color(0xFF10B981),
          ),
          const _LevelRow(
            number: '2',
            title: '発展文',
            desc: 'SVOO / SVOC の文',
            color: Color(0xFF4361EE),
          ),
          const _LevelRow(
            number: '3',
            title: '修飾語あり',
            desc: 'M（修飾語）を含む文',
            color: Color(0xFF9B5DE5),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.shuffle_rounded, color: Color(0xFF4361EE), size: 15),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '各レベル32問のプールから毎回ランダムで5問出題されます。',
                    style: TextStyle(color: Color(0xFF3050B0), fontSize: 11),
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

class _LevelRow extends StatelessWidget {
  final String number;
  final String title;
  final String desc;
  final Color color;
  const _LevelRow({
    required this.number,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                desc,
                style:
                    const TextStyle(color: Colors.black45, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 共通パーツ ───────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
