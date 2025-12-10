import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inapp_purchase_method_channel.dart';

abstract class InappPurchasePlatform extends PlatformInterface {
  /// Constructs a InappPurchasePlatform.
  InappPurchasePlatform() : super(token: _token);

  static final Object _token = Object();

  static InappPurchasePlatform _instance = MethodChannelInappPurchase();

  /// The default instance of [InappPurchasePlatform] to use.
  ///
  /// Defaults to [MethodChannelInappPurchase].
  static InappPurchasePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InappPurchasePlatform] when
  /// they register themselves.
  static set instance(InappPurchasePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
