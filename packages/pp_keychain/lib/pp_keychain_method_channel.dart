import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pp_keychain_platform_interface.dart';

/// An implementation of [PPKeychainPlatform] that uses method channels.
class MethodChannelPpKeychain extends PPKeychainPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pp_keychain');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> save({required String key, required String value}) async {
    print('pp_keychain: Saving data - key: $key, value: $value');
    try {
      final result = await methodChannel.invokeMethod<bool>('save', {
        'key': key,
        'value': value,
      });
      print('pp_keychain: Save result - $result');
      return result ?? false;
    } catch (e) {
      print('pp_keychain: Save error - $e');
      return false;
    }
  }

  @override
  Future<String?> read({required String key}) async {
    print('pp_keychain: Reading data - key: $key');
    try {
      final result = await methodChannel.invokeMethod<String>('read', {
        'key': key,
      });
      print('pp_keychain: Read result - $result');
      return result;
    } catch (e) {
      print('pp_keychain: Read error - $e');
      return null;
    }
  }

  @override
  Future<bool> delete({required String key}) async {
    print('pp_keychain: Deleting data - key: $key');
    try {
      final result = await methodChannel.invokeMethod<bool>('delete', {
        'key': key,
      });
      print('pp_keychain: Delete result - $result');
      return result ?? false;
    } catch (e) {
      print('pp_keychain: Delete error - $e');
      return false;
    }
  }
}
