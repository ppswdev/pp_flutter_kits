import 'dart:async';
import 'dart:typed_data';
import 'apple_music_player_platform_interface.dart';

/// 重复播放模式枚举
enum RepeatMode {
  /// 不循环（默认模式）
  none,

  /// 单曲循环
  one,

  /// 列表循环
  all,

  /// 随机播放
  shuffle,
}

/// 播放状态枚举
enum PlaybackState {
  /// 停止
  stopped,

  /// 播放中
  playing,

  /// 暂停
  paused,
}

/// 媒体项目类
class MediaItem {
  /// 唯一标识符
  final String persistentID;

  /// 标题
  final String title;

  /// 艺术家
  final String artist;

  /// 专辑标题
  final String albumTitle;

  /// 专辑艺术家
  final String albumArtist;

  /// 播放时长（秒）
  final double playbackDuration;

  /// 专辑封面数据
  final Uint8List? artworkData;

  MediaItem({
    required this.persistentID,
    required this.title,
    required this.artist,
    required this.albumTitle,
    required this.albumArtist,
    required this.playbackDuration,
    this.artworkData,
  });

  /// 从Map创建MediaItem
  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
        persistentID: map['persistentID'] as String,
        title: map['title'] as String? ?? '',
        artist: map['artist'] as String? ?? '',
        albumTitle: map['albumTitle'] as String? ?? '',
        albumArtist: map['albumArtist'] as String? ?? '',
        playbackDuration: map['playbackDuration'] as double? ?? 0.0,
        artworkData: map['artworkData'] != null
            ? (map['artworkData'] as Uint8List)
            : null);
  }

  @override
  String toString() {
    return 'MediaItem{persistentID: $persistentID, title: $title, artist: $artist}';
  }
}

/// Apple Music 播放器插件
class AppleMusicPlayer {
  /// 播放器事件流
  ///
  /// onMusicListUpdated 音乐列表更新回调
  /// onPlaybackStateChanged 播放状态变化回调
  /// onPlaybackProgressUpdate 播放进度变化回调
  /// onNowPlayingItemChanged 当前播放项目变化回调
  /// onRepeatModeChanged 播放模式变化回调
  /// onError 错误回调
  Stream<(String, Map<String, dynamic>)> get onPlayerEvents {
    return AppleMusicPlayerPlatform.instance.onEventStream
        .where((event) => event['event'] != null)
        .map((event) {
      try {
        final eventType = event['event'] as String;
        final eventData = Map<String, dynamic>.from(event)..remove('event');
        return (eventType, eventData);
      } catch (e) {
        return ('error', {'desc': e.toString()});
      }
    });
  }

  /// 获取平台版本
  Future<String?> getPlatformVersion() {
    return AppleMusicPlayerPlatform.instance.getPlatformVersion();
  }

  /// 同步所有音乐
  Future<void> syncAllMusic() {
    return AppleMusicPlayerPlatform.instance.syncAllMusic();
  }

  /// 打开媒体选择器
  Future<void> openMediaPicker() {
    return AppleMusicPlayerPlatform.instance.openMediaPicker();
  }

  /// 播放
  Future<void> play() {
    return AppleMusicPlayerPlatform.instance.play();
  }

  /// 暂停
  Future<void> pause() {
    return AppleMusicPlayerPlatform.instance.pause();
  }

  /// 停止
  Future<void> stop() {
    return AppleMusicPlayerPlatform.instance.stop();
  }

  /// 切换播放状态
  Future<void> togglePlayPause() {
    return AppleMusicPlayerPlatform.instance.togglePlayPause();
  }

  /// 设置播放位置
  Future<void> seekToTime(double time) {
    return AppleMusicPlayerPlatform.instance.seekToTime(time);
  }

  /// 跳转到开始
  Future<void> skipToBeginning() {
    return AppleMusicPlayerPlatform.instance.skipToBeginning();
  }

  /// 跳转到上一首
  Future<void> skipToPreviousItem() {
    return AppleMusicPlayerPlatform.instance.skipToPreviousItem();
  }

  /// 跳转到下一首
  Future<void> skipToNextItem() {
    return AppleMusicPlayerPlatform.instance.skipToNextItem();
  }

  /// 设置播放模式
  ///
  /// [mode] 播放模式
  Future<void> setRepeatMode(RepeatMode mode) {
    return AppleMusicPlayerPlatform.instance.setRepeatMode(mode.name);
  }

  /// 播放当前队列
  Future<void> playCurrentQueue() {
    return AppleMusicPlayerPlatform.instance.playCurrentQueue();
  }

  /// 播放队列
  ///
  /// [persistentIDs] 音乐列表的唯一标识符列表
  Future<void> playQueue(List<String> persistentIDs) {
    return AppleMusicPlayerPlatform.instance.playQueue(persistentIDs);
  }

  /// 播放项目
  ///
  /// [persistentID] 音乐的唯一标识符
  Future<void> playItem(String persistentID) {
    return AppleMusicPlayerPlatform.instance.playItem(persistentID);
  }
}
