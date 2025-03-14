import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'now_playing_info_platform_interface.dart';

/// An implementation of [NowPlayingInfoPlatform] that uses method channels.
class MethodChannelNowPlayingInfo extends NowPlayingInfoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('now_playing_info');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> updateNowPlayingInfo({
    required String title,
    required String artist,
    String? album,
    String? albumArt,
    int? duration,
    int? position,
    bool isPlaying = false,
  }) async {
    try {
      final result =
          await methodChannel.invokeMethod<bool>('updateNowPlayingInfo', {
        'title': title,
        'artist': artist,
        'album': album,
        'albumArt': albumArt,
        'duration': duration,
        'position': position,
        'isPlaying': isPlaying,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('更新媒体信息失败: $e');
      return false;
    }
  }
}
