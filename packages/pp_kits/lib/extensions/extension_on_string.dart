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

  /// 判断文本是否是Emoji表情
  bool isEmoji() {
    final emojiRegex = RegExp(
      r'(\u00A9|\u00AE|[\u2000-\u3300]|[\uD83C-\uDBFF\uDC00-\uDFFF])',
    );
    return emojiRegex.hasMatch(this);
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
