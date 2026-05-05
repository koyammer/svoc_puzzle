import 'dart:async' show unawaited;
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._() {
    for (int i = 0; i < 5; i++) {
      _pool.add(AudioPlayer());
    }
  }
  static final SoundService instance = SoundService._();

  static const int _sr = 44100;
  final List<AudioPlayer> _pool = [];
  int _idx = 0;

  // Pre-generated WAV bytes (lazy)
  late final Uint8List _tapWav = _wav(_tone(1100, 35, 0.45, atk: 2, rel: 18));
  late final Uint8List _slotWav = _wav(_tone(750, 55, 0.50, atk: 5, rel: 25));
  late final Uint8List _c5Wav = _wav(_tone(523.25, 90, 0.60, atk: 4, rel: 40));
  late final Uint8List _e5Wav = _wav(_tone(659.25, 90, 0.60, atk: 4, rel: 40));
  late final Uint8List _g5Wav = _wav(_tone(783.99, 140, 0.65, atk: 4, rel: 60));
  late final Uint8List _wrongWav = _wav(_chirp(280, 140, 190, 0.50));
  late final Uint8List _navWav = _wav(_tone(950, 42, 0.35, atk: 3, rel: 18));

  AudioPlayer get _next {
    final p = _pool[_idx];
    _idx = (_idx + 1) % _pool.length;
    return p;
  }

  void playTap() => unawaited(_next.play(BytesSource(_tapWav)));
  void playSlotFill() => unawaited(_next.play(BytesSource(_slotWav)));
  void playWrong() => unawaited(_next.play(BytesSource(_wrongWav)));
  void playNavigation() => unawaited(_next.play(BytesSource(_navWav)));

  void playCorrect() {
    unawaited(_next.play(BytesSource(_c5Wav)));
    Future.delayed(const Duration(milliseconds: 95), () => unawaited(_next.play(BytesSource(_e5Wav))));
    Future.delayed(const Duration(milliseconds: 190), () => unawaited(_next.play(BytesSource(_g5Wav))));
  }

  /// 5-note ascending fanfare: G4 → C5 → E5 → G5 → C6
  void playClear() {
    _scheduleNote(392.0, 65, 0.55, 0);
    _scheduleNote(523.25, 65, 0.55, 80);
    _scheduleNote(659.25, 65, 0.60, 160);
    _scheduleNote(783.99, 65, 0.62, 240);
    _scheduleNote(1046.5, 340, 0.68, 320);
  }

  void _scheduleNote(double freq, int ms, double amp, int delayMs) {
    final bytes = _wav(_tone(freq, ms, amp, atk: 2, rel: ms * 0.35));
    if (delayMs == 0) {
      unawaited(_next.play(BytesSource(bytes)));
    } else {
      Future.delayed(Duration(milliseconds: delayMs),
          () => unawaited(_next.play(BytesSource(bytes))));
    }
  }

  // ─── DSP helpers ─────────────────────────────────────────────────────────

  /// Pure sine + 2nd harmonic tone with smoothstep envelope.
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

  /// Exponential frequency sweep (chirp) — used for wrong-answer sound.
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
    b.setUint16(20, 1, Endian.little);  // PCM
    b.setUint16(22, 1, Endian.little);  // mono
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
