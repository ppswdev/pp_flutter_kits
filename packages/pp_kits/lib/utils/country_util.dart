import 'dart:io';

/// 国家工具类
///
/// 用于判断当前用户所在的国家是否为指定的国家
///
/// 启动的时候获取设备的地区信息，然后设置CountryUtil.countryCode
///
class CountryUtil {
  static String countryCode = 'en';

  /// 判断当前是否为阿拉伯语用户
  static bool isArabic() =>
      countryCode.toLowerCase() == 'ar' || Platform.localeName.endsWith('AR');

  /// 判断当前是否为德语用户
  static bool isGermany() =>
      countryCode.toLowerCase() == 'de' || Platform.localeName.endsWith('DE');

  /// 判断当前是否为英语用户
  static bool isEnglish() =>
      countryCode.toLowerCase() == 'en' || Platform.localeName.endsWith('EN');

  /// 判断当前是否为西班牙语用户
  static bool isSpanish() =>
      countryCode.toLowerCase() == 'es' || Platform.localeName.endsWith('ES');

  /// 判断当前是否为菲律宾语用户
  static bool isFilipino() =>
      countryCode.toLowerCase() == 'fil' || Platform.localeName.endsWith('FIL');

  /// 判断当前是否为法语用户
  static bool isFrench() =>
      countryCode.toLowerCase() == 'fr' || Platform.localeName.endsWith('FR');

  /// 判断当前是否为印地语用户
  static bool isHindi() =>
      countryCode.toLowerCase() == 'hi' || Platform.localeName.endsWith('HI');

  /// 判断当前是否为印尼语用户
  static bool isIndonesian() =>
      countryCode.toLowerCase() == 'id' || Platform.localeName.endsWith('ID');

  /// 判断当前是否为意大利语用户
  static bool isItalian() =>
      countryCode.toLowerCase() == 'it' || Platform.localeName.endsWith('IT');

  /// 判断当前是否为日语用户
  static bool isJapanese() =>
      countryCode.toLowerCase() == 'ja' || Platform.localeName.endsWith('JA');

  /// 判断当前是否为韩语用户
  static bool isKorea() =>
      countryCode.toLowerCase() == 'kr' || Platform.localeName.endsWith('KR');

  /// 判断当前是否为波兰语用户
  static bool isPolish() =>
      countryCode.toLowerCase() == 'pl' || Platform.localeName.endsWith('PL');

  /// 判断当前是否为葡萄牙语用户
  static bool isPortuguese() =>
      countryCode.toLowerCase() == 'pt' || Platform.localeName.endsWith('PT');

  /// 判断当前是否为俄语用户
  static bool isRussian() =>
      countryCode.toLowerCase() == 'ru' || Platform.localeName.endsWith('RU');

  /// 判断当前是否为泰语用户
  static bool isThai() =>
      countryCode.toLowerCase() == 'th' || Platform.localeName.endsWith('TH');

  /// 判断当前是否为土耳其语用户
  static bool isTurkish() =>
      countryCode.toLowerCase() == 'tr' || Platform.localeName.endsWith('TR');

  /// 判断当前是否为越南语用户
  static bool isVietnamese() =>
      countryCode.toLowerCase() == 'vi' || Platform.localeName.endsWith('VI');

  /// 判断当前是否为中国用户
  static bool isChina() =>
      countryCode.toLowerCase() == 'zh' || Platform.localeName.endsWith('ZH');
}
