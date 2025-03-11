import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'now_playing_info_method_channel.dart';

abstract class NowPlayingInfoPlatform extends PlatformInterface {
  /// Constructs a NowPlayingInfoPlatform.
  NowPlayingInfoPlatform() : super(token: _token);

  static final Object _token = Object();

  static NowPlayingInfoPlatform _instance = MethodChannelNowPlayingInfo();

  /// The default instance of [NowPlayingInfoPlatform] to use.
  ///
  /// Defaults to [MethodChannelNowPlayingInfo].
  static NowPlayingInfoPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NowPlayingInfoPlatform] when
  /// they register themselves.
  static set instance(NowPlayingInfoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// 更新锁屏界面和控制中心的媒体信息
  ///
  /// [title] 标题，必填
  /// [artist] 艺术家/歌手，必填
  /// [album] 专辑名称，可选
  /// [albumArt] 专辑封面图片的base64编码字符串，可选
  /// [duration] 音频总时长（毫秒），可选
  /// [position] 当前播放位置（毫秒），可选
  /// [isPlaying] 是否正在播放，默认为false
  Future<bool> updateNowPlayingInfo({
    required String title,
    required String artist,
    String? album,
    String? albumArt,
    int? duration,
    int? position,
    bool isPlaying = false,
  }) {
    throw UnimplementedError(
        'updateNowPlayingInfo() has not been implemented.');
  }
}
