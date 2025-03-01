import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences工具类
/// 提供一些常用的SharedPreferences操作方法
class SharepUtil {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// 存储布尔值
  /// 使用示例
  /// void example() {
  ///   SharepUtil.setBool('key', true);
  /// }
  static Future<void> setBool(String key, bool value) async {
    final prefs = _prefs ?? await init();
    await prefs.setBool(key, value);
  }

  /// 获取布尔值
  /// 使用示例
  /// void example() {
  ///   SharepUtil.getBool('key');
  /// }
  /// 返回：true
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /// 存储字符串
  /// 使用示例
  /// void example() {
  ///   SharepUtil.setString('key', 'value');
  /// }
  static Future<void> setString(String key, String value) async {
    final prefs = _prefs ?? await init();
    await prefs.setString(key, value);
  }

  /// 获取字符串
  /// 使用示例
  /// void example() {
  ///   SharepUtil.getString('key');
  /// }
  /// 返回：value
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  /// 存储整型
  /// 使用示例
  /// void example() {
  ///   SharepUtil.setInt('key', 1);
  /// }
  static Future<void> setInt(String key, int value) async {
    final prefs = _prefs ?? await init();
    await prefs.setInt(key, value);
  }

  /// 获取整型
  /// 使用示例
  /// void example() {
  ///   SharepUtil.getInt('key');
  /// }
  /// 返回：1
  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  /// 存储双精度
  /// 使用示例
  /// void example() {
  ///   SharepUtil.setDouble('key', 1.0);
  /// }
  static Future<void> setDouble(String key, double value) async {
    final prefs = _prefs ?? await init();
    await prefs.setDouble(key, value);
  }

  /// 获取双精度
  /// 使用示例
  /// void example() {
  ///   SharepUtil.getDouble('key');
  /// }
  /// 返回：1.0
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  /// 存储字符串列表
  /// 使用示例
  /// void example() {
  ///   SharepUtil.setStringList('key', ['value1', 'value2']);
  /// }
  static Future<void> setStringList(String key, List<String> value) async {
    final prefs = _prefs ?? await init();
    await prefs.setStringList(key, value);
  }

  /// 获取字符串列表
  /// 使用示例
  /// void example() {
  ///   SharepUtil.getStringList('key');
  /// }
  /// 返回：['value1', 'value2']
  static List<String> getStringList(String key,
      {List<String> defaultValue = const []}) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  /// 删除指定key的数据
  /// 使用示例
  /// void example() {
  ///   SharepUtil.remove('key');
  /// }
  static Future<void> remove(String key) async {
    final prefs = _prefs ?? await init();
    await prefs.remove(key);
  }

  /// 清空所有数据
  /// 使用示例
  /// void example() {
  ///   SharepUtil.clear();
  /// }
  static Future<void> clear() async {
    final prefs = _prefs ?? await init();
    await prefs.clear();
  }
}
