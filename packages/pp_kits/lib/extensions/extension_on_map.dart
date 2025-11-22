import 'dart:convert';

/// 为 Map<String, dynamic> 增加扩展方法
extension MapExtension on Map<String, dynamic> {
  /// 将当前 Map 对象转换为 JSON 格式字符串
  ///
  /// 返回结果：
  ///   返回一个 JSON 格式的字符串，等价于原 Map 的序列化结果。
  ///
  /// 示例代码：
  /// ```dart
  /// final map = {'name': 'Alice', 'age': 20};
  /// final jsonString = map.toJsonString();
  /// print(jsonString); // 输出: {"name":"Alice","age":20}
  /// ```
  String toJsonString() {
    return jsonEncode(this);
  }
}
