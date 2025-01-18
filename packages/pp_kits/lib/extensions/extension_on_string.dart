import 'dart:io';

import 'package:flutter/services.dart';

import '../common/logger.dart';

extension StringExtension on String {
  int toInt() {
    return int.tryParse(this) ?? 0;
  }

  double toDouble() {
    return double.tryParse(this) ?? 0.0;
  }

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

  /// 将十六进制颜色字符串转换为 Color 对象。
  /// hexColor: 十六进制颜色字符串，如：#CCCCCC
  /// 可选的 [alpha] 参数表示透明度，范围从 0.0（完全透明）到 1.0（完全不透明）。
  /// 返回一个新的 Color 对象。
  Color toColor({double alpha = 1.0}) {
    // 确保透明度在0.0到1.0之间
    alpha = alpha.clamp(0.0, 1.0);
    // 将透明度从0.0-1.0转换为0-255
    int alphaValue = (alpha * 255).round();
    // 转换为十六进制字符串
    String alphaHex = alphaValue.toRadixString(16).padLeft(2, '0');

    final buffer = StringBuffer();
    buffer.write(alphaHex); // 使用计算得到的透明度值
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String urlEncode() {
    return Uri.encodeFull(this);
  }
}
