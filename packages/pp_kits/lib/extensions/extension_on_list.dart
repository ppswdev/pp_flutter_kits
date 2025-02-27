import 'dart:math';

/// 列表扩展
/// 提供一些常用的列表操作方法
extension ListExtension<T> on List<T> {
  /// 打乱数组
  List<T> get shuffled => [...this]..shuffle();

  /// 随机获取一个数组中的元素
  T randomSingle() {
    final random = Random();
    final index = random.nextInt(length);
    return this[index];
  }
}
