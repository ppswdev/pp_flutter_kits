import 'pp_keychain_platform_interface.dart';

class PPKeychain {
  /// 获取平台版本
  Future<String?> getPlatformVersion() {
    return PPKeychainPlatform.instance.getPlatformVersion();
  }

  /// 保存数据到钥匙串
  ///
  /// [key] 要保存的键
  /// [value] 要保存的值
  ///
  /// 返回值：保存成功返回 true，失败返回 false
  Future<bool> save({required String key, required String value}) {
    return PPKeychainPlatform.instance.save(key: key, value: value);
  }

  /// 从钥匙串读取数据
  ///
  /// [key] 要读取的键
  ///
  /// 返回值：读取成功返回对应的值，失败返回 null
  Future<String?> read({required String key}) {
    return PPKeychainPlatform.instance.read(key: key);
  }

  /// 从钥匙串删除数据
  ///
  /// [key] 要删除的键
  ///
  /// 返回值：删除成功返回 true，失败返回 false
  Future<bool> delete({required String key}) {
    return PPKeychainPlatform.instance.delete(key: key);
  }
}
