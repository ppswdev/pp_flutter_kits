import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'decibel_meter_platform_interface.dart';
import 'src/models/decibel_models.dart';

/// An implementation of [DecibelMeterPlatform] that uses method channels.
class MethodChannelDecibelMeter extends DecibelMeterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('decibel_meter');

  // MARK: - 基础方法

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  // MARK: - 核心测量方法

  @override
  Future<bool> startMeasurement() async {
    final result = await methodChannel.invokeMethod<bool>('startMeasurement');
    return result ?? false;
  }

  @override
  Future<bool> stopMeasurement() async {
    final result = await methodChannel.invokeMethod<bool>('stopMeasurement');
    return result ?? false;
  }

  // MARK: - 状态和数据获取方法

  @override
  Future<String> getCurrentState() async {
    final result = await methodChannel.invokeMethod<String>('getCurrentState');
    return result ?? 'idle';
  }

  @override
  Future<double> getCurrentDecibel() async {
    final result = await methodChannel.invokeMethod<double>(
      'getCurrentDecibel',
    );
    return result ?? 0.0;
  }

  @override
  Future<DecibelMeasurement?> getCurrentMeasurement() async {
    final result = await methodChannel.invokeMethod<Map>(
      'getCurrentMeasurement',
    );
    if (result == null) return null;
    return DecibelMeasurement.fromMap(Map<String, dynamic>.from(result));
  }

  @override
  Future<Map<String, double>> getStatistics() async {
    final result = await methodChannel.invokeMethod<Map>('getStatistics');
    if (result == null) return {'current': 0.0, 'max': 0.0, 'min': 0.0};
    return Map<String, double>.from(
      result.map(
        (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
      ),
    );
  }

  @override
  Future<List<DecibelMeasurement>> getMeasurementHistory() async {
    final result = await methodChannel.invokeMethod<List>(
      'getMeasurementHistory',
    );
    if (result == null) return [];
    return result
        .map(
          (e) =>
              DecibelMeasurement.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  @override
  Future<DecibelStatistics?> getCurrentStatistics() async {
    final result = await methodChannel.invokeMethod<Map>(
      'getCurrentStatistics',
    );
    if (result == null) return null;
    return DecibelStatistics.fromMap(Map<String, dynamic>.from(result));
  }

  @override
  Future<double> getRealTimeLeq() async {
    final result = await methodChannel.invokeMethod<double>('getRealTimeLeq');
    return result ?? 0.0;
  }

  @override
  Future<double> getCurrentPeak() async {
    final result = await methodChannel.invokeMethod<double>('getCurrentPeak');
    return result ?? 0.0;
  }

  // MARK: - 校准方法

  @override
  Future<bool> setCalibrationOffset(double offset) async {
    final result = await methodChannel.invokeMethod<bool>(
      'setCalibrationOffset',
      {'offset': offset},
    );
    return result ?? false;
  }

  @override
  Future<double> getCalibrationOffset() async {
    final result = await methodChannel.invokeMethod<double>(
      'getCalibrationOffset',
    );
    return result ?? 0.0;
  }

  // MARK: - 频率权重方法

  @override
  Future<String> getCurrentFrequencyWeighting() async {
    final result = await methodChannel.invokeMethod<String>(
      'getCurrentFrequencyWeighting',
    );
    return result ?? 'A-weight';
  }

  @override
  Future<bool> setFrequencyWeighting(String weighting) async {
    final result = await methodChannel.invokeMethod<bool>(
      'setFrequencyWeighting',
      {'weighting': weighting},
    );
    return result ?? false;
  }

  @override
  Future<List<String>> getAvailableFrequencyWeightings() async {
    final result = await methodChannel.invokeMethod<List>(
      'getAvailableFrequencyWeightings',
    );
    if (result == null) return [];
    return result.map((e) => e.toString()).toList();
  }

  @override
  Future<List<double>> getFrequencyWeightingCurve(String weighting) async {
    final result = await methodChannel.invokeMethod<List>(
      'getFrequencyWeightingCurve',
      {'weighting': weighting},
    );
    if (result == null) return [];
    return result.map((e) => (e as num).toDouble()).toList();
  }

  @override
  Future<String> getFrequencyWeightingsList() async {
    final result = await methodChannel.invokeMethod<String>(
      'getFrequencyWeightingsList',
    );
    return result ?? '{}';
  }

  // MARK: - 时间权重方法

  @override
  Future<String> getCurrentTimeWeighting() async {
    final result = await methodChannel.invokeMethod<String>(
      'getCurrentTimeWeighting',
    );
    return result ?? 'Fast';
  }

  @override
  Future<bool> setTimeWeighting(String weighting) async {
    final result = await methodChannel.invokeMethod<bool>('setTimeWeighting', {
      'weighting': weighting,
    });
    return result ?? false;
  }

  @override
  Future<List<String>> getAvailableTimeWeightings() async {
    final result = await methodChannel.invokeMethod<List>(
      'getAvailableTimeWeightings',
    );
    if (result == null) return [];
    return result.map((e) => e.toString()).toList();
  }

  @override
  Future<String> getTimeWeightingsList() async {
    final result = await methodChannel.invokeMethod<String>(
      'getTimeWeightingsList',
    );
    return result ?? '{}';
  }

  // MARK: - 扩展的公共获取方法

  @override
  Future<String> getFormattedMeasurementDuration() async {
    final result = await methodChannel.invokeMethod<String>(
      'getFormattedMeasurementDuration',
    );
    return result ?? '00:00:00';
  }

  @override
  Future<double> getMeasurementDuration() async {
    final result = await methodChannel.invokeMethod<double>(
      'getMeasurementDuration',
    );
    return result ?? 0.0;
  }

  @override
  Future<String> getWeightingDisplayText() async {
    final result = await methodChannel.invokeMethod<String>(
      'getWeightingDisplayText',
    );
    return result ?? 'dB(A)F';
  }

  @override
  Future<double> getMinDecibel() async {
    final result = await methodChannel.invokeMethod<double>('getMinDecibel');
    return result ?? 0.0;
  }

  @override
  Future<double> getMaxDecibel() async {
    final result = await methodChannel.invokeMethod<double>('getMaxDecibel');
    return result ?? 0.0;
  }

  @override
  Future<double> getLeqDecibel() async {
    final result = await methodChannel.invokeMethod<double>('getLeqDecibel');
    return result ?? 0.0;
  }

  // MARK: - 图表数据获取方法

  @override
  Future<String> getTimeHistoryChartData({double timeRange = 60.0}) async {
    final result = await methodChannel.invokeMethod<String>(
      'getTimeHistoryChartData',
      {'timeRange': timeRange},
    );
    return result ?? '{}';
  }

  @override
  Future<String> getRealTimeIndicatorData() async {
    final result = await methodChannel.invokeMethod<String>(
      'getRealTimeIndicatorData',
    );
    return result ?? '{}';
  }

  @override
  Future<String> getSpectrumChartData({String bandType = '1/3'}) async {
    final result = await methodChannel.invokeMethod<String>(
      'getSpectrumChartData',
      {'bandType': bandType},
    );
    return result ?? '{}';
  }

  @override
  Future<String> getStatisticalDistributionChartData() async {
    final result = await methodChannel.invokeMethod<String>(
      'getStatisticalDistributionChartData',
    );
    return result ?? '{}';
  }

  @override
  Future<String> getLEQTrendChartData({double interval = 10.0}) async {
    final result = await methodChannel.invokeMethod<String>(
      'getLEQTrendChartData',
      {'interval': interval},
    );
    return result ?? '{}';
  }

  // MARK: - 设置方法

  @override
  Future<bool> resetAllData() async {
    final result = await methodChannel.invokeMethod<bool>('resetAllData');
    return result ?? false;
  }

  @override
  Future<bool> clearHistory() async {
    final result = await methodChannel.invokeMethod<bool>('clearHistory');
    return result ?? false;
  }

  // MARK: - 噪音测量计功能

  @override
  Future<Map<String, dynamic>> getNoiseDoseData({String? standard}) async {
    final result = await methodChannel.invokeMethod<Map>(
      'getNoiseDoseData',
      standard != null ? {'standard': standard} : null,
    );
    if (result == null) {
      return {};
    }
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<bool> isExceedingLimit(String standard) async {
    final result = await methodChannel.invokeMethod<bool>('isExceedingLimit', {
      'standard': standard,
    });
    return result ?? false;
  }

  @override
  Future<Map<String, dynamic>> getLimitComparisonResult(String standard) async {
    final result = await methodChannel.invokeMethod<Map>(
      'getLimitComparisonResult',
      {'standard': standard},
    );
    if (result == null) {
      return {};
    }
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<String> getDoseAccumulationChartData({
    double interval = 60.0,
    String? standard,
  }) async {
    final arguments = <String, dynamic>{'interval': interval};
    if (standard != null) {
      arguments['standard'] = standard;
    }

    final result = await methodChannel.invokeMethod<String>(
      'getDoseAccumulationChartData',
      arguments,
    );
    return result ?? '{}';
  }

  @override
  Future<String> getTWATrendChartData({
    double interval = 60.0,
    String? standard,
  }) async {
    final arguments = <String, dynamic>{'interval': interval};
    if (standard != null) {
      arguments['standard'] = standard;
    }

    final result = await methodChannel.invokeMethod<String>(
      'getTWATrendChartData',
      arguments,
    );
    return result ?? '{}';
  }

  @override
  Future<bool> setNoiseStandard(String standard) async {
    final result = await methodChannel.invokeMethod<bool>('setNoiseStandard', {
      'standard': standard,
    });
    return result ?? false;
  }

  @override
  Future<String> getCurrentNoiseStandard() async {
    final result = await methodChannel.invokeMethod<String>(
      'getCurrentNoiseStandard',
    );
    return result ?? 'niosh';
  }

  @override
  Future<List<String>> getAvailableNoiseStandards() async {
    final result = await methodChannel.invokeMethod<List>(
      'getAvailableNoiseStandards',
    );
    if (result == null) return [];
    return result.map((e) => e.toString()).toList();
  }

  @override
  Future<String?> generateNoiseDosimeterReport({String? standard}) async {
    final result = await methodChannel.invokeMethod<String>(
      'generateNoiseDosimeterReport',
      standard != null ? {'standard': standard} : null,
    );
    return result;
  }

  @override
  Future<String> getPermissibleExposureDurationTable({String? standard}) async {
    final result = await methodChannel.invokeMethod<String>(
      'getPermissibleExposureDurationTable',
      standard != null ? {'standard': standard} : null,
    );
    return result ?? '{}';
  }
}
