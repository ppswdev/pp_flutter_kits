import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pp_kits/common/logger.dart';

/// 安全存储工具类
/// 提供一些常用的安全存储方法, 比如：读取、写入、删除, iOS存储到钥匙串中, Android存储到KeyStore中
/// 使用示例
/// ``` dart
/// void example() {
///   KeychainUtil.write(key: 'key', value: 'value');
///   KeychainUtil.read(key: 'key');
///   KeychainUtil.delete(key: 'key');
/// }
/// ```
class KeychainUtil {
  /// 获取安全存储实例
  static FlutterSecureStorage get storage {
    var storage = const FlutterSecureStorage();
    if (Platform.isAndroid) {
      storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
    }
    return storage;
  }

  /// 读取指定键值
  static Future<String?> read({required String key}) async {
    try {
      return await storage.read(key: key);
    } catch (e) {
      Logger.trace('Failed to read keychain: $e');
      return null;
    }
  }

  /// 写入指定键值
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
