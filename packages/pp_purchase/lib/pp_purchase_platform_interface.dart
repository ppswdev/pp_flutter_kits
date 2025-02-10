import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pp_purchase_method_channel.dart';

abstract class PpPurchasePlatform extends PlatformInterface {
  /// Constructs a PpPurchasePlatform.
  PpPurchasePlatform() : super(token: _token);

  static final Object _token = Object();

  static PpPurchasePlatform _instance = MethodChannelPpPurchase();

  /// The default instance of [PpPurchasePlatform] to use.
  ///
  /// Defaults to [MethodChannelPpPurchase].
  static PpPurchasePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PpPurchasePlatform] when
  /// they register themselves.
  static set instance(PpPurchasePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
