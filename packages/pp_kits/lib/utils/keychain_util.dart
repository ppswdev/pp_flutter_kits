import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 安全存储工具类
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
}
