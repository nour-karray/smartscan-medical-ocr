import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class AppFeedbackService {
  AppFeedbackService._();

  static final AppFeedbackService instance = AppFeedbackService._();
  static const String _tapSoundAsset = 'sounds/ui_tap.wav';

  AudioPlayer? _player;

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  void configure({required bool soundEnabled, required bool vibrationEnabled}) {
    _soundEnabled = soundEnabled;
    _vibrationEnabled = vibrationEnabled;
  }

  Future<void> tap() => _play(
    fallback: HapticFeedback.selectionClick,
    duration: 48,
    amplitude: 110,
    strongSound: false,
  );

  Future<void> success() => _play(
    fallback: HapticFeedback.mediumImpact,
    duration: 96,
    amplitude: 170,
    strongSound: true,
  );

  Future<void> error() => _playPattern(
    fallback: HapticFeedback.heavyImpact,
    pattern: const [0, 120, 70, 190],
    intensities: const [0, 140, 0, 220],
    strongSound: true,
  );

  Future<void> _play({
    required Future<void> Function() fallback,
    required int duration,
    required int amplitude,
    required bool strongSound,
  }) async {
    if (kIsWeb) return;
    try {
      await _playSound(strong: strongSound);

      if (!_vibrationEnabled) return;

      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != true) {
        await fallback();
        return;
      }

      final amplitudeSupported = await Vibration.hasAmplitudeControl();
      if (amplitudeSupported == true) {
        await Vibration.vibrate(duration: duration, amplitude: amplitude);
      } else {
        await Vibration.vibrate(duration: duration);
      }
    } catch (_) {
      try {
        await fallback();
      } catch (_) {}
    }
  }

  Future<void> _playPattern({
    required Future<void> Function() fallback,
    required List<int> pattern,
    required List<int> intensities,
    required bool strongSound,
  }) async {
    if (kIsWeb) return;
    try {
      await _playSound(strong: strongSound);

      if (!_vibrationEnabled) return;

      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != true) {
        await fallback();
        return;
      }

      final customSupport = await Vibration.hasCustomVibrationsSupport();
      final amplitudeSupported = await Vibration.hasAmplitudeControl();
      if (customSupport == true) {
        if (amplitudeSupported == true) {
          await Vibration.vibrate(pattern: pattern, intensities: intensities);
        } else {
          await Vibration.vibrate(pattern: pattern);
        }
      } else {
        await Vibration.vibrate(duration: 120);
        await Future<void>.delayed(const Duration(milliseconds: 90));
        await Vibration.vibrate(duration: 180);
      }
    } catch (_) {
      try {
        await fallback();
      } catch (_) {}
    }
  }

  Future<void> _playSound({required bool strong}) async {
    if (!_soundEnabled) return;
    try {
      final player = _player ??= AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.stop();
      await player.play(
        AssetSource(_tapSoundAsset),
        volume: strong ? 0.7 : 0.45,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      try {
        await SystemSound.play(
          strong ? SystemSoundType.alert : SystemSoundType.click,
        );
      } catch (_) {}
    }
  }
}
