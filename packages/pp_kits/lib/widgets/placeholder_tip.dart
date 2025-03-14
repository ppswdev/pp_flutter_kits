import 'package:flutter/material.dart';

/// 页面中心提示
/// 一般用于空页面显示占位，无网络，错误信息等
class PlaceholderTip extends StatelessWidget {
  const PlaceholderTip({
    super.key,
    required this.image,
    required this.text,
    this.textStyle,
    this.button,
  });

  final Widget image;
  final String text;
  final TextStyle? textStyle;
  final Widget? button;

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
