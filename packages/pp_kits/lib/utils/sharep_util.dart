import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 工具类
/// 
/// 提供对 SharedPreferences 的常用操作方法，包括初始化、数据的存储与读取、移除、清空等。
/// 
/// 应用启动时应先初始化：
/// ```dart
/// await SharepUtil.init();
/// ```
class SharepUtil {
  static SharedPreferences? _prefs;

  /// 初始化 SharedPreferences 实例
  /// 
  /// 必须在使用其他方法前调用一次进行初始化。
  /// 
  /// 示例:
  /// ```dart
  /// await SharepUtil.init();
  /// ```
  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// 存储布尔值到 SharedPreferences
  /// 
  /// 示例:
  /// ```dart
  /// await SharepUtil.setBool('isFirstOpen', true);
  /// ```
  static Future<void> setBool(String key, bool value) async {
    final prefs = _prefs ?? await init();
    await prefs.setBool(key, value);
  }

  /// 获取布尔值类型的数据
  ///
  /// [key] 要获取的键
  /// [defaultValue] 若没有对应 key 返回的默认值，默认为 false
  ///
  /// 示例:
  /// ```dart
  /// bool firstOpen = SharepUtil.getBool('isFirstOpen', defaultValue: true);
  /// print(firstOpen); // 例如: true
  /// ```
  /// 返回结果：
  ///   [bool] 读取到的布尔值
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /// 存储字符串到 SharedPreferences
  /// 
  /// 示例:
  /// ```dart
  /// await SharepUtil.setString('username', 'admin');
  /// ```
  static Future<void> setString(String key, String value) async {
    final prefs = _prefs ?? await init();
    await prefs.setString(key, value);
  }

  /// 获取字符串类型的数据
  ///
  /// [key] 键
  /// [defaultValue] 如果没有找到 key 返回的默认值，默认为空字符串
  ///
  /// 示例:
  /// ```dart
  /// String name = SharepUtil.getString('username');
  /// print(name); // 例如: 'admin'
  /// ```
  /// 返回结果：
  ///   [String] 读取到的字符串
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  /// 存储整型值到 SharedPreferences
  /// 
  /// 示例:
  /// ```dart
  /// await SharepUtil.setInt('age', 25);
  /// ```
  static Future<void> setInt(String key, int value) async {
    final prefs = _prefs ?? await init();
    await prefs.setInt(key, value);
  }

  /// 获取整型数据
  ///
  /// [key] 键
  /// [defaultValue] 未找到时的默认值，默认为0
  ///
  /// 示例:
  /// ```dart
  /// int age = SharepUtil.getInt('age', defaultValue: 18);
  /// print(age); // 例如: 25
  /// ```
  /// 返回结果：
  ///   [int] 读取到的整型数据
  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  /// 存储双精度类型到 SharedPreferences
  /// 
  /// 示例:
  /// ```dart
  /// await SharepUtil.setDouble('salary', 8888.8);
  /// ```
  static Future<void> setDouble(String key, double value) async {
    final prefs = _prefs ?? await init();
    await prefs.setDouble(key, value);
  }

  /// 获取双精度浮点数
  ///
  /// [key] 键
  /// [defaultValue] 未找到时的默认值，默认为 0.0
  ///
  /// 示例:
  /// ```dart
  /// double salary = SharepUtil.getDouble('salary', defaultValue: 8888.8);
  /// print(salary); // 例如: 8888.8
  /// ```
  /// 返回结果：
  ///   [double] 读取到的值
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  /// 存储字符串列表到 SharedPreferences
  /// 
  /// 示例:
  /// ```dart
  /// await SharepUtil.setStringList('fruit', ['apple', 'banana']);
  /// ```
  static Future<void> setStringList(String key, List<String> value) async {
    final prefs = _prefs ?? await init();
    await prefs.setStringList(key, value);
  }

  /// 获取字符串列表数据
  /// 
  /// [key] 键
  /// [defaultValue] 未找到时返回的默认 List，默认为空 List
  /// 
  /// 示例:
  /// ```dart
  /// List<String> fruits = SharepUtil.getStringList('fruit');
  /// print(fruits); // 例如: ['apple', 'banana']
  /// ```
  /// 返回结果：
  ///   [List<String>] 字符串列表
  static List<String> getStringList(String key,
      {List<String> defaultValue = const []}) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  /// 删除指定 key 的数据
  /// 
  /// 示例:
  /// ```dart
  /// await SharepUtil.remove('username');
  /// ```
  static Future<void> remove(String key) async {
    final prefs = _prefs ?? await init();
    await prefs.remove(key);
  }

  /// 清空所有 SharedPreferences 存储数据
  /// 
  /// 示例:
  /// ```dart
  /// await SharepUtil.clear();
  /// ```
  static Future<void> clear() async {
    final prefs = _prefs ?? await init();
    await prefs.clear();
  }
}
