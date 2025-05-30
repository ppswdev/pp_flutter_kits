import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../common/logger.dart';

class AudioPool {
  final List<AudioPlayer> players;
  int currentPlayerIndex = 0;

  AudioPool(int size) : players = List.generate(size, (_) => AudioPlayer());

  Future<void> play(String assetPath) async {
    final player = players[currentPlayerIndex];
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    await player.play(AssetSource(assetPath));
  }
}

/// 特效工具类
class EffectUtil {
  static final EffectUtil _instance = EffectUtil._internal();
  static EffectUtil get instance => _instance;
  factory EffectUtil() => _instance;
  EffectUtil._internal();

  final _audioPool = [AudioPool(5), AudioPool(3)];

  /// 点击反馈特效
  /// enableHapticFeedback: 是否启用触感反馈
  /// level: 触感反馈强度
  /// enableSound: 是否启用音效
  /// audioAssetPath: 音效资源路径
  ///
  /// 使用示例
  /// void example() {
  ///   EffectUtil().tapFeedbackEffect(
  ///     enableHapticFeedback: true,
  ///     level: 1,
  ///     enableSound: true,
  ///     audioAssetPath: 'assets/sounds/win_sound.mp3',
  ///   );
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
      tapSoundEffect(audioAssetPath);
    }
  }

  /// 点击音效
  /// assetPath : 'assets/sounds/win_sound.mp3'
  void tapSoundEffect(String assetPath) async {
    Logger.log('Playing sound from: $assetPath');
    try {
      await _audioPool[0].play(assetPath.replaceAll('assets/', ''));
    } catch (e) {
      Logger.log('Error playing sound: $e');
    }
  }

  /// 播放音效的方法
  /// assetPath : 'assets/sounds/win_sound.mp3'
  ///
  /// 使用示例
  /// void example() {
  ///   EffectUtil().playSoundEffect('assets/sounds/win_sound.mp3');
  /// }
  void playSoundEffect(String assetPath) async {
    Logger.log('Playing sound from: $assetPath');
    try {
      await _audioPool[1].play(assetPath.replaceAll('assets/', ''));
    } catch (e) {
      Logger.log('Error playing sound: $e');
    }
  }

  /// 停止所有音效播放
  void stopSounds() {
    for (var player in _audioPool[1].players) {
      player.stop();
    }
  }

  /// 触感反馈
  /// level: 触感反馈强度
  ///
  /// 使用示例
  /// void example() {
  ///   EffectUtil().hapticFeedbackImpact(level: 1);
  /// }
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
