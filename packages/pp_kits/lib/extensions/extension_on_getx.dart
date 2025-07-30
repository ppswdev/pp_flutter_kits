import 'package:get/get.dart';

extension GetXFindOrPut on GetInterface {
  /// Finds a dependency of type [T], or creates and registers it if it's not found.
  ///
  /// This is a safe way to get a dependency, as it will instantiate and register
  /// it using the provided [creator] function if it's not already available.
  /// This prevents "not found" errors and ensures a singleton instance.
  ///
  /// - [creator]: A function that returns a new instance of the dependency.
  ///   It's only called if the dependency is not already registered.
  /// - [tag]: Optional tag to distinguish between different instances of the same type.
  ///
  /// Returns the existing or newly created instance of [T].
  ///
  /// Example:
  /// ```dart
  /// final controller = Get.findOrPut(() => MyController());
  /// ```
  T findOrPut<T extends Object>(T Function() creator, {String? tag}) {
    // 检查此类型的依赖是否已经被注册
    if (isRegistered<T>(tag: tag)) {
      // 如果已注册，直接find并返回
      return find<T>(tag: tag);
    } else {
      // 如果未注册，通过creator创建一个新实例，
      // 然后使用put注册它，并返回这个新实例。
      // Get.put()会返回它刚刚创建的实例。
      return put<T>(creator(), tag: tag);
    }
  }
}
