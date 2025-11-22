import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../common/logger.dart';

/// 音频池，用于实现多个音效的并发播放
class AudioPool {
  final List<AudioPlayer> players;
  int currentPlayerIndex = 0;

  /// 构造方法
  ///
  /// [size] 表示音频池的播放器数量
  AudioPool(int size) : players = List.generate(size, (_) => AudioPlayer());

  /// 播放音效
  ///
  /// [assetPath] 资源文件路径(如: 'sounds/win_sound.mp3')
  ///
  /// 示例：
  /// ```dart
  /// await audioPool.play('sounds/click.mp3');
  /// ```
  ///
  /// 返回：Future<void>
  Future<void> play(String assetPath) async {
    final player = players[currentPlayerIndex];
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    await player.play(AssetSource(assetPath));
  }
}

/// 特效工具类，提供音效与触感反馈功能
class EffectUtil {
  static final EffectUtil _instance = EffectUtil._internal();

  /// 单例访问
  static EffectUtil get instance => _instance;
  factory EffectUtil() => _instance;
  EffectUtil._internal();

  /// 私有音频池列表
  final _audioPool = [AudioPool(5), AudioPool(3)];

  /// 点击反馈特效，结合触感与音效
  ///
  /// [enableHapticFeedback] 是否启用触感反馈，默认 false
  /// [level] 触感反馈强度（1: 轻，2: 普通，3: 中等，4: 重），默认 1
  /// [enableSound] 是否启用音效，默认 false
  /// [audioAssetPath] 音效资源路径，如 'assets/sounds/win_sound.mp3'
  ///
  /// 示例：
  /// ```dart
  /// EffectUtil().tapFeedbackEffect(
  ///   enableHapticFeedback: true,
  ///   level: 2,
  ///   enableSound: true,
  ///   audioAssetPath: 'assets/sounds/win_sound.mp3',
  /// );
  /// ```
  ///
  /// 返回结果：无返回值
  void tapFeedbackEffect({
    bool enableHapticFeedback = false,
    int level = 1,
    bool enableSound = false,
    String audioAssetPath = '',
  }) {
    if (enableHapticFeedback) {
      hapticFeedbackImpact(level: level);
    }
    if (enableSound) {
      tapSoundEffect(audioAssetPath);
    }
  }

  /// 播放点击音效（复用音频池0）
  ///
  /// [assetPath] 音效资源文件路径，如 'assets/sounds/win_sound.mp3'
  ///
  /// 示例：
  /// ```dart
  /// EffectUtil().tapSoundEffect('assets/sounds/win_sound.mp3');
  /// ```
  ///
  /// 返回结果：Future<void>
  void tapSoundEffect(String assetPath) async {
    Logger.log('Playing sound from: $assetPath');
    try {
      // audioplayers的AssetSource参数不需要'assets/'前缀
      await _audioPool[0].play(assetPath.replaceAll('assets/', ''));
    } catch (e) {
      Logger.log('Error playing sound: $e');
    }
  }

  /// 播放普通音效（复用音频池1）
  ///
  /// [assetPath] 音效资源文件路径，如 'assets/sounds/win_sound.mp3'
  ///
  /// 示例：
  /// ```dart
  /// EffectUtil().playSoundEffect('assets/sounds/win_sound.mp3');
  /// ```
  ///
  /// 返回结果：Future<void>
  void playSoundEffect(String assetPath) async {
    Logger.log('Playing sound from: $assetPath');
    try {
      await _audioPool[1].play(assetPath.replaceAll('assets/', ''));
    } catch (e) {
      Logger.log('Error playing sound: $e');
    }
  }

  /// 停止所有音效的播放（只作用于池1）
  ///
  /// 示例：
  /// ```dart
  /// EffectUtil().stopSounds();
  /// ```
  ///
  /// 返回结果：无
  void stopSounds() {
    for (var player in _audioPool[1].players) {
      player.stop();
    }
  }

  /// 触感反馈
  ///
  /// [level] 强度（1: 轻，2: 有力度轻，3: 有力度中，4: 有力度重, 其他: 默认震动）
  ///
  /// 示例：
  /// ```dart
  /// EffectUtil().hapticFeedbackImpact(level: 3);
  /// ```
  ///
  /// 返回结果：无
  void hapticFeedbackImpact({int level = 1}) {
    switch (level) {
      case 1:
        HapticFeedback.selectionClick();
        break;
      case 2:
        HapticFeedback.lightImpact();
        break;
      case 3:
        HapticFeedback.mediumImpact();
        break;
      case 4:
        HapticFeedback.heavyImpact();
        break;
      default:
        HapticFeedback.vibrate();
    }
  }
}
