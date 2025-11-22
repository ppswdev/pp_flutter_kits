import 'dart:math';

import 'package:flutter/services.dart';

/// 通用工具类
/// 提供一些常用的通用方法
class CommonUtil {
  /// 复制文本到剪切板
  ///
  /// 将传入的 [text] 文本内容复制到系统剪贴板。
  ///
  /// 示例：
  /// ```dart
  /// CommonUtil.copy('Hello World');
  /// ```
  ///
  /// 没有返回值。
  static void copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  /// 获取[min, max]范围内的随机整数
  ///
  /// 生成一个大于等于[min]且小于等于[max]的随机整数。
  ///
  /// 参数:
  /// - [min] 最小值（包含）
  /// - [max] 最大值（包含）
  ///
  /// 示例：
  /// ```dart
  /// int num = CommonUtil.randomInt(1, 10);
  /// print(num); // 例如：3
  /// ```
  ///
  /// 返回值:
  /// 返回一个介于[min]和[max]之间的随机整数。
  static int randomInt(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  /// 根据权重列表随机返回索引，权重累积法
  ///
  /// 要求 [weights] 列表内的权重总和为100（百分比），每个数为 double 类型。
  ///
  /// 示例：
  /// ```dart
  /// List<double> probabilities = [10, 15, 5, 20, 10, 5, 15, 5, 10, 5]; // 总和100%
  /// int selectedIndex = CommonUtil.randomIndexByWeight(probabilities);
  /// print('Selected index: $selectedIndex');
  /// ```
  ///
  /// 返回值:
  /// 返回被选中的索引，整数类型。
  ///
  /// 抛出异常: 当权重总和不为100时抛出异常。
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

  /// 随机生成一个颜色
  ///
  /// 使用Dart内置的[Random.secure]生成RGB三通道的0~254随机色（透明度始终为255）。
  ///
  /// 示例：
  /// ```dart
  /// Color color = CommonUtil.randomColor();
  /// print(color); // 例如：Color(0xffff67ad)
  /// ```
  ///
  /// 返回值:
  /// 返回一个随机生成的[Color]。
  static Color randomColor() {
    return Color.fromARGB(255, Random.secure().nextInt(255),
        Random.secure().nextInt(255), Random.secure().nextInt(255));
  }

  /// 基于指定基色生成相近色随机颜色
  ///
  /// [baseColor]：基础颜色。
  /// [variation]：变化范围[0.0, 1.0]，数值越大颜色可变化越大，默认0.2。
  ///
  /// 示例：
  /// ```dart
  /// Color newColor = CommonUtil.randomColorInRange(Colors.blue, variation: 0.1);
  /// print(newColor);
  /// ```
  ///
  /// 返回值:
  /// 返回一个颜色值接近基色的随机[Color]对象。
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

  /// 填充字符串数组，使每个字符串长度相同（前后补空格）
  ///
  /// 传入字符串列表 [strs]，将各字符串通过前后补空格的方式填充至最大长度，实际内容两端对齐。
  ///
  /// 示例：
  /// ```dart
  /// List<String> input = ['a', 'abc', 'bb'];
  /// List<String> filled = CommonUtil.fillSpaceStr(input);
  /// print(filled); // [' a ', 'abc', 'bb ']
  /// ```
  ///
  /// 返回值:
  /// 返回一个各项填充长度至一致的新字符串数组。
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
