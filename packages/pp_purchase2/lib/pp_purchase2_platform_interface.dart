import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pp_purchase2_method_channel.dart';

abstract class PpPurchase2Platform extends PlatformInterface {
  /// Constructs a PpPurchase2Platform.
  PpPurchase2Platform() : super(token: _token);

  static final Object _token = Object();

  static PpPurchase2Platform _instance = MethodChannelPpPurchase2();

  /// The default instance of [PpPurchase2Platform] to use.
  ///
  /// Defaults to [MethodChannelPpPurchase2].
  static PpPurchase2Platform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PpPurchase2Platform] when
  /// they register themselves.
  static set instance(PpPurchase2Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
