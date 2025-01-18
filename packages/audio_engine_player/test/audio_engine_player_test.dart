import 'package:flutter_test/flutter_test.dart';
import 'package:audio_engine_player/audio_engine_player.dart';
import 'package:audio_engine_player/audio_engine_player_platform_interface.dart';
import 'package:audio_engine_player/audio_engine_player_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAudioEnginePlayerPlatform
    with MockPlatformInterfaceMixin
    implements AudioEnginePlayerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> appendToPlaylist(
      String source, String title, String artist, String album, bool autoPlay) {
    // TODO: implement appendToPlaylist
    throw UnimplementedError();
  }

  @override
  Future<void> clearCaches() {
    // TODO: implement clearCaches
    throw UnimplementedError();
  }

  @override
  Future<int> currentPlayIndex() {
    // TODO: implement currentPlayIndex
    throw UnimplementedError();
  }

  @override
  Future<int> duration() {
    // TODO: implement duration
    throw UnimplementedError();
  }

  @override
  Future<bool> enableFadeEffect() {
    // TODO: implement enableFadeEffect
    throw UnimplementedError();
  }

  @override
  Future<void> ensureEngineRunning() {
    // TODO: implement ensureEngineRunning
    throw UnimplementedError();
  }

  @override
  Future<bool> isMute() {
    // TODO: implement isMute
    throw UnimplementedError();
  }

  @override
  Future<bool> isPlaying() {
    // TODO: implement isPlaying
    throw UnimplementedError();
  }

  @override
  Future<void> moveOnPlaylist(int oldIndex, int newIndex) {
    // TODO: implement moveOnPlaylist
    throw UnimplementedError();
  }

  @override
  // TODO: implement onEventStream
  Stream<Map<String, dynamic>> get onEventStream => throw UnimplementedError();

  @override
  Future<void> pause() {
    // TODO: implement pause
    throw UnimplementedError();
  }

  @override
  Future<void> play(
      String filePath, String title, String artist, String album) {
    // TODO: implement play
    throw UnimplementedError();
  }

  @override
  Future<void> playNext() {
    // TODO: implement playNext
    throw UnimplementedError();
  }

  @override
  Future<void> playOrPause() {
    // TODO: implement playOrPause
    throw UnimplementedError();
  }

  @override
  Future<void> playPrevious() {
    // TODO: implement playPrevious
    throw UnimplementedError();
  }

  @override
  Future<void> removeFromPlaylist(int index) {
    // TODO: implement removeFromPlaylist
    throw UnimplementedError();
  }

  @override
  Future<void> resetAll() {
    // TODO: implement resetAll
    throw UnimplementedError();
  }

  @override
  Future<void> seekTo(int milliseconds) {
    // TODO: implement seekTo
    throw UnimplementedError();
  }

  @override
  Future<void> seekToIndex(int index) {
    // TODO: implement seekToIndex
    throw UnimplementedError();
  }

  @override
  Future<void> setBandGain(int bandIndex, double gain) {
    // TODO: implement setBandGain
    throw UnimplementedError();
  }

  @override
  Future<void> setEnableFadeEffect(bool value) {
    // TODO: implement setEnableFadeEffect
    throw UnimplementedError();
  }

  @override
  Future<void> setLoopMode(int mode) {
    // TODO: implement setLoopMode
    throw UnimplementedError();
  }

  @override
  Future<void> setMute(bool value) {
    // TODO: implement setMute
    throw UnimplementedError();
  }

  @override
  Future<void> setPlaylist(List<Map<String, String>> tracks, bool autoPlay) {
    // TODO: implement setPlaylist
    throw UnimplementedError();
  }

  @override
  Future<void> setReverb(int id, double wetDryMix) {
    // TODO: implement setReverb
    throw UnimplementedError();
  }

  @override
  Future<void> setSpeed(double value) {
    // TODO: implement setSpeed
    throw UnimplementedError();
  }

  @override
  Future<void> setVolume(double value) {
    // TODO: implement setVolume
    throw UnimplementedError();
  }

  @override
  Future<void> setVolumeBoost(double value) {
    // TODO: implement setVolumeBoost
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
    throw UnimplementedError();
  }

  @override
  Future<double> volume() {
    // TODO: implement volume
    throw UnimplementedError();
  }
}

void main() {
  final AudioEnginePlayerPlatform initialPlatform =
      AudioEnginePlayerPlatform.instance;

  test('$MethodChannelAudioEnginePlayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAudioEnginePlayer>());
  });
}
