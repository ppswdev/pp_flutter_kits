import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pp_kits/commons/logger.dart';

/// 安全存储工具类
///
/// 提供一些常用的安全存储方法, 如读取、写入、删除。
/// iOS端存储到钥匙串，Android端存储到KeyStore。
///
/// 使用示例：
/// ```dart
/// void example() async {
///   // 写入
///   bool writeResult = await KeychainUtil.write(key: 'my_key', value: 'my_value');
///   print('写入结果: $writeResult');
///
///   // 读取
///   String? value = await KeychainUtil.read(key: 'my_key');
///   print('读取到的值: $value');
///
///   // 删除
///   bool deleteResult = await KeychainUtil.delete(key: 'my_key');
///   print('删除结果: $deleteResult');
/// }
/// ```
class KeychainUtil {
  /// 获取安全存储实例
  ///
  /// 根据平台区分不同参数，iOS/Android自动适配。
  static FlutterSecureStorage get storage {
    var storage = const FlutterSecureStorage();
    if (Platform.isAndroid) {
      storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
    }
    return storage;
  }

  /// 读取指定键的值
  ///
  /// [key] 指定要读取的键名称。
  ///
  /// 返回值：
  ///   - 读取成功时，返回对应 key 的 value（字符串），
  ///   - 若 key 不存在或读取失败，返回 null。
  ///
  /// 示例：
  /// ```dart
  /// String? value = await KeychainUtil.read(key: 'my_key');
  /// ```
  static Future<String?> read({required String key}) async {
    try {
      return await storage.read(key: key);
    } catch (e) {
      Logger.trace('Failed to read keychain: $e');
      return null;
    }
  }

  /// 写入指定键值对
  ///
  /// [key] 要写入的键。
  /// [value] 要写入的值。
  ///
  /// 返回值：
  ///   - 写入成功返回 true，
  ///   - 写入失败返回 false。
  ///
  /// 示例：
  /// ```dart
  /// bool success = await KeychainUtil.write(key: 'my_key', value: 'abc123');
  /// ```
  static Future<bool> write({
    required String key,
    required String value,
  }) async {
    try {
      await storage.write(key: key, value: value);
      return true;
    } catch (e) {
      Logger.trace('Failed to write keychain: $e');
      return false;
    }
  }

  /// 删除指定键值
  ///
  /// [key] 要删除的键。
  ///
  /// 返回值：
  ///   - 删除成功返回 true，
  ///   - 删除失败返回 false。
  ///
  /// 示例：
  /// ```dart
  /// bool deleted = await KeychainUtil.delete(key: 'my_key');
  /// ```
  static Future<bool> delete({required String key}) async {
    try {
      await storage.delete(key: key);
      return true;
    } catch (e) {
      Logger.trace('Failed to delete keychain: $e');
      return false;
    }
  }
}
