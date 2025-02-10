
import 'pp_purchase_platform_interface.dart';

class PpPurchase {
  Future<String?> getPlatformVersion() {
    return PpPurchasePlatform.instance.getPlatformVersion();
  }
}
