import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../common/logger.dart';

/// JSON工具类
/// 提供一些常用的JSON操作方法
class JsonUtil {
  /// 通用的 JSON 数组解析为对象 List 的方法。
  ///
  /// 从本地 asset 或沙盒文件中读取 JSON 数组并解析为对象列表。
  ///
  /// [assetPath] JSON 文件路径（asset 或本地文件）
  /// [fromJson] JSON 映射到 T 类型对象的工厂函数
  /// [fromSandbox] 是否从沙盒目录读取（默认false，即从asset读取）
  ///
  /// 返回值:
  ///   [Future<List<T>>] 解析后的对象List，文件不存在或异常时返回空列表
  ///
  /// 使用示例:
  /// ```dart
  /// List<WheelModel> models = await JsonUtil.localJsonToModels<WheelModel>(
  ///   'assets/data/wheels.json',
  ///   (json) => WheelModel.fromJson(json),
  /// );
  /// ```
  static Future<List<T>> localJsonToModels<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson, {
    bool fromSandbox = false,
  }) async {
    String response;
    if (fromSandbox) {
      final file = File(assetPath);
      if (!file.existsSync()) {
        return [];
      }
      response = await file.readAsString();
    } else {
      try {
        response = await rootBundle.loadString(assetPath);
      } catch (e) {
        return [];
      }
    }
    final List<dynamic> data = json.decode(response);
    return data.map((item) => fromJson(item)).toList();
  }

  /// 通用的 JSON 解析为对象的方法。
  ///
  /// 从本地 asset 或沙盒文件中读取 JSON 并解析为对象。
  ///
  /// [assetPath] JSON 文件路径（asset 或本地文件）
  /// [fromJson] JSON 映射到 T 类型对象的工厂函数
  /// [fromSandbox] 是否从沙盒目录读取（默认false，即从asset读取）
  ///
  /// 返回值:
  ///   [Future<T?>] 解析后的对象，文件不存在或异常时返回 null
  ///
  /// 使用示例:
  /// ```dart
  /// WheelModel? model = await JsonUtil.localJsonToModel<WheelModel>(
  ///   'assets/data/wheel.json',
  ///   (json) => WheelModel.fromJson(json),
  /// );
  /// ```
  static Future<T?> localJsonToModel<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson, {
    bool fromSandbox = false,
  }) async {
    String response;
    if (fromSandbox) {
      final file = File(assetPath);
      if (!file.existsSync()) {
        return null;
      }
      response = await file.readAsString();
    } else {
      try {
        response = await rootBundle.loadString(assetPath);
      } catch (e) {
        return null;
      }
    }
    final data = json.decode(response);
    return fromJson(data);
  }

  /// 写入 JSON 数据到文件
  ///
  /// [json] 要写入的 Map<String, dynamic> 数据
  /// [filePath] 保存到的文件路径
  ///
  /// 返回值:
  ///   [bool] 是否写入成功（true成功，false失败）
  ///
  /// 使用示例:
  /// ```dart
  /// bool ok = JsonUtil.writeJsonToFile({'a': 1, 'b': 2}, '/tmp/example.json');
  /// print(ok); // true or false
  /// ```
  static bool writeJsonToFile(Map<String, dynamic> json, String filePath) {
    try {
      final file = File(filePath);
      file.parent.createSync(recursive: true);
      final jsonString = jsonEncode(json);
      file.writeAsStringSync(jsonString);
      return true;
    } catch (e) {
      Logger.log('Error writing JSON to file: $e');
      return false;
    }
  }

  /// 从文件中读取 JSON 数据并解析为 Map
  ///
  /// [filePath] JSON 文件路径
  ///
  /// 返回值:
  ///   [Map<String, dynamic>?] 成功返回 JSON 对象，失败或文件不存在返回 null
  ///
  /// 使用示例:
  /// ```dart
  /// final data = JsonUtil.readJsonFromFile('/tmp/example.json');
  /// if (data != null) {
  ///   print(data['a']); // 1
  /// }
  /// ```
  static Map<String, dynamic>? readJsonFromFile(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return null;
      }
      final jsonString = file.readAsStringSync();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      Logger.log('Error reading JSON from file: $e');
      return null;
    }
  }
}
