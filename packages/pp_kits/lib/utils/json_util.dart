import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../common/logger.dart';

/// JSON工具类
/// 提供一些常用的JSON操作方法
class JsonUtil {
  ///
  /// 定义一个通用的 JSON 数组解析为对象List的方法
  ///
  /// 使用示例
  /// void exampleUsage() async {
  ///   List<WheelModel> models = await localJsonToModels<WheelModel>(
  ///     A.jsonWheels,
  ///     (json) => WheelModel.fromJson(json),
  ///     fromSandbox: true,
  ///   );
  /// }
  static Future<List<T>> localJsonToModels<T>(
      String assetPath, T Function(Map<String, dynamic>) fromJson,
      {bool fromSandbox = false}) async {
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

  ///
  /// 定义一个通用的 JSON 数组解析为对象的方法
  ///
  /// 使用示例
  /// void exampleUsage() async {
  ///   WheelModel? model = await localJsonToModel<WheelModel>(
  ///     A.jsonWheels,
  ///     (json) => WheelModel.fromJson(json),
  ///     fromSandbox: true,
  ///   );
  /// }
  static Future<T?> localJsonToModel<T>(
      String assetPath, T Function(Map<String, dynamic>) fromJson,
      {bool fromSandbox = false}) async {
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

  /// 写入JSON到文件
  /// filePath: 文件路径
  /// json: 要写入的JSON数据
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
}
