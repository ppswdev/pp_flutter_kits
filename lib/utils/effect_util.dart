import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../common/logger.dart';

class AudioPool {
  final List<AudioPlayer> _players;
  int _currentPlayerIndex = 0;

  AudioPool(int size) : _players = List.generate(size, (_) => AudioPlayer());

  Future<void> play(String assetPath) async {
    final player = _players[_currentPlayerIndex];
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    await player.play(AssetSource(assetPath));
  }
}

/// 特效工具类
class EffectUtil {
  static final EffectUtil _instance = EffectUtil._internal();
  factory EffectUtil() => _instance;
  EffectUtil._internal();

  final _audioPool = [AudioPool(5), AudioPool(3)];

  /// 点击反馈特效
  void tapFeedbackEffect({
    bool enableHapticFeedback = false,
    int level = 1,
    bool enableSound = false,
    String audioAssetPath = '',
  }) {
    if (enableHapticFeedback) {
      hapticFeedbackImpact();
    }
    if (enableSound) {
      _tapSoundEffect(audioAssetPath);
    }
  }

  /// 点击音效
  /// assetPath : 'assets/sounds/win_sound.mp3'
  void _tapSoundEffect(String assetPath) async {
    Logger.log('Playing sound from: $assetPath');
    try {
      await _audioPool[0].play(assetPath.replaceAll('assets/', ''));
    } catch (e) {
      Logger.log('Error playing sound: $e');
    }
  }

  /// 播放音效的方法
  /// assetPath : 'assets/sounds/win_sound.mp3'
  void playSoundEffect(String assetPath) async {
    Logger.log('Playing sound from: $assetPath');
    try {
      await _audioPool[1].play(assetPath.replaceAll('assets/', ''));
    } catch (e) {
      Logger.log('Error playing sound: $e');
    }
  }

  /// 触感反馈
  void hapticFeedbackImpact({int level = 1}) {
    switch (level) {
      case 1:
        HapticFeedback.lightImpact();
        break;
      case 2:
        HapticFeedback.mediumImpact();
        break;
      case 3:
        HapticFeedback.heavyImpact();
        break;
      default:
        HapticFeedback.vibrate();
    }
  }
}
