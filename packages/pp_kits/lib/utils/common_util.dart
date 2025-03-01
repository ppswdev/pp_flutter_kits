import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/logger.dart';

/// 通用工具类
/// 提供一些常用的通用方法
class CommonUtil {
  /// 打开链接或者跳转到其他App
  /// @param url 链接
  /// 使用示例
  /// void example() {
  ///   CommonUtil.openLink('https://www.google.com');
  /// }
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

  /// 使用累积概率法根据权重获取随机索引
  /// 使用示例:
  ///
  /// void example() {
  ///
  ///   List<double> probabilities = [10, 15, 5, 20, 10, 5, 15, 5, 10, 5]; // 总和100%
  ///
  ///   int selectedIndex = randomIndexByWeight(probabilities);
  ///
  ///   print('Selected index: $selectedIndex');
  ///
  /// }
  static int randomIndexByWeight(List<double> weights) {
    // 1. 验证权重合计是否为100%
    double sum = weights.fold(0, (prev, weight) => prev + weight);
    if ((sum - 100).abs() > 0.000001) {
      // 使用精度范围比较
      throw Exception('Weights must sum to 100%');
    }

    // 2. 生成0-100之间的随机数
    double random = Random().nextDouble() * 100;

    // 3. 累加概率直到超过随机数
    double accumulatedWeight = 0;
    for (int i = 0; i < weights.length; i++) {
      accumulatedWeight += weights[i];
      if (random <= accumulatedWeight) {
        return i;
      }
    }

    // 处理边界情况
    return weights.length - 1;
  }

  /// 生成随机色
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

    // 使用 Color.withValues() 方法来创建新颜色
    return baseColor.withValues(
      red: (baseColor.r + (random.nextInt(range) - (range ~/ 2)) / 255)
          .clamp(0.0, 1.0),
      green: (baseColor.g + (random.nextInt(range) - (range ~/ 2)) / 255)
          .clamp(0.0, 1.0),
      blue: (baseColor.b + (random.nextInt(range) - (range ~/ 2)) / 255)
          .clamp(0.0, 1.0),
    );
  }
}
