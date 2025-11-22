import 'package:flutter/material.dart';

/// [PlaceholderTip]
///
/// 页面中心提示组件，通常用于空页面的占位显示（如无数据、无网络、错误信息等）。
///
/// ## 参数
/// - [image]: 显示的图片组件，必填。
/// - [text]: 提示文本，必填。
/// - [textStyle]: 提示文本的自定义样式，选填，默认灰色14号字体。
/// - [button]: 可选的操作按钮Widget，选填。
///
/// ## 代码示例
/// ```dart
/// PlaceholderTip(
///   image: Icon(Icons.cloud_off, size: 100, color: Colors.grey),
///   text: '无网络连接，请检查您的网络设置。',
///   button: ElevatedButton(
///     onPressed: () {},
///     child: Text('重试'),
///   ),
/// )
/// ```
///
/// ## 返回
/// 返回一个 [Widget]，通常为页面中央的占位提示，包括图片、文本和可选按钮。
class PlaceholderTip extends StatelessWidget {
  /// 创建一个 [PlaceholderTip] 组件。
  const PlaceholderTip({
    super.key,
    required this.image,
    required this.text,
    this.textStyle,
    this.button,
  });

  /// 显示的图片组件。
  final Widget image;

  /// 提示文本。
  final String text;

  /// 提示文本的样式，默认为灰色14号字体。
  final TextStyle? textStyle;

  /// 可选的操作按钮。
  final Widget? button;

  /// 构建占位提示组件。
  ///
  /// 返回: 居中且纵向排列的图片、提示文本与可选按钮的 [Widget]。
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: image,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: textStyle ??
                  const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          if (button != null) ...[
            const SizedBox(height: 20),
            button!,
          ],
        ],
      ),
    );
  }
}
