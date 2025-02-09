import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'audio_engine_player_method_channel.dart';

abstract class AudioEnginePlayerPlatform extends PlatformInterface {
  AudioEnginePlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioEnginePlayerPlatform _instance = MethodChannelAudioEnginePlayer();

  static AudioEnginePlayerPlatform get instance => _instance;

  static set instance(AudioEnginePlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();

  Future<int> duration();

  Future<double> volume();

  Future<bool> isMute();

  Future<bool> enableFadeEffect();

  Future<int> currentPlayIndex();

  Future<bool> isPlaying();

  Future<void> ensureEngineRunning();

  Future<void> playWith(String filePath, String title, String artist,
      String album, String albumArt);

  Future<void> seekTo(int milliseconds);

  Future<void> seekToIndex(int index);

  Future<void> playOrPause();

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> setPlaylist(List<Map<String, String>> tracks, bool autoPlay);

  Future<void> appendToPlaylist(String source, String title, String artist,
      String album, String albumArt, bool autoPlay);

  Future<void> removeFromPlaylist(int index);

  Future<void> moveOnPlaylist(int oldIndex, int newIndex);

  Future<void> playNext();

  Future<void> playPrevious();

  Future<void> setSpeed(double value);

  Future<void> setVolume(double value);

  Future<void> setVolumeBoost(double value);

  Future<void> setMute(bool value);

  Future<void> setEnableFadeEffect(bool value);

  Future<void> setLoopMode(int mode);

  Future<void> setBandGain(int bandIndex, double gain);

  Future<void> setReverb(int id, double wetDryMix);

  Future<void> resetAll();

  Future<void> clearCaches();

  Stream<Map<String, dynamic>> get onEventStream;
}
