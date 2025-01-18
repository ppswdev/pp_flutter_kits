import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ndt7_service_method_channel.dart';

abstract class Ndt7ServicePlatform extends PlatformInterface {
  /// Constructs a Ndt7ServicePlatform.
  Ndt7ServicePlatform() : super(token: _token);

  static final Object _token = Object();

  static Ndt7ServicePlatform _instance = MethodChannelNdt7Service();

  /// The default instance of [Ndt7ServicePlatform] to use.
  ///
  /// Defaults to [MethodChannelNdt7Service].
  static Ndt7ServicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Ndt7ServicePlatform] when
  /// they register themselves.
  static set instance(Ndt7ServicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();
  Future<void> loadServers();
  Future<void> startTest(int index);
  Future<void> stopTest();

  Stream<Map<String, dynamic>> get onEventStream;
}
