import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:hex/hex.dart';

/// 加密工具类，支持AES、Base64等方法
class EncryptUtil {
  /// 生成随机的128位（16字节）AES十六进制密钥
  ///
  /// 返回结果：
  ///   [String] 返回生成的16字节长度的十六进制密钥字符串
  ///
  /// 示例：
  /// ```dart
  /// String aesKey = EncryptUtil.initHexKey();
  /// print('AES密钥: $aesKey');
  /// ```
  static String initHexKey() {
    final key = Key.fromSecureRandom(128 ~/ 8);
    return HEX.encode(key.bytes);
  }

  /// 将 [bytes] 转换为 Base64 编码字符串
  ///
  /// [bytes] 源数据，Uint8List 类型
  ///
  /// 返回结果：
  ///   [String] Base64 编码字符串
  ///
  /// 示例：
  /// ```dart
  /// Uint8List raw = utf8.encode('hello') as Uint8List;
  /// String base64Str = EncryptUtil.encodeBase64(raw);
  /// print(base64Str); // aGVsbG8=
  /// ```
  static String encodeBase64(Uint8List bytes) {
    return base64.encode(bytes);
  }

  /// 将 Base64 编码字符串解码为 Uint8List
  ///
  /// [base64Code] Base64字符串
  ///
  /// 返回结果：
  ///   [Uint8List] 解码后的字节数组
  ///
  /// 示例：
  /// ```dart
  /// String str = 'aGVsbG8=';
  /// Uint8List bytes = EncryptUtil.decodeBase64(str);
  /// print(utf8.decode(bytes)); // hello
  /// ```
  static Uint8List decodeBase64(String base64Code) {
    return base64.decode(base64Code);
  }

  /// 使用AES（CBC模式+PKCS7填充）对内容进行加密
  ///
  /// [content] 明文内容（String）
  /// [key] 16字节长度的密钥，UTF8字符串 or hex解码后再转为key
  /// [iv]  16字节长度的初始向量，UTF8字符串
  ///
  /// 返回结果：
  ///   [String] 加密后的Base64字符串
  ///
  /// 示例：
  /// ```dart
  /// String encrypted = EncryptUtil.aesEncrypt('hello', '1234567890123456', '1234567890123456');
  /// print(encrypted); // 加密后的Base64字符串
  /// ```
  static String aesEncrypt(String content, String key, String iv) {
    final encrypter =
        Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(content, iv: IV.fromUtf8(iv));
    return encrypted.base64;
  }

  /// 使用AES（CBC模式+PKCS7填充）对内容进行解密
  ///
  /// [encryptStr] 需要解密的Base64字符串
  /// [key] 16字节长度的密钥，UTF8字符串
  /// [iv]  16字节长度的初始向量，UTF8字符串
  ///
  /// 返回结果：
  ///   [String] 解密后的明文字符串
  ///
  /// 示例：
  /// ```dart
  /// String encrypted = EncryptUtil.aesEncrypt('hello', '1234567890123456', '1234567890123456');
  /// String decrypted = EncryptUtil.aesDecrypt(encrypted, '1234567890123456', '1234567890123456');
  /// print(decrypted); // hello
  /// ```
  static String aesDecrypt(String encryptStr, String key, String iv) {
    final encrypter =
        Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc, padding: 'PKCS7'));
    final decrypted = encrypter.decrypt64(encryptStr, iv: IV.fromUtf8(iv));
    return decrypted;
  }
}

/*
示例 main 演示：

void main() {
  // 生成一个随机的AES密钥
  String aesKey = EncryptUtil.initHexKey();
  print("AES密钥: $aesKey");

  String content = "{'id': 0, 'name': 'jack'}";
  print("加密前: $content");

  // 假定已知16位Key和IV
  String key = '1234567890123456';
  String iv = '6543210987654321';

  String encrypted =
      EncryptUtil.aesEncrypt(content, key, iv);
  print("加密后: $encrypted");

  String decrypted =
      EncryptUtil.aesDecrypt(encrypted, key, iv);
  print("解密后: $decrypted");
}
*/
