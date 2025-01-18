import 'package:shared_preferences/shared_preferences.dart';

class SharepUtil {
  static SharedPreferencesWithCache? _prefs;

  static Future<SharedPreferencesWithCache> init() async {
    _prefs = await SharedPreferencesWithCache.create(
        cacheOptions: SharedPreferencesWithCacheOptions(allowList: {}));
    return _prefs!;
  }

  /// 存储布尔值
  static Future<void> setBool(String key, bool value) async {
    final prefs = _prefs ?? await init();
    await prefs.setBool(key, value);
  }

  /// 获取布尔值
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /// 存储字符串
  static Future<void> setString(String key, String value) async {
    final prefs = _prefs ?? await init();
    await prefs.setString(key, value);
  }

  /// 获取字符串
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  /// 存储整型
  static Future<void> setInt(String key, int value) async {
    final prefs = _prefs ?? await init();
    await prefs.setInt(key, value);
  }

  /// 获取整型
  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  /// 存储双精度
  static Future<void> setDouble(String key, double value) async {
    final prefs = _prefs ?? await init();
    await prefs.setDouble(key, value);
  }

  /// 获取双精度
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  /// 存储字符串列表
  static Future<void> setStringList(String key, List<String> value) async {
    final prefs = _prefs ?? await init();
    await prefs.setStringList(key, value);
  }

  /// 获取字符串列表
  static List<String> getStringList(String key,
      {List<String> defaultValue = const []}) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  /// 删除指定key的数据
  static Future<void> remove(String key) async {
    final prefs = _prefs ?? await init();
    await prefs.remove(key);
  }

  /// 清空所有数据
  static Future<void> clear() async {
    final prefs = _prefs ?? await init();
    await prefs.clear();
  }
}
