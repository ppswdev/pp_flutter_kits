import 'package:flutter/services.dart';
import 'audio_engine_player_platform_interface.dart';

class MethodChannelAudioEnginePlayer extends AudioEnginePlayerPlatform {
  static const MethodChannel _channel = MethodChannel('audio_engine_player');
  static const EventChannel _eventChannel =
      EventChannel('audio_engine_player_events');

  Stream<Map<String, dynamic>>? _eventStream;

  @override
  Future<String?> getPlatformVersion() async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  Future<int> duration() async {
    final int duration = await _channel.invokeMethod('duration') ?? 0;
    return duration;
  }

  @override
  Future<double> volume() async {
    final double volume = await _channel.invokeMethod('isMute') ?? 1;
    return volume;
  }

  @override
  Future<bool> isMute() async {
    final bool isMute = await _channel.invokeMethod('isMute') ?? false;
    return isMute;
  }

  @override
  Future<bool> enableFadeEffect() async {
    final bool value = await _channel.invokeMethod('enableFadeEffect') ?? false;
    return value;
  }

  @override
  Future<int> currentPlayIndex() async {
    final int currentPlayIndex =
        await _channel.invokeMethod('currentPlayIndex') ?? 0;
    return currentPlayIndex;
  }

  @override
  Future<bool> isPlaying() async {
    final bool isPlaying = await _channel.invokeMethod('isPlaying') ?? false;
    return isPlaying;
  }

  @override
  Future<void> ensureEngineRunning() async {
    await _channel.invokeMethod('ensureEngineRunning');
  }

  @override
  Future<void> playWith(
      String filePath, String title, String artist, String album) async {
    await _channel.invokeMethod<void>('playWith', {
      'filePath': filePath,
      'title': title,
      'artist': artist,
      'album': album,
    });
  }

  @override
  Future<void> seekTo(int milliseconds) async {
    await _channel.invokeMethod('seekTo', {'milliseconds': milliseconds});
  }

  @override
  Future<void> seekToIndex(int index) async {
    await _channel.invokeMethod('seekToIndex', {'index': index});
  }

  @override
  Future<void> playOrPause() async {
    await _channel.invokeMethod('playOrPause');
  }

  @override
  Future<void> play() async {
    await _channel.invokeMethod('play');
  }

  @override
  Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  @override
  Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

  @override
  Future<void> setPlaylist(
      List<Map<String, String>> tracks, bool autoPlay) async {
    await _channel.invokeMethod<void>('setPlaylist', {
      'tracks': tracks,
      'autoPlay': autoPlay,
    });
  }

  @override
  Future<void> appendToPlaylist(String source, String title, String artist,
      String album, bool autoPlay) async {
    await _channel.invokeMethod<void>('appendToPlaylist', {
      'source': source,
      'title': title,
      'artist': artist,
      'album': album,
      'autoPlay': autoPlay,
    });
  }

  @override
  Future<void> removeFromPlaylist(int index) async {
    await _channel.invokeMethod('removeFromPlaylist', {'index': index});
  }

  @override
  Future<void> moveOnPlaylist(int oldIndex, int newIndex) async {
    await _channel.invokeMethod(
        'moveOnPlaylist', {'oldIndex': oldIndex, 'newIndex': newIndex});
  }

  @override
  Future<void> playNext() async {
    await _channel.invokeMethod('playNext');
  }

  @override
  Future<void> playPrevious() async {
    await _channel.invokeMethod('playPrevious');
  }

  @override
  Future<void> setSpeed(double value) async {
    await _channel.invokeMethod('setSpeed', {'speed': value});
  }

  @override
  Future<void> setVolume(double value) async {
    await _channel.invokeMethod('setVolume', {'volume': value});
  }

  @override
  Future<void> setVolumeBoost(double value) async {
    await _channel.invokeMethod('setVolumeBoost', {'gain': value});
  }

  @override
  Future<void> setMute(bool value) async {
    await _channel.invokeMethod('setMute', {'isMute': value});
  }

  @override
  Future<void> setEnableFadeEffect(bool value) async {
    await _channel
        .invokeMethod('setEnableFadeEffect', {'enableFadeEffect': value});
  }

  @override
  Future<void> setLoopMode(int mode) async {
    await _channel.invokeMethod('setLoopMode', {'mode': mode});
  }

  @override
  Future<void> setBandGain(int bandIndex, double gain) async {
    await _channel
        .invokeMethod('setBandGain', {'bandIndex': bandIndex, 'gain': gain});
  }

  @override
  Future<void> setReverb(int id, double wetDryMix) async {
    await _channel
        .invokeMethod('setReverb', {'id': id, 'wetDryMix': wetDryMix});
  }

  @override
  Future<void> resetAll() async {
    await _channel.invokeMethod('resetAll');
  }

  @override
  Future<void> clearCaches() async {
    await _channel.invokeMethod('clearCaches');
  }

  @override
  Stream<Map<String, dynamic>> get onEventStream {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
    return _eventStream!;
  }
}
