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
      // iPod
      // case "iPod1,1": return "iPod Touch 1";
      // case "iPod2,1": return "iPod Touch 2";
      // case "iPod3,1": return "iPod Touch 3";
      // case "iPod4,1": return "iPod Touch 4";
      // case "iPod5,1": return "iPod Touch 5";
      // case "iPod7,1": return "iPod Touch 6";
      // case "iPod9,1": return "iPod touch (7th generation)";

      // iPhone
      // case "iPhone3,1":
      // case "iPhone3,2":
      // case "iPhone3,3": return "iPhone 4";
      // case "iPhone4,1": return "iPhone 4s";
      // case "iPhone5,1":
      // case "iPhone5,2": return "iPhone 5";
      // case "iPhone5,3":
      // case "iPhone5,4": return "iPhone 5c";
      // case "iPhone6,1":
      // case "iPhone6,2": return "iPhone 5s";
      case "iPhone7,2":
        return "iPhone 6";
      case "iPhone7,1":
        return "iPhone 6 Plus";
      case "iPhone8,1":
        return "iPhone 6s";
      case "iPhone8,2":
        return "iPhone 6s Plus";
      case "iPhone9,1":
      case "iPhone9,3":
        return "iPhone 7";
      case "iPhone9,2":
      case "iPhone9,4":
        return "iPhone 7 Plus";
      case "iPhone8,4":
        return "iPhone SE";
      case "iPhone10,1":
      case "iPhone10,4":
        return "iPhone 8";
      case "iPhone10,2":
      case "iPhone10,5":
        return "iPhone 8 Plus";
      case "iPhone10,3":
      case "iPhone10,6":
        return "iPhone X";
      case "iPhone11,2":
        return "iPhone XS";
      case "iPhone11,4":
      case "iPhone11,6":
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
      case "iPhone14,2":
        return "iPhone 13 Pro";
      case "iPhone14,3":
        return "iPhone 13 Pro Max";
      case "iPhone14,4":
        return "iPhone 13 mini";
      case "iPhone14,5":
        return "iPhone 13";
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

      // iPad
      // case "iPad2,1":
      // case "iPad2,2":
      // case "iPad2,3":
      // case "iPad2,4": return "iPad 2";
      // case "iPad3,1":
      // case "iPad3,2":
      // case "iPad3,3": return "iPad 3";
      // case "iPad3,4":
      // case "iPad3,5":
      // case "iPad3,6": return "iPad 4";
      // case "iPad6,11":
      // case "iPad6,12": return "iPad 5";
      case "iPad7,5":
      case "iPad7,6":
        return "iPad (6th generation)";
      case "iPad7,11":
      case "iPad7,12":
        return "iPad (7th generation)";
      case "iPad11,6":
      case "iPad11,7":
        return "iPad (8th generation)";
      case "iPad12,1":
      case "iPad12,2":
        return "iPad (9th generation)";
      case "iPad13,18":
      case "iPad13,19":
        return "iPad (10th generation)";
      case "iPad4,1":
      case "iPad4,2":
      case "iPad4,3":
        return "iPad Air 1";
      case "iPad5,3":
      case "iPad5,4":
        return "iPad Air 2";
      case "iPad11,3":
      case "iPad11,4":
        return "iPad Air (3rd generation)";
      case "iPad13,1":
      case "iPad13,2":
        return "iPad Air (4th generation)";
      case "iPad13,16":
      case "iPad13,17":
        return "iPad Air (5th generation)";
      // case "iPad2,5":
      // case "iPad2,6":
      // case "iPad2,7": return "iPad Mini 1";
      // case "iPad4,4":
      // case "iPad4,5":
      // case "iPad4,6": return "iPad Mini 2";
      // case "iPad4,7":
      // case "iPad4,8":
      // case "iPad4,9": return "iPad Mini 3";
      case "iPad5,1":
      case "iPad5,2":
        return "iPad Mini 4";
      case "iPad11,1":
      case "iPad11,2":
        return "iPad mini (5th generation)";
      case "iPad14,1":
      case "iPad14,2":
        return "iPad mini (6th generation)";
      case "iPad6,3":
      case "iPad6,4":
        return "iPad Pro 9.7 Inch";
      case "iPad6,7":
      case "iPad6,8":
        return "iPad Pro 12.9 Inch";
      case "iPad7,1":
      case "iPad7,2":
        return "iPad Pro 12.9 Inch (2nd generation)";
      case "iPad7,3":
      case "iPad7,4":
        return "iPad Pro 10.5 Inch";
      case "iPad8,1":
      case "iPad8,2":
      case "iPad8,3":
      case "iPad8,4":
      case "iPad8,5":
      case "iPad8,6":
      case "iPad8,7":
      case "iPad8,8":
        return "iPad Pro (12.9-inch) (3rd generation)";
      case "iPad8,9":
      case "iPad8,10":
        return "iPad Pro (11-inch) (2nd generation)";
      case "iPad8,11":
      case "iPad8,12":
        return "iPad Pro (12.9-inch) (4th generation)";
      case "iPad13,4":
      case "iPad13,5":
      case "iPad13,6":
      case "iPad13,7":
        return "iPad Pro (11-inch) (3rd generation)";
      case "iPad13,8":
      case "iPad13,9":
      case "iPad13,10":
      case "iPad13,11":
        return "iPad Pro (12.9-inch) (5th generation)";
      case "iPad14,3":
      case "iPad14,4":
        return "iPad Pro (11-inch) (4th generation)";
      case "iPad14,5":
      case "iPad14,6":
        return "iPad Pro (12.9-inch) (6th generation)";

      default:
        return "Unknown Device";
    }
  }
}
