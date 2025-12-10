
import 'inapp_purchase_platform_interface.dart';

class InappPurchase {
  Future<String?> getPlatformVersion() {
    return InappPurchasePlatform.instance.getPlatformVersion();
  }
}
