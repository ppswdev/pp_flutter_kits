import 'now_playing_info_platform_interface.dart';

class NowPlayingInfo {
  Future<String?> getPlatformVersion() {
    return NowPlayingInfoPlatform.instance.getPlatformVersion();
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
  ///
  /// 返回更新是否成功
  Future<bool> updateNowPlayingInfo({
    required String title,
    required String artist,
    String? album,
    String? albumArt,
    int? duration,
    int? position,
    bool isPlaying = false,
  }) {
    return NowPlayingInfoPlatform.instance.updateNowPlayingInfo(
      title: title,
      artist: artist,
      album: album,
      albumArt: albumArt,
      duration: duration,
      position: position,
      isPlaying: isPlaying,
    );
  }
}
