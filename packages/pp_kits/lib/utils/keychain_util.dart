import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 安全存储工具类
/// 提供一些常用的安全存储方法, 比如：读取、写入、删除, iOS存储到钥匙串中, Android存储到KeyStore中
/// 使用示例
/// void example() {
///   KeychainUtil.write(key: 'key', value: 'value');
///   KeychainUtil.read(key: 'key');
///   KeychainUtil.delete(key: 'key');
/// }
class KeychainUtil {
  /// 获取安全存储实例
  static get storage {
    var storage = const FlutterSecureStorage();
    if (Platform.isAndroid) {
      storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
    }
    return storage;
  }

  /// 读取指定键值
  static read({required String key}) async {
    return await storage.read(key: key);
  }

  /// 写入指定键值
  static write({required String key, required String value}) async {
    await storage.write(key: key, value: value);
  }

  /// 删除指定键值
  static delete({required String key}) async {
    await storage.delete(key: key);
  }
}
