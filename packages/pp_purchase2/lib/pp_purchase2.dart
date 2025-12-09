
import 'pp_purchase2_platform_interface.dart';

class PpPurchase2 {
  Future<String?> getPlatformVersion() {
    return PpPurchase2Platform.instance.getPlatformVersion();
  }
}
