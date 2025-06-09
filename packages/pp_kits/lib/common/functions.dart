import 'package:flutter/material.dart';
import 'package:pp_kits/utils/app_util.dart';
import 'package:pp_kits/utils/common_util.dart';
import 'package:uuid/uuid.dart';

import '../utils/json_util.dart';

/// UUID（Universally Unique Identifier）有多种版本，每个版本的生成方式和用途不同。
///
/// v5：
///   生成方式：基于命名空间和名称的 SHA-1 哈希。
///   特点：相同的命名空间和名称会生成相同的 UUID。
///   用途：适用于需要从固定输入生成一致 UUID 的场景。
///
/// v6：
///   生成方式：类似 v1，但时间戳顺序不同，优化了数据库索引。
///   特点：时间戳在前，适合排序。
///   用途：适用于需要时间排序且避免 MAC 地址泄露的场景。
///
/// v7：
///   生成方式：基于 Unix 时间戳和随机数。
///   特点：时间戳在前，适合排序，避免了 v1 的隐私问题。
///   用途：适用于需要时间排序的场景。
///
/// v8：
///   生成方式：自定义格式，用户定义。
///   特点：灵活性高，用户可以定义生成方式。
///   用途：适用于需要自定义 UUID 生成规则的场景。
///
/// 选择建议：
/// v4 是最常用的版本，适合大多数场景。
/// v1 和 v6 适合需要时间排序的场景，但要注意隐私问题。
/// v5 适合需要从固定输入生成一致 UUID 的场景。
/// v7 是一种新的标准，结合了时间排序和隐私保护。
/// v8 适合需要自定义生成规则的场景。
///
/// 注意：
/// 在选择 UUID 版本时，考虑应用场景的需求，如排序、隐私、唯一性等。
/// 确保使用可靠的库来生成 UUID，以避免实现错误。
String uuid() {
  return const Uuid().v7();
}

/// 获取随机数
///
/// @param min 最小值
///
/// @param max 最大值
///
int randomInt(int min, int max) {
  return CommonUtil.randomInt(min, max);
}

/// 生成随机色
Color randomColor() {
  return CommonUtil.randomColor();
}

///
/// 生成特定色系的随机颜色
///
/// [baseColor] 基础颜色
///
/// [variation] 变化范围 0.0-1.0
Color randomColorInRange(Color baseColor, {double variation = 0.2}) {
  return CommonUtil.randomColorInRange(baseColor, variation: variation);
}

///
/// 定义一个通用的 JSON 数组解析为对象List的方法
///
/// [assetPath] JSON 文件路径
///
/// [fromJson] JSON 转对象的方法
///
/// [fromSandbox] 是否从沙盒读取
///
/// 用法示例：
///
/// ```dart
/// void exampleUsage() async {
///   List<WheelModel> models = await localJsonToModels<WheelModel>(
///     A.jsonWheels,
///     (json) => WheelModel.fromJson(json),
///     fromSandbox: true,
///   );
/// }
/// ```
Future<List<T>> localJsonToModels<T>(
    String assetPath, T Function(Map<String, dynamic>) fromJson,
    {bool fromSandbox = false}) async {
  return JsonUtil.localJsonToModels(assetPath, fromJson,
      fromSandbox: fromSandbox);
}

///
/// 通用的 JSON 数组解析为单个对象的方法。
///
/// [assetPath] JSON 文件路径
///
/// [fromJson] JSON 转对象的方法
///
/// [fromSandbox] 是否从沙盒读取
///
/// 用法示例：
///
/// ```dart
/// void exampleUsage() async {
///   WheelModel? model = await localJsonToModel<WheelModel>(
///     A.jsonWheels,
///     (json) => WheelModel.fromJson(json),
///     fromSandbox: true,
///   );
/// }
/// ```
Future<T?> localJsonToModel<T>(
    String assetPath, T Function(Map<String, dynamic>) fromJson,
    {bool fromSandbox = false}) async {
  return JsonUtil.localJsonToModel(assetPath, fromJson,
      fromSandbox: fromSandbox);
}

/// 打开链接
void openLink(String url) {
  AppUtil.openLink(url);
}
