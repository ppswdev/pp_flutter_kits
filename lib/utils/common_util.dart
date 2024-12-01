import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pp_kits/common/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonUtil {
  /// 打开链接
  /// @param url 链接
  static void openLink(String url) async {
    if (GetUtils.isURL(url)) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        Logger.log('ppkits openLink error: $e');
      }
    }
  }

  /// 复制文本
  /// @param text 文本
  static copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  /// 获取随机数
  /// @param min 最小值
  /// @param max 最大值
  static int randomInt(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  //生成随机色
  static Color randomColor() {
    return Color.fromARGB(255, Random.secure().nextInt(255),
        Random.secure().nextInt(255), Random.secure().nextInt(255));
  }

  // 生成特定色系的随机颜色
  /// [baseColor] 基础颜色
  /// [variation] 变化范围 0.0-1.0
  static Color randomColorInRange(Color baseColor, {double variation = 0.2}) {
    assert(variation >= 0.0 && variation <= 1.0,
        'variation must be between 0.0 and 1.0');

    final random = Random.secure();
    final range = (255 * variation).toInt();

    int newValue(int base) {
      final delta = random.nextInt(range) - (range ~/ 2);
      return (base + delta).clamp(0, 255);
    }

    return Color.fromARGB(
      255,
      newValue(baseColor.red),
      newValue(baseColor.green),
      newValue(baseColor.blue),
    );
  }
}
