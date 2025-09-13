import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../common/logger.dart';

/// 字符串扩展
/// 提供一些常用的字符串操作方法
extension StringExtension on String {
  /// 将字符串转换为int
  int toInt() {
    return int.tryParse(this) ?? 0;
  }

  /// 将字符串转换为double
  double toDouble() {
    return double.tryParse(this) ?? 0.0;
  }

  /// 将字符串转换为bool
  bool toBool() {
    return this == 'true' || this == '1';
  }

  /// 将字符串转换为json
  Map<String, dynamic> toJson() {
    return jsonDecode(this) as Map<String, dynamic>;
  }

  /// 判断文本是否是Emoji表情
  bool isEmoji() {
    final emojiRegex = RegExp(
      r'(\u00A9|\u00AE|[\u2000-\u3300]|[\uD83C-\uDBFF\uDC00-\uDFFF])',
    );
    return emojiRegex.hasMatch(this);
  }

  /// 判断字符串是否为合法的IP地址（支持IPv4和IPv6）
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
  /// [filePath] 文件路径
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
  /// [filePath] 文件路径
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
  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: this));
  }

  /// 将字符串进行url编码
  String urlEncode() {
    return Uri.encodeFull(this);
  }

  /// 将字符串进行url解码
  String urlDecode() {
    return Uri.decodeFull(this);
  }
}
