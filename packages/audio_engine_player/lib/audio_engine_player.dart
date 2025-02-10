import 'dart:async';
import 'audio_engine_player_platform_interface.dart';

enum PlayerEventType {
  playbackProgress,
  playingStatus,
  playCompleted,
  playingIndex
}

class AudioEnginePlayer {
  Future<String?> get platformVersion async {
    return AudioEnginePlayerPlatform.instance.getPlatformVersion();
  }

  Future<int> get duration async {
    return AudioEnginePlayerPlatform.instance.duration();
  }

  Future<double> get volume async {
    return AudioEnginePlayerPlatform.instance.volume();
  }

  Future<bool> get isMute async {
    return AudioEnginePlayerPlatform.instance.isMute();
  }

  Future<int> get currentPlayIndex async {
    return AudioEnginePlayerPlatform.instance.currentPlayIndex();
  }

  Future<bool> get isPlaying async {
    return AudioEnginePlayerPlatform.instance.isPlaying();
  }

  Future<void> ensureEngineRunning() async {
    return AudioEnginePlayerPlatform.instance.ensureEngineRunning();
  }

  Future<void> playWith(String filePath, String title, String artist,
      String album, String albumArt) {
    return AudioEnginePlayerPlatform.instance
        .playWith(filePath, title, artist, album, albumArt);
  }

  Future<void> seekTo(int milliseconds) async {
    return AudioEnginePlayerPlatform.instance.seekTo(milliseconds);
  }

  Future<void> seekToIndex(int index) async {
    return AudioEnginePlayerPlatform.instance.seekToIndex(index);
  }

  Future<void> playOrPause() async {
    return AudioEnginePlayerPlatform.instance.playOrPause();
  }

  Future<void> play() async {
    return AudioEnginePlayerPlatform.instance.play();
  }

  Future<void> pause() async {
    return AudioEnginePlayerPlatform.instance.pause();
  }

  Future<void> stop() async {
    return AudioEnginePlayerPlatform.instance.stop();
  }

  Future<void> setPlaylist(List<Map<String, String>> tracks, bool autoPlay) {
    return AudioEnginePlayerPlatform.instance.setPlaylist(tracks, autoPlay);
  }

  Future<void> updatePlaylistInfos(List<Map<String, String>> tracks) {
    return AudioEnginePlayerPlatform.instance.updatePlaylistInfos(tracks);
  }

  Future<void> appendToPlaylist(String source, String title, String artist,
      String album, String albumArt, bool autoPlay) {
    return AudioEnginePlayerPlatform.instance
        .appendToPlaylist(source, title, artist, album, albumArt, autoPlay);
  }

  Future<void> removeFromPlaylist(int index) async {
    return AudioEnginePlayerPlatform.instance.removeFromPlaylist(index);
  }

  Future<void> moveOnPlaylist(int oldIndex, int newIndex) async {
    return AudioEnginePlayerPlatform.instance
        .moveOnPlaylist(oldIndex, newIndex);
  }

  Future<void> playNext() async {
    return AudioEnginePlayerPlatform.instance.playNext();
  }

  Future<void> playPrevious() async {
    return AudioEnginePlayerPlatform.instance.playPrevious();
  }

  Future<void> setSpeed(double value) async {
    return AudioEnginePlayerPlatform.instance.setSpeed(value);
  }

  Future<void> setVolume(double value) async {
    return AudioEnginePlayerPlatform.instance.setVolume(value);
  }

  Future<void> setVolumeBoost(double value) async {
    return AudioEnginePlayerPlatform.instance.setVolumeBoost(value);
  }

  Future<void> setMute(bool value) async {
    return AudioEnginePlayerPlatform.instance.setMute(value);
  }

  Future<void> setEnableFadeEffect(bool value) async {
    return AudioEnginePlayerPlatform.instance.setEnableFadeEffect(value);
  }

  Future<void> setLoopMode(int mode) async {
    return AudioEnginePlayerPlatform.instance.setLoopMode(mode);
  }

  Future<void> setBandGain(int bandIndex, double gain) async {
    return AudioEnginePlayerPlatform.instance.setBandGain(bandIndex, gain);
  }

  Future<void> setReverb(int id, double wetDryMix) async {
    return AudioEnginePlayerPlatform.instance.setReverb(id, wetDryMix);
  }

  Future<void> resetAll() async {
    return AudioEnginePlayerPlatform.instance.resetAll();
  }

  Future<void> clearCaches() async {
    return AudioEnginePlayerPlatform.instance.clearCaches();
  }

  Stream<(String, Map<String, dynamic>)> get onPlayerEvents {
    return AudioEnginePlayerPlatform.instance.onEventStream
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
}
