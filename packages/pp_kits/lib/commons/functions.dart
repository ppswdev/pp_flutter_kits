import 'package:flutter/material.dart';
import 'package:pp_kits/utils/app_util.dart';
import 'package:pp_kits/utils/common_util.dart';
import 'package:uuid/uuid.dart';

import '../utils/json_util.dart';

/// 生成一个基于v7（Unix时间戳+随机数）的唯一UUID字符串。
///
/// v7 版本结合了时间有序性和隐私需求，满足绝大多数业务需要。
///
/// 返回结果: [String] 新生成的UUID。
///
/// 示例：
/// ```dart
/// String id = uuid();
/// print(id); // 输出形如"018eb6f2-617b-7be0-8b93-b83a33fa3cbb"
/// ```
String uuid() {
  return const Uuid().v7();
}

/// 获取一个[min, max]之间的随机整数。
///
/// 参数:
/// * [min] 最小值（包含）
/// * [max] 最大值（包含）
///
/// 返回结果: [int] 区间内的随机整数。
///
/// 示例：
/// ```dart
/// int rnd = randomInt(10, 20);
/// print(rnd); // 可能输出12
/// ```
int randomInt(int min, int max) {
  return CommonUtil.randomInt(min, max);
}

/// 生成一个随机颜色。
///
/// 返回结果: [Color] 随机颜色对象。
///
/// 示例：
/// ```dart
/// Color color = randomColor();
/// print(color);
/// ```
Color randomColor() {
  return CommonUtil.randomColor();
}

/// 生成距离基础色[baseColor]一定色彩范围内的随机颜色。
///
/// 参数:
/// * [baseColor] 作为基准的颜色。
/// * [variation] 色差幅度（0.0~1.0，默认0.2），越大色彩变化越明显。
///
/// 返回结果: [Color] 变化后的随机颜色。
///
/// 示例：
/// ```dart
/// Color base = Colors.blue;
/// Color varied = randomColorInRange(base, variation: 0.3);
/// print(varied);
/// ```
Color randomColorInRange(Color baseColor, {double variation = 0.2}) {
  return CommonUtil.randomColorInRange(baseColor, variation: variation);
}

/// 从本地JSON文件解析为对象列表。
///
/// 参数:
/// * [assetPath] JSON文件路径。
/// * [fromJson] 负责把Map转换为目标对象的回调。
/// * [fromSandbox] 是否从沙盒目录读取（可选，默认false）。
///
/// 返回结果: [Future<List<T>>] 解析后的对象集合。
///
/// 示例：
/// ```dart
/// List<MyModel> models = await localJsonToModels<MyModel>(
///   'assets/data.json',
///   (json) => MyModel.fromJson(json),
/// );
/// ```
Future<List<T>> localJsonToModels<T>(
    String assetPath, T Function(Map<String, dynamic>) fromJson,
    {bool fromSandbox = false}) async {
  return JsonUtil.localJsonToModels(assetPath, fromJson,
      fromSandbox: fromSandbox);
}

/// 从本地JSON文件解析为单个对象。
///
/// 参数:
/// * [assetPath] JSON文件路径。
/// * [fromJson] 负责把Map转换为目标对象的回调。
/// * [fromSandbox] 是否从沙盒目录读取（可选，默认false）。
///
/// 返回结果: [Future<T?>] 解析得到的对象，若JSON为空返回null。
///
/// 示例：
/// ```dart
/// MyModel? model = await localJsonToModel<MyModel>(
///   'assets/data.json',
///   (json) => MyModel.fromJson(json),
/// );
/// ```
Future<T?> localJsonToModel<T>(
    String assetPath, T Function(Map<String, dynamic>) fromJson,
    {bool fromSandbox = false}) async {
  return JsonUtil.localJsonToModel(assetPath, fromJson,
      fromSandbox: fromSandbox);
}

/// 使用系统浏览器打开链接。
///
/// 参数:
/// * [url] 要打开的网址（如"https://flutter.dev"）
///
/// 返回结果: 无
///
/// 示例：
/// ```dart
/// openLink('https://flutter.dev');
/// ```
void openLink(String url) {
  AppUtil.openLink(url);
}
