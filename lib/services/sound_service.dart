import 'dart:async' show unawaited;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'settings_service.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const int _sr = 44100;
  final List<AudioPlayer> _pool = [];
  int _idx = 0;
  bool _ready = false;

  late String _tapPath, _slotPath, _wrongPath, _navPath;
  late String _corC5Path, _corE5Path, _corG5Path;
  late String _clrG4Path, _clrC5Path, _clrE5Path, _clrG5Path, _clrC6Path;

  /// アプリ起動時に一度だけ呼ぶ。
  /// ambient カテゴリ = 消音スイッチがオフのときだけ再生。
  Future<void> init() async {
    await AudioPlayer.global.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
      ),
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
    ));

    for (int i = 0; i < 5; i++) {
      _pool.add(AudioPlayer());
    }

    // WAV をテンポラリファイルに書き出して DeviceFileSource で再生する。
    // BytesSource は iOS 実機で不安定なため使用しない。
    final d = Directory.systemTemp.path;
    _tapPath   = await _write('$d/svoc_tap.wav',    _tone(1100,   35, 0.45, atk: 2, rel: 18));
    _slotPath  = await _write('$d/svoc_slot.wav',   _tone(750,    55, 0.50, atk: 5, rel: 25));
    _wrongPath = await _write('$d/svoc_wrong.wav',  _chirp(280, 140, 190, 0.50));
    _navPath   = await _write('$d/svoc_nav.wav',    _tone(950,    42, 0.35, atk: 3, rel: 18));
    _corC5Path = await _write('$d/svoc_cor_c5.wav', _tone(523.25, 90, 0.60, atk: 4, rel: 40));
    _corE5Path = await _write('$d/svoc_cor_e5.wav', _tone(659.25, 90, 0.60, atk: 4, rel: 40));
    _corG5Path = await _write('$d/svoc_cor_g5.wav', _tone(783.99,140, 0.65, atk: 4, rel: 60));
    _clrG4Path = await _write('$d/svoc_clr_g4.wav', _tone(392.0,  65, 0.55, atk: 2, rel: 65 * 0.35));
    _clrC5Path = await _write('$d/svoc_clr_c5.wav', _tone(523.25, 65, 0.55, atk: 2, rel: 65 * 0.35));
    _clrE5Path = await _write('$d/svoc_clr_e5.wav', _tone(659.25, 65, 0.60, atk: 2, rel: 65 * 0.35));
    _clrG5Path = await _write('$d/svoc_clr_g5.wav', _tone(783.99, 65, 0.62, atk: 2, rel: 65 * 0.35));
    _clrC6Path = await _write('$d/svoc_clr_c6.wav', _tone(1046.5,340, 0.68, atk: 2, rel: 340 * 0.35));

    _ready = true;
  }

  Future<String> _write(String path, List<int> samples) async {
    await File(path).writeAsBytes(_wav(samples));
    return path;
  }

  AudioPlayer get _next {
    final p = _pool[_idx];
    _idx = (_idx + 1) % _pool.length;
    return p;
  }

  bool get _on => _ready && SettingsService.instance.soundEnabled;

  void playTap()        { if (_on) unawaited(_next.play(DeviceFileSource(_tapPath))); }
  void playSlotFill()   { if (_on) unawaited(_next.play(DeviceFileSource(_slotPath))); }
  void playWrong()      { if (_on) unawaited(_next.play(DeviceFileSource(_wrongPath))); }
  void playNavigation() { if (_on) unawaited(_next.play(DeviceFileSource(_navPath))); }

  void playCorrect() {
    if (!_on) return;
    unawaited(_next.play(DeviceFileSource(_corC5Path)));
    Future.delayed(const Duration(milliseconds: 95),  () => unawaited(_next.play(DeviceFileSource(_corE5Path))));
    Future.delayed(const Duration(milliseconds: 190), () => unawaited(_next.play(DeviceFileSource(_corG5Path))));
  }

  void playClear() {
    if (!_on) return;
    _playAt(_clrG4Path, 0);
    _playAt(_clrC5Path, 80);
    _playAt(_clrE5Path, 160);
    _playAt(_clrG5Path, 240);
    _playAt(_clrC6Path, 320);
  }

  void _playAt(String path, int delayMs) {
    if (delayMs == 0) {
      unawaited(_next.play(DeviceFileSource(path)));
    } else {
      Future.delayed(Duration(milliseconds: delayMs),
          () => unawaited(_next.play(DeviceFileSource(path))));
    }
  }

  // ─── DSP helpers ─────────────────────────────────────────────────────────

  List<int> _tone(double freq, int ms, double amp, {double atk = 5, double rel = 20}) {
    final n = (_sr * ms / 1000).round();
    final a = (_sr * atk / 1000).round();
    final r = (_sr * rel / 1000).round();
    return List.generate(n, (i) {
      final env = _smoothstep(i, n, a, r);
      final t = i / _sr;
      final s = sin(2 * pi * freq * t) + sin(2 * pi * freq * 2 * t) * 0.2;
      return (s / 1.2 * env * amp * 32767).round().clamp(-32768, 32767);
    });
  }

  List<int> _chirp(double f0, double f1, int ms, double amp) {
    final n = (_sr * ms / 1000).round();
    final r = (_sr * 30.0 / 1000).round();
    var phase = 0.0;
    return List.generate(n, (i) {
      final t = i / n;
      final freq = f0 * pow(f1 / f0, t).toDouble();
      phase += 2 * pi * freq / _sr;
      final env = i >= n - r ? (n - i) / r : 1.0;
      return (sin(phase) * env * amp * 32767).round().clamp(-32768, 32767);
    });
  }

  double _smoothstep(int i, int n, int atk, int rel) {
    double x;
    if (i < atk) {
      x = atk > 0 ? i / atk : 1.0;
    } else if (i >= n - rel) {
      x = rel > 0 ? (n - i) / rel : 1.0;
    } else {
      return 1.0;
    }
    return x * x * (3 - 2 * x);
  }

  Uint8List _wav(List<int> samples) {
    final dataSize = samples.length * 2;
    final b = ByteData(44 + dataSize);
    void setChars(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        b.setUint8(offset + i, s.codeUnitAt(i));
      }
    }
    setChars(0, 'RIFF');
    b.setUint32(4, 36 + dataSize, Endian.little);
    setChars(8, 'WAVE');
    setChars(12, 'fmt ');
    b.setUint32(16, 16, Endian.little);
    b.setUint16(20, 1, Endian.little);
    b.setUint16(22, 1, Endian.little);
    b.setUint32(24, _sr, Endian.little);
    b.setUint32(28, _sr * 2, Endian.little);
    b.setUint16(32, 2, Endian.little);
    b.setUint16(34, 16, Endian.little);
    setChars(36, 'data');
    b.setUint32(40, dataSize, Endian.little);
    for (int i = 0; i < samples.length; i++) {
      b.setInt16(44 + i * 2, samples[i], Endian.little);
    }
    return b.buffer.asUint8List();
  }
}
