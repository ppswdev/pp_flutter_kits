import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pp_shazam_kit_method_channel.dart';

abstract class PPShazamKitPlatform extends PlatformInterface {
  /// Constructs a PpShazamKitPlatform.
  PPShazamKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static PPShazamKitPlatform _instance = MethodChannelPpShazamKit();

  /// The default instance of [PPShazamKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelPpShazamKit].
  static PPShazamKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PPShazamKitPlatform] when
  /// they register themselves.
  static set instance(PPShazamKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Stream<Map<String, dynamic>> get onEventStream;

  Future<void> startRecognize();

  Future<void> stopRecognize();
}
