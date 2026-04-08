import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../commons/logger.dart';

/// JSON工具类
/// 提供一些常用的JSON操作方法
class JsonUtil {
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
  /// [fromAsset] 是否从 Assets 中读取（默认false，即从沙盒文件读取）
  ///
  /// 返回值:
  ///   [Future<Map<String, dynamic>?>] 成功返回 JSON 对象，失败或文件不存在返回 null
  ///
  /// 使用示例:
  /// ```dart
  /// // 从沙盒文件读取
  /// final data = await JsonUtil.readJsonFromFile('/tmp/example.json');
  /// if (data != null) {
  ///   print(data['a']); // 1
  /// }
  ///
  /// // 从 Assets 读取
  /// final data = await JsonUtil.readJsonFromFile('assets/data/config.json', fromAsset: true);
  /// ```
  static Future<Map<String, dynamic>?> readJsonFromFile(
    String filePath, {
    bool fromAsset = false,
  }) async {
    try {
      String jsonString;
      if (fromAsset) {
        jsonString = await rootBundle.loadString(filePath);
      } else {
        final file = File(filePath);
        if (!file.existsSync()) {
          return null;
        }
        jsonString = await file.readAsString();
      }
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      Logger.log('Error reading JSON from file: $e');
      return null;
    }
  }

  /// 将单个对象写入 JSON 文件
  ///
  /// [model] 要写入的对象
  /// [filePath] 保存到的文件路径
  /// [toJson] 对象转换为 Map 的函数
  ///
  /// 返回值:
  ///   [bool] 是否写入成功（true成功，false失败）
  ///
  /// 使用示例:
  /// ```dart
  /// WheelModel model = WheelModel(...);
  /// bool ok = JsonUtil.writeModelToFile<WheelModel>(
  ///   model,
  ///   '/tmp/wheel.json',
  ///   (m) => m.toJson(),
  /// );
  /// print(ok);
  /// ```
  static bool writeModelToFile<T>(
    T model,
    String filePath,
    Map<String, dynamic> Function(T) toJson,
  ) {
    try {
      final file = File(filePath);
      file.parent.createSync(recursive: true);
      final jsonMap = toJson(model);
      final jsonString = jsonEncode(jsonMap);
      file.writeAsStringSync(jsonString);
      return true;
    } catch (e) {
      Logger.log('Error writing model to file: $e');
      return false;
    }
  }

  /// 从文件中读取 JSON 并解析为单个对象
  ///
  /// [filePath] JSON 文件路径
  /// [fromJson] JSON 映射到 T 类型对象的工厂函数
  /// [fromAsset] 是否从 Assets 中读取（默认false，即从沙盒文件读取）
  ///
  /// 返回值:
  ///   [Future<T?>] 解析后的对象，文件不存在或异常时返回 null
  ///
  /// 使用示例:
  /// ```dart
  /// // 从沙盒文件读取
  /// WheelModel? model = await JsonUtil.readModelFromFile<WheelModel>(
  ///   '/tmp/wheel.json',
  ///   (json) => WheelModel.fromJson(json),
  /// );
  ///
  /// // 从 Assets 读取
  /// WheelModel? model = await JsonUtil.readModelFromFile<WheelModel>(
  ///   'assets/data/wheel.json',
  ///   (json) => WheelModel.fromJson(json),
  ///   fromAsset: true,
  /// );
  /// ```
  static Future<T?> readModelFromFile<T>(
    String filePath,
    T Function(Map<String, dynamic>) fromJson, {
    bool fromAsset = false,
  }) async {
    try {
      String jsonString;
      if (fromAsset) {
        jsonString = await rootBundle.loadString(filePath);
      } else {
        final file = File(filePath);
        if (!file.existsSync()) {
          return null;
        }
        jsonString = await file.readAsString();
      }
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(data);
    } catch (e) {
      Logger.log('Error reading model from file: $e');
      return null;
    }
  }

  /// 将对象列表写入 JSON 文件
  ///
  /// [models] 要写入的对象列表
  /// [filePath] 保存到的文件路径
  /// [toJson] 对象转换为 Map 的函数
  ///
  /// 返回值:
  ///   [bool] 是否写入成功（true成功，false失败）
  ///
  /// 使用示例:
  /// ```dart
  /// List<WheelModel> models = [model1, model2];
  /// bool ok = JsonUtil.writeModelsToFile<WheelModel>(
  ///   models,
  ///   '/tmp/wheels.json',
  ///   (model) => model.toJson(),
  /// );
  /// print(ok);
  /// ```
  static bool writeModelsToFile<T>(
    List<T> models,
    String filePath,
    Map<String, dynamic> Function(T) toJson,
  ) {
    try {
      final file = File(filePath);
      file.parent.createSync(recursive: true);
      final jsonList = models.map((model) => toJson(model)).toList();
      final jsonString = jsonEncode(jsonList);
      file.writeAsStringSync(jsonString);
      return true;
    } catch (e) {
      Logger.log('Error writing models to file: $e');
      return false;
    }
  }

  /// 从文件中读取 JSON 数组并解析为对象列表
  ///
  /// [filePath] JSON 文件路径
  /// [fromJson] JSON 映射到 T 类型对象的工厂函数
  /// [fromAsset] 是否从 Assets 中读取（默认false，即从沙盒文件读取）
  ///
  /// 返回值:
  ///   [Future<List<T>>] 解析后的对象列表，文件不存在或异常时返回空列表
  ///
  /// 使用示例:
  /// ```dart
  /// // 从沙盒文件读取
  /// List<WheelModel> models = await JsonUtil.readModelsFromFile<WheelModel>(
  ///   '/tmp/wheels.json',
  ///   (json) => WheelModel.fromJson(json),
  /// );
  ///
  /// // 从 Assets 读取
  /// List<WheelModel> models = await JsonUtil.readModelsFromFile<WheelModel>(
  ///   'assets/data/wheels.json',
  ///   (json) => WheelModel.fromJson(json),
  ///   fromAsset: true,
  /// );
  /// ```
  static Future<List<T>> readModelsFromFile<T>(
    String filePath,
    T Function(Map<String, dynamic>) fromJson, {
    bool fromAsset = false,
  }) async {
    try {
      String jsonString;
      if (fromAsset) {
        jsonString = await rootBundle.loadString(filePath);
      } else {
        final file = File(filePath);
        if (!file.existsSync()) {
          return [];
        }
        jsonString = await file.readAsString();
      }
      final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
      return data
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger.log('Error reading models from file: $e');
      return [];
    }
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
  @Deprecated('Use readModelFromFile instead')
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
  @Deprecated('Use readModelsFromFile instead')
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
}
