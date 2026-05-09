import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/settings_service.dart';
import 'services/sound_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.instance.init();
  await SoundService.instance.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(SVOCPuzzleApp(showOnboarding: !SettingsService.instance.isOnboarded));
}

class SVOCPuzzleApp extends StatelessWidget {
  final bool showOnboarding;
  const SVOCPuzzleApp({super.key, this.showOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SVOCパズル',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
