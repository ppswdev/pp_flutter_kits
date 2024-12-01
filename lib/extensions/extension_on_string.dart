import 'dart:io';

import '../common/logger.dart';

extension StringExtension on String {
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
}
