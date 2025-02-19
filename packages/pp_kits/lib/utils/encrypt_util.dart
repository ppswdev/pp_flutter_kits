import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:hex/hex.dart';

class EncryptUtil {
  static const String KEY_ALGORITHM = "AES";
  static const int DEFAULT_KEY_SIZE = 128;
  static const String ECB_PKCS7_PADDING = "AES/ECB/PKCS7";

  static String initHexKey() {
    final key = Key.fromSecureRandom(DEFAULT_KEY_SIZE ~/ 8);
    return HEX.encode(key.bytes);
  }

  static String encodeBase64(Uint8List bytes) {
    return base64.encode(bytes);
  }

  static Uint8List decodeBase64(String base64Code) {
    return base64.decode(base64Code);
  }

  static String aesEncrypt(String content, String hexAesKey) {
    final key = Key(Uint8List.fromList(HEX.decode(hexAesKey)));
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(content);
    return encodeBase64(encrypted.bytes);
  }

  static String aesDecrypt(String encryptStr, String hexAesKey) {
    final key = Key(Uint8List.fromList(HEX.decode(hexAesKey)));
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb, padding: 'PKCS7'));
    final encryptBytes = decodeBase64(encryptStr);
    final decrypted = encrypter.decrypt64(encodeBase64(encryptBytes));
    return decrypted;
  }
}

// void main() {
//   // 生成一个随机的AES密钥
//   String aesKey = EncryptUtil.initHexKey();
//   print("AES密钥: $aesKey");

//   String content = "{'id': 0, 'name': 'jack'}";
//   print("加密前: $content");

//   String encrypted = EncryptUtil.aesEncrypt(content, aesKey);
//   print("加密后: $encrypted");

//   String decrypted = EncryptUtil.aesDecrypt(encrypted, aesKey);
//   print("解密后: $decrypted");
// }
