import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'shared_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = SettingsService.instance.soundEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: LevelSelectAppBar(
        title: '設定',
        gradient: const LinearGradient(
          colors: [Color(0xFF4158D0), Color(0xFF764BA2)],
        ),
      ),
      body: ListView(
        children: [
          _SectionHeader('サウンド'),
          _SettingsTile(
            icon: Icons.volume_up_rounded,
            iconColor: const Color(0xFF667EEA),
            title: 'サウンドエフェクト',
            subtitle: 'ボタン操作・正解・不正解の効果音',
            trailing: Switch.adaptive(
              value: _soundEnabled,
              activeThumbColor: const Color(0xFF667EEA),
              activeTrackColor: const Color(0xFF667EEA).withValues(alpha: 0.4),
              onChanged: (v) {
                setState(() => _soundEnabled = v);
                SettingsService.instance.setSoundEnabled(v);
              },
            ),
          ),
          _SectionHeader('情報'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF9B5DE5),
            title: 'このアプリについて',
            subtitle: 'バージョン情報・プライバシーポリシー',
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.black38),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF10B981),
            title: 'オープンソースライセンス',
            subtitle: '使用しているパッケージのライセンス',
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.black38),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'SVOCパズル',
              applicationVersion: '1.0.0',
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black45,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.black38, fontSize: 12)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
