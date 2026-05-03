import 'package:flutter/material.dart';
import '../data/results_repository.dart';
import '../models/game_result.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Future<List<GameResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = ResultsRepository.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: LevelSelectAppBar(
        title: 'プレイ履歴',
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF4158D0), Color(0xFF764BA2)],
        ),
      ),
      body: FutureBuilder<List<GameResult>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: results.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _SummaryCard(results: results);
              return _ResultCard(result: results[index - 1]);
            },
          );
        },
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_rounded, size: 64, color: Colors.black12),
          const SizedBox(height: 16),
          const Text(
            'まだ記録がありません',
            style: TextStyle(color: Colors.black38, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'ゲームをプレイすると履歴が表示されます',
            style: TextStyle(color: Colors.black26, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final List<GameResult> results;
  const _SummaryCard({required this.results});

  @override
  Widget build(BuildContext context) {
    final totalPlays = results.length;
    final totalCorrect = results.fold(0, (sum, r) => sum + r.correct);
    final totalQuestions = results.fold(0, (sum, r) => sum + r.total);
    final accuracy =
        totalQuestions == 0 ? 0.0 : totalCorrect / totalQuestions;
    final bestScore =
        results.fold(0, (best, r) => r.score > best ? r.score : best);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4158D0), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4158D0).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(
            label: '総プレイ数',
            value: '$totalPlays 回',
            icon: Icons.sports_esports_rounded,
          ),
          _VertDivider(),
          _StatItem(
            label: '正解率',
            value: '${(accuracy * 100).round()}%',
            icon: Icons.percent_rounded,
          ),
          _VertDivider(),
          _StatItem(
            label: '最高スコア',
            value: '$bestScore 点',
            icon: Icons.emoji_events_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

// ─── Result card ──────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final GameResult result;
  const _ResultCard({required this.result});

  String get _modeLabel => result.mode == 'decompose' ? '分解' : '文型判断';
  Color get _modeColor => result.mode == 'decompose'
      ? const Color(0xFF667EEA)
      : const Color(0xFFF5576C);

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 0) return '今日 $time';
    if (diff.inDays == 1) return '昨日 $time';
    return '${dt.month}/${dt.day} $time';
  }

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (result.accuracy * 100).round();
    final isGood = accuracyPct >= 80;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mode + level badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _modeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _modeLabel,
                  style: TextStyle(
                    color: _modeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Lv.${result.level}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Date + correct count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(result.playedAt),
                  style: const TextStyle(color: Colors.black38, fontSize: 11),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      isGood
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 14,
                      color: isGood
                          ? const Color(0xFF10B981)
                          : Colors.black26,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '正解 ${result.correct} / ${result.total} 問',
                      style: TextStyle(
                        color: isGood
                            ? const Color(0xFF059669)
                            : Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.score}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  color: Color(0xFF4361EE),
                ),
              ),
              const Text(
                '点',
                style: TextStyle(color: Colors.black38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
