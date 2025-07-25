import 'dart:math';

import 'package:flutter/services.dart';

/// 通用工具类
/// 提供一些常用的通用方法
class CommonUtil {
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

  /// 字符串数组，填充空格保持字符串长度一致
  ///
  /// @param strs 字符串列表
  static List<String> fillSpaceStr(List<String> strs) {
    if (strs.isEmpty) return strs;

    // 获取最长字符串的长度
    int maxLength = strs.map((str) => str.length).reduce(max);

    // 遍历处理每个字符串
    List<String> result = strs.map((str) {
      if (str.length == maxLength) return str;

      // 计算需要补充的空格数量
      int spacesToAdd = maxLength - str.length;
      // 如果是奇数，后面多加一个空格
      int frontSpaces = spacesToAdd ~/ 2;
      int backSpaces = spacesToAdd - frontSpaces;

      // 在字符串前后添加空格
      return '${' ' * frontSpaces}$str${' ' * backSpaces}';
    }).toList();

    return result;
  }
}
