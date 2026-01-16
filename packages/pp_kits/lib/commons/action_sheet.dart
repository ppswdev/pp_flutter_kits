import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// 操作表选项模型
class ActionSheetOption {
  /// 选项标题
  final String title;

  /// 选项值
  final dynamic value;

  /// 是否为破坏性操作（红色文字）
  final bool isDestructive;

  /// 是否为默认选中项
  final bool isDefault;

  /// 构造函数
  const ActionSheetOption({
    required this.title,
    this.value,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

/// 底部操作表
///
/// ```dart
/// PPActionSheet.show(
///   title: 'Dingyue_FamilyShare'.localized,
///   message: 'Dingyue_FamilyShare_Desc'.localized,
///   options: [
///     ActionSheetOption(title: 'A'),
///     ActionSheetOption(title: 'B'),
///     ActionSheetOption(title: 'C'),
///   ],
///   onOptionSelected: (index, option) {
///     print('onOptionSelected: $index ${option.title}');
///   },
/// );
/// ```
class PPActionSheet {
  /// 显示操作表
  ///
  /// 参数：
  /// - [title]：操作表标题
  /// - [message]：操作表副标题
  /// - [options]：操作表选项列表
  /// - [cancelText]：取消按钮文本
  /// - [onOptionSelected]：选中选项时的回调
  /// - [onCancel]：点击取消时的回调
  static void show({
    String? title,
    String? message,
    required List<ActionSheetOption> options,
    String cancelText = '取消',
    void Function(int index, ActionSheetOption option)? onOptionSelected,
    void Function()? onCancel,
  }) {
    showCupertinoModalPopup(
      context: Get.context!,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          message: message != null ? Text(message) : null,
          actions: List.generate(
            options.length,
            (index) => CupertinoActionSheetAction(
              isDestructiveAction: options[index].isDestructive,
              isDefaultAction: options[index].isDefault,
              onPressed: () {
                Navigator.pop(context);
                if (onOptionSelected != null) {
                  onOptionSelected(index, options[index]);
                }
              },
              child: Text(options[index].title),
            ),
          ),
          cancelButton: CupertinoActionSheetAction(
            child: Text(cancelText),
            onPressed: () {
              Navigator.pop(context);
              if (onCancel != null) {
                onCancel();
              }
            },
          ),
        );
      },
    );
  }
}
