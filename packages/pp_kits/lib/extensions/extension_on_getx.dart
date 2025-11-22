import 'package:get/get.dart';

/// 为 [GetInterface] 增加 findOrPut 方法，便捷安全地获取依赖对象。
extension GetXFindOrPut on GetInterface {
  /// 查找类型为 [T] 的依赖；如未找到，则使用 [creator] 创建并注册后返回。
  ///
  /// 此方法用于安全获取依赖。如果依赖未被注册，则调用 [creator] 创建实例，
  /// 并通过 [put] 注册为单例，防止“未找到”错误并确保全局唯一。
  ///
  /// 参数说明:
  /// - [creator]：返回类型为 [T] 的工厂函数，仅在依赖未注册时调用一次进行实例化。
  /// - [tag]：可选的标签，可用于区分相同类型的多个依赖实例。
  ///
  /// 返回结果:
  /// 返回已注册（或新创建并注册）的 [T] 类型对象实例。
  ///
  /// 示例代码：
  /// ```dart
  /// // 假设有一个控制器 MyController
  /// final controller = Get.findOrPut(() => MyController());
  /// // 若 MyController 已注册，则直接获取；否则先创建再注册再返回
  /// ```
  T findOrPut<T extends Object>(T Function() creator, {String? tag}) {
    // 检查此类型的依赖是否已被注册
    if (isRegistered<T>(tag: tag)) {
      // 已注册，则直接查找返回
      return find<T>(tag: tag);
    } else {
      // 未注册，则创建、注册并返回该依赖
      return put<T>(creator(), tag: tag);
    }
  }
}
