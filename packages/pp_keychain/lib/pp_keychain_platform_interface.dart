import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pp_keychain_method_channel.dart';

abstract class PPKeychainPlatform extends PlatformInterface {
  /// Constructs a PpKeychainPlatform.
  PPKeychainPlatform() : super(token: _token);

  static final Object _token = Object();

  static PPKeychainPlatform _instance = MethodChannelPpKeychain();

  /// The default instance of [PPKeychainPlatform] to use.
  ///
  /// Defaults to [MethodChannelPpKeychain].
  static PPKeychainPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PPKeychainPlatform] when
  /// they register themselves.
  static set instance(PPKeychainPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> save({required String key, required String value}) {
    throw UnimplementedError('save() has not been implemented.');
  }

  Future<String?> read({required String key}) {
    throw UnimplementedError('read() has not been implemented.');
  }

  Future<bool> delete({required String key}) {
    throw UnimplementedError('delete() has not been implemented.');
  }
}
