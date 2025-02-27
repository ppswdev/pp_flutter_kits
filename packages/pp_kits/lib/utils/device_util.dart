import 'package:pp_kits/utils/keychain_util.dart';
import 'package:uuid/uuid.dart';

/// 设备工具类
/// 提供一些常用的设备信息获取方法
class DeviceUtil {
  /// 获取设备型号
  /// https://theapplewiki.com/wiki/Models#iPhone
  /// https://theapplewiki.com/wiki/Models#iPad
  /// https://theapplewiki.com/wiki/Models#iPad_Air
  /// https://theapplewiki.com/wiki/Models#iPad_Pro
  /// https://theapplewiki.com/wiki/Models#iPad_mini
  ///
  static String iosModelName(String machine) {
    switch (machine) {
      // iPhone 系列
      case "iPhone7,2":
        return "iPhone 6";
      case "iPhone7,1":
        return "iPhone 6 Plus";
      case "iPhone8,1":
        return "iPhone 6s";
      case "iPhone8,2":
        return "iPhone 6s Plus";
      case "iPhone9,1" || "iPhone9,3":
        return "iPhone 7";
      case "iPhone9,2" || "iPhone9,4":
        return "iPhone 7 Plus";
      case "iPhone8,4":
        return "iPhone SE";
      case "iPhone10,1" || "iPhone10,4":
        return "iPhone 8";
      case "iPhone10,2" || "iPhone10,5":
        return "iPhone 8 Plus";
      case "iPhone10,3" || "iPhone10,6":
        return "iPhone X";
      case "iPhone11,2":
        return "iPhone XS";
      case "iPhone11,4" || "iPhone11,6":
        return "iPhone XS Max";
      case "iPhone11,8":
        return "iPhone XR";
      case "iPhone12,1":
        return "iPhone 11";
      case "iPhone12,3":
        return "iPhone 11 Pro";
      case "iPhone12,5":
        return "iPhone 11 Pro Max";
      case "iPhone12,8":
        return "iPhone SE (2nd generation)";
      case "iPhone13,1":
        return "iPhone 12 mini";
      case "iPhone13,2":
        return "iPhone 12";
      case "iPhone13,3":
        return "iPhone 12 Pro";
      case "iPhone13,4":
        return "iPhone 12 Pro Max";
      case "iPhone13,5":
        return "iPhone 13";
      case "iPhone14,2":
        return "iPhone 13 Pro";
      case "iPhone14,3":
        return "iPhone 13 Pro Max";
      case "iPhone14,4":
        return "iPhone 13 mini";
      case "iPhone14,6":
        return "iPhone SE (3rd generation)";
      case "iPhone14,7":
        return "iPhone 14";
      case "iPhone14,8":
        return "iPhone 14 Plus";
      case "iPhone15,2":
        return "iPhone 14 Pro";
      case "iPhone15,3":
        return "iPhone 14 Pro Max";
      case "iPhone15,4":
        return "iPhone 15";
      case "iPhone15,5":
        return "iPhone 15 Plus";
      case "iPhone16,1":
        return "iPhone 15 Pro";
      case "iPhone16,2":
        return "iPhone 15 Pro Max";
      case "iPhone17,3":
        return "iPhone 16";
      case "iPhone17,4":
        return "iPhone 16 Plus";
      case "iPhone17,1":
        return "iPhone 16 Pro";
      case "iPhone17,2":
        return "iPhone 16 Pro Max";

      // iPad 系列
      case "iPad2,1" || "iPad2,2" || "iPad2,3" || "iPad2,4":
        return "iPad 2";
      case "iPad3,1" || "iPad3,2" || "iPad3,3":
        return "iPad 3";
      case "iPad3,4" || "iPad3,5" || "iPad3,6":
        return "iPad 4";
      case "iPad6,11" || "iPad6,12":
        return "iPad 5";
      case "iPad7,5" || "iPad7,6":
        return "iPad 6";
      case "iPad7,11" || "iPad7,12":
        return "iPad 7";
      case "iPad11,6" || "iPad11,7":
        return "iPad 8";
      case "iPad12,1" || "iPad12,2":
        return "iPad 9";
      case "iPad13,18" || "iPad13,19":
        return "iPad 10";

      // iPad Air 系列
      case "iPad4,1" || "iPad4,2" || "iPad4,3":
        return "iPad Air 1";
      case "iPad5,3" || "iPad5,4":
        return "iPad Air 2";
      case "iPad11,3" || "iPad11,4":
        return "iPad Air 3";
      case "iPad13,1" || "iPad13,2":
        return "iPad Air 4";
      case "iPad13,16" || "iPad13,17":
        return "iPad Air 5";
      case "iPad14,8" || "iPad14,9":
        return "iPad Air 11-inch (M2)";
      case "iPad14,10" || "iPad14,11":
        return "iPad Air 13-inch (M2)";

      // iPad Mini 系列
      case "iPad2,5" || "iPad2,6" || "iPad2,7":
        return "iPad Mini 1";
      case "iPad4,4" || "iPad4,5" || "iPad4,6":
        return "iPad Mini 2";
      case "iPad4,7" || "iPad4,8" || "iPad4,9":
        return "iPad Mini 3";
      case "iPad5,1" || "iPad5,2":
        return "iPad Mini 4";
      case "iPad11,1" || "iPad11,2":
        return "iPad mini 5";
      case "iPad14,1" || "iPad14,2":
        return "iPad mini 6";
      case "iPad16,1" || "iPad16,2":
        return "iPad mini (A17 Pro)";

      // iPad Pro 系列
      case "iPad6,3" || "iPad6,4":
        return "iPad Pro 9.7 Inch";
      case "iPad7,3" || "iPad7,4":
        return "iPad Pro 10.5 Inch";
      case "iPad8,1" || "iPad8,2" || "iPad8,3" || "iPad8,4":
        return "iPad Pro 11 Inch";
      case "iPad8,9" || "iPad8,10":
        return "iPad Pro 11 Inch 2";
      case "iPad13,4" || "iPad13,5" || "iPad13,6" || "iPad13,7":
        return "iPad Pro 11 Inch 3";
      case "iPad16,3" || "iPad16,4":
        return "iPad Pro 11 Inch (M4)";
      case "iPad6,7" || "iPad6,8":
        return "iPad Pro 12.9 Inch";
      case "iPad7,1" || "iPad7,2":
        return "iPad Pro 12.9 Inch 2";
      case "iPad8,5" || "iPad8,6" || "iPad8,7" || "iPad8,8":
        return "iPad Pro 12.9 Inch 3";
      case "iPad8,11" || "iPad8,12":
        return "iPad Pro 12.9 Inch 4";
      case "iPad13,8" || "iPad13,9" || "iPad13,10" || "iPad13,11":
        return "iPad Pro 12.9 Inch 5";
      case "iPad16,5" || "iPad16,6":
        return "iPad Pro 13 Inch (M4)";

      default:
        return "Unknown Device";
    }
  }

  /// 获取设备UUID
  static Future<String> getDeviceUUID(String packageName) async {
    String? value = await KeychainUtil.read(key: '$packageName.deviceUUID');
    if (value == null) {
      value = const Uuid().v7();
      await KeychainUtil.write(key: '$packageName.deviceUUID', value: value);
    }
    return value;
  }
}
