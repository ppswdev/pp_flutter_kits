import 'dart:convert';
import 'dart:math';

/// 列表扩展
/// 提供一些常用的列表操作方法
extension ListExtension<T> on List<T> {
  /// 返回一个新的列表，其元素顺序已经被打乱（随机排列）。
  ///
  /// 返回结果：
  ///   一个新的随机顺序的 List<T>，原始列表不会被修改。
  ///
  /// 示例代码：
  /// ```dart
  /// final origin = [1, 2, 3, 4];
  /// final randomList = origin.shuffled;
  /// print(randomList); // 如：[3, 1, 4, 2]
  /// print(origin); // 仍为：[1, 2, 3, 4]
  /// ```
  List<T> get shuffled => [...this]..shuffle();

  /// 随机返回当前列表中的一个元素。
  ///
  /// 返回结果：
  ///   返回列表中的任意一个元素。如果列表为空，将抛出异常。
  ///
  /// 示例代码：
  /// ```dart
  /// final list = ['a', 'b', 'c'];
  /// print(list.randomSingle()); // 例如：'b'
  /// ```
  T randomSingle() {
    if (isEmpty) {
      throw StateError('Cannot select a random element from an empty list.');
    }
    final random = Random();
    final index = random.nextInt(length);
    return this[index];
  }

  /// 将列表转换为 JSON 字符串。
  ///
  /// 返回结果：
  ///   返回列表的 JSON 字符串。
  ///
  /// 示例代码：
  /// ```dart
  /// final list = [1, 2, 3];
  /// print(list.toJsonString()); // 例如：'[1,2,3]'
  String toJsonString() {
    return jsonEncode(this);
  }
}
