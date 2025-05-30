import 'package:flutter/material.dart';

/// 用于包裹需要缓存的页面, 状态保持
///
/// 使用方法介绍
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   var children = <Widget>[];
///   for (int i = 0; i < 6; ++i) {
///     //只需要用 KeepAliveWrapper 包装一下即可
///     children.add(KeepAliveWrapper(child:Page( text: '$i'));
///   }
///   return PageView(children: children);
/// }
/// ```
class KeepAliveWrapper extends StatefulWidget {
  const KeepAliveWrapper({
    super.key,
    this.keepAlive = true,
    required this.child,
  });
  final bool keepAlive;
  final Widget child;

  @override
  // ignore: library_private_types_in_public_api
  _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(covariant KeepAliveWrapper oldWidget) {
    if (oldWidget.keepAlive != widget.keepAlive) {
      // keepAlive 状态需要更新，实现在 AutomaticKeepAliveClientMixin 中
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
