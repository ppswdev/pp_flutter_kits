/// 格式化工具类
/// 提供一些常用的格式化方法
class FormatUtil {
  /// 格式化时间
  ///
  /// 将传入的毫秒数转换为分钟和秒的字符串表示。
  ///
  /// 示例：
  /// ```dart
  /// String formattedTime = FormatUtil.formatDuration(123456);
  /// print(formattedTime); // 例如：02:03
  /// ```
  ///
  static String formatDuration(double milliseconds) {
    final duration = Duration(milliseconds: milliseconds.toInt());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 格式化时间字符串
  ///
  /// 将传入的时间字符串（格式为"毫秒数"）转换为分钟和秒的字符串表示。
  ///
  /// 示例：
  /// ```dart
  /// String formattedTime = FormatUtil.formatDurationByStr('123456');
  /// print(formattedTime); // 例如：02:03
  /// ```
  ///
  /// 参数:
  /// - [milliseconds] 时间字符串，格式为"毫秒数"。
  ///
  static String formatDurationByStr(String milliseconds) {
    final duration = Duration(milliseconds: double.parse(milliseconds).toInt());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 格式化播放量
  /// [viewCount] 播放量
  /// [langCode] 语言代码，支持 ar, de, en, es, fil, fr, id, it, ja, ko, pl, pt, ru, th, tr, vi, zh_Hans, zh_Hant，默认是 en
  /// 返回格式化后的播放量
  static String formatViewCount(int viewCount, [String langCode = 'en']) {
    if (viewCount < 1000) {
      return _formatNumber(viewCount, langCode);
    } else if (viewCount < 1000000) {
      final value = viewCount / 1000;
      return _formatNumber(value, langCode, 'K');
    } else if (viewCount < 1000000000) {
      final value = viewCount / 1000000;
      return _formatNumber(value, langCode, 'M');
    } else {
      final value = viewCount / 1000000000;
      return _formatNumber(value, langCode, 'B');
    }
  }

  /// 格式化数字
  /// [value] 数字值
  /// [langCode] 语言代码
  /// [suffix] 后缀（K, M, B, T）
  static String _formatNumber(
    dynamic value,
    String langCode, [
    String? suffix,
  ]) {
    String formattedValue;

    if (value is int) {
      formattedValue = _formatInteger(value, langCode);
    } else {
      formattedValue = value
          .toStringAsFixed(1)
          .replaceAll(RegExp(r'\.?0+$'), '');
    }

    if (suffix != null) {
      return '$formattedValue$suffix';
    }
    return formattedValue;
  }

  /// 格式化整数
  /// [value] 整数值
  /// [langCode] 语言代码
  static String _formatInteger(int value, String langCode) {
    final isChinese =
        langCode == 'ja' ||
        langCode == 'ko' ||
        langCode == 'zh_Hans' ||
        langCode == 'zh_Hant';

    if (isChinese) {
      return _formatChineseNumber(value);
    }

    final separator =
        langCode == 'id' ||
            langCode == 'pl' ||
            langCode == 'th' ||
            langCode == 'tr' ||
            langCode == 'vi'
        ? '.'
        : ',';

    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (match) => '${match.group(1)}$separator',
    );
  }

  /// 格式化中文数字
  /// [value] 整数值
  static String _formatChineseNumber(int value) {
    if (value < 10000) {
      return value.toString();
    } else if (value < 100000000) {
      final num = value / 10000;
      return '${num.toStringAsFixed(1).replaceAll(RegExp(r'\.?0+$'), '')}万';
    } else {
      final num = value / 100000000;
      return '${num.toStringAsFixed(1).replaceAll(RegExp(r'\.?0+$'), '')}亿';
    }
  }
}
