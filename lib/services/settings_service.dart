import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService._();
  static final instance = SettingsService._();

  static const _keySound = 'pref_sound';
  static const _keyOnboarded = 'pref_onboarded';

  late SharedPreferences _prefs;
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get isOnboarded => _prefs.getBool(_keyOnboarded) ?? false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _soundEnabled = _prefs.getBool(_keySound) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _prefs.setBool(_keySound, value);
  }

  Future<void> markOnboarded() async {
    await _prefs.setBool(_keyOnboarded, true);
  }
}
