import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'apple_music_player_method_channel.dart';

abstract class AppleMusicPlayerPlatform extends PlatformInterface {
  /// Constructs a AppleMusicPlayerPlatform.
  AppleMusicPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppleMusicPlayerPlatform _instance = MethodChannelAppleMusicPlayer();

  /// The default instance of [AppleMusicPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelAppleMusicPlayer].
  static AppleMusicPlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppleMusicPlayerPlatform] when
  /// they register themselves.
  static set instance(AppleMusicPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<Map<String, dynamic>> get onEventStream;

  Future<String?> getPlatformVersion();

  Future<void> syncAllMusic();

  Future<void> openMediaPicker();

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> togglePlayPause();

  Future<void> seekToTime(double time);

  Future<void> skipToBeginning();

  Future<void> skipToPreviousItem();

  Future<void> skipToNextItem();

  Future<void> setRepeatMode(String mode);

  Future<void> playCurrentQueue();

  Future<void> playQueue(List<String> persistentIDs);

  Future<void> playItem(String persistentID);
}
