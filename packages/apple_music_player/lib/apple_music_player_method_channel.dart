import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'apple_music_player_platform_interface.dart';

/// An implementation of [AppleMusicPlayerPlatform] that uses method channels.
class MethodChannelAppleMusicPlayer extends AppleMusicPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('apple_music_player');
  final EventChannel _eventChannel = EventChannel('apple_music_player_events');

  Stream<Map<String, dynamic>>? _eventStream;

  @override
  Stream<Map<String, dynamic>> get onEventStream {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
    return _eventStream!;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> syncAllMusic() async {
    await methodChannel.invokeMethod<void>('syncAllMusic');
  }

  @override
  Future<void> openMediaPicker() async {
    await methodChannel.invokeMethod<void>('openMediaPicker');
  }

  @override
  Future<void> play() async {
    await methodChannel.invokeMethod<void>('play');
  }

  @override
  Future<void> pause() async {
    await methodChannel.invokeMethod<void>('pause');
  }

  @override
  Future<void> stop() async {
    await methodChannel.invokeMethod<void>('stop');
  }

  @override
  Future<void> togglePlayPause() async {
    await methodChannel.invokeMethod<void>('togglePlayPause');
  }

  @override
  Future<void> seekToTime(double time) async {
    await methodChannel.invokeMethod<void>('seekToTime', time);
  }

  @override
  Future<void> skipToBeginning() async {
    await methodChannel.invokeMethod<void>('skipToBeginning');
  }

  @override
  Future<void> skipToPreviousItem() async {
    await methodChannel.invokeMethod<void>('skipToPreviousItem');
  }

  @override
  Future<void> skipToNextItem() async {
    await methodChannel.invokeMethod<void>('skipToNextItem');
  }

  @override
  Future<void> setRepeatMode(String mode) async {
    await methodChannel.invokeMethod<void>('setRepeatMode', mode);
  }

  @override
  Future<void> playCurrentQueue() async {
    await methodChannel.invokeMethod<void>('playCurrentQueue');
  }

  @override
  Future<void> playQueue(List<String> persistentIDs) async {
    await methodChannel.invokeMethod<void>('playQueue', persistentIDs);
  }

  @override
  Future<void> playItem(String persistentID) async {
    await methodChannel.invokeMethod<void>('playItem', persistentID);
  }
}
