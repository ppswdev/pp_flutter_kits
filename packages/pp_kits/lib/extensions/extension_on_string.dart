import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../common/logger.dart';

/// 字符串扩展
/// 提供一些常用的字符串操作方法
extension StringExtension on String {
  /// 将字符串转换为int
  ///
  /// 返回结果：
  ///   若字符串可正确转换为整数，则返回对应整数值；否则返回0。
  ///
  /// 示例：
  /// ```dart
  /// print('123'.toInt()); // 123
  /// print('abc'.toInt()); // 0
  /// ```
  int toInt() {
    return int.tryParse(this) ?? 0;
  }

  /// 将字符串转换为double
  ///
  /// 返回结果：
  ///   若字符串可正确转换为浮点数，则返回对应double值；否则返回0.0。
  ///
  /// 示例：
  /// ```dart
  /// print('0.5'.toDouble()); // 0.5
  /// print('abc'.toDouble()); // 0.0
  /// ```
  double toDouble() {
    return double.tryParse(this) ?? 0.0;
  }

  /// 将字符串转换为bool
  ///
  /// 返回结果：
  ///   字符串为'true'或'1'时返回true，否则返回false。
  ///
  /// 示例：
  /// ```dart
  /// print('true'.toBool()); // true
  /// print('1'.toBool()); // true
  /// print('false'.toBool()); // false
  /// print('0'.toBool()); // false
  /// ```
  bool toBool() {
    return this == 'true' || this == '1';
  }

  /// 将字符串转换为JSON Map<String, dynamic>
  ///
  /// 返回结果：
  ///   若转换成功，则返回Map<String, dynamic>对象；若无法转换，将抛出异常。
  ///
  /// 示例：
  /// ```dart
  /// print('{"a":1}'.toJson()); // {a: 1}
  /// ```
  Map<String, dynamic> toJson() {
    return jsonDecode(this) as Map<String, dynamic>;
  }

  /// 判断文本是否是Emoji表情
  ///
  /// 返回结果：
  ///   若字符串是Emoji表情则返回true，否则返回false。
  ///
  /// 示例：
  /// ```dart
  /// print('😄'.isEmoji()); // true
  /// print('hi'.isEmoji()); // false
  /// ```
  bool isEmoji() {
    final emojiRegex = RegExp(
      r'(\u00A9|\u00AE|[\u2000-\u3300]|[\uD83C-\uDBFF\uDC00-\uDFFF])',
    );
    return emojiRegex.hasMatch(this);
  }

  /// 判断字符串是否为合法的IP地址（支持IPv4和IPv6）
  ///
  /// 返回结果：
  ///   若字符串为有效的IPv4或IPv6地址则返回true，否则返回false。
  ///
  /// 示例：
  /// ```dart
  /// print('192.168.0.1'.isValidIP()); // true
  /// print('2001:db8::1'.isValidIP()); // true
  /// print('999.999.999.999'.isValidIP()); // false
  /// ```
  bool isValidIP() {
    // IPv4正则表达式
    final ipv4Pattern = RegExp(
      r'^(\d{1,3}\.){3}\d{1,3}$',
    );

    // IPv6正则表达式
    final ipv6Pattern = RegExp(
      r'^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$',
    );

    // 检查是否为IPv4地址
    if (ipv4Pattern.hasMatch(this)) {
      final parts = split('.');
      for (final part in parts) {
        final number = int.parse(part);
        if (number < 0 || number > 255) {
          return false;
        }
      }
      return true;
    }

    // 检查是否为IPv6地址
    if (ipv6Pattern.hasMatch(this)) {
      return true;
    }

    return false;
  }

  /// 将文本内容写入指定文件目录中
  ///
  /// [filePath] 文件路径
  ///
  /// 返回结果：
  ///   写入成功返回true，写入失败返回false。
  ///
  /// 示例：
  /// ```dart
  /// bool result = 'hello world'.writeToFile('/tmp/test.txt');
  /// print(result); // true 或 false
  /// ```
  bool writeToFile(String filePath) {
    try {
      final file = File(filePath);
      // 确保目录存在
      file.parent.createSync(recursive: true);
      // 写入字符串内容
      file.writeAsStringSync(this);
      return true;
    } catch (e) {
      Logger.log('Error writing to file: $e');
      return false;
    }
  }

  /// 从指定文件目录中读取文本内容
  ///
  /// 方法调用方式为：`'/path/to/file.txt'.readFileText()`
  ///
  /// 返回结果：
  ///   返回读取到的文件内容字符串。如果文件不存在或读取失败，则返回空字符串。
  ///
  /// 示例：
  /// ```dart
  /// String text = '/tmp/test.txt'.readFileText();
  /// print(text); // 文件内容 或 ''
  /// ```
  String readFileText() {
    try {
      final file = File(this);
      if (!file.existsSync()) {
        return '';
      }
      return File(this).readAsStringSync();
    } catch (e) {
      Logger.log('Error reading from file: $e');
      return '';
    }
  }

  /// 将文本内容复制到剪贴板
  ///
  /// 返回结果：
  ///   返回一个Future<void>，操作完成时可继续后续操作。
  ///
  /// 示例：
  /// ```dart
  /// await 'hello'.copyToClipboard();
  /// ```
  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: this));
  }

  /// 将字符串进行url编码
  ///
  /// 返回结果：
  ///   返回url编码后的字符串。
  ///
  /// 示例：
  /// ```dart
  /// print('空 格'.urlEncode()); // %E7%A9%BA%20%E6%A0%BC
  /// ```
  String urlEncode() {
    return Uri.encodeFull(this);
  }

  /// 将字符串进行url解码
  ///
  /// 返回结果：
  ///   返回解码后的字符串内容。
  ///
  /// 示例：
  /// ```dart
  /// print('%E7%A9%BA%20%E6%A0%BC'.urlDecode()); // 空 格
  /// ```
  String urlDecode() {
    return Uri.decodeFull(this);
  }
}
