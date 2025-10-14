import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'decibel_meter_method_channel.dart';
import 'src/models/decibel_models.dart';

abstract class DecibelMeterPlatform extends PlatformInterface {
  /// Constructs a DecibelMeterPlatform.
  DecibelMeterPlatform() : super(token: _token);

  static final Object _token = Object();

  static DecibelMeterPlatform _instance = MethodChannelDecibelMeter();

  /// The default instance of [DecibelMeterPlatform] to use.
  ///
  /// Defaults to [MethodChannelDecibelMeter].
  static DecibelMeterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DecibelMeterPlatform] when
  /// they register themselves.
  static set instance(DecibelMeterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // MARK: - 基础方法

  Stream<Map<String, dynamic>> get onEventStream;

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  // MARK: - 核心测量方法

  /// 开始测量
  Future<bool> startMeasurement() {
    throw UnimplementedError('startMeasurement() has not been implemented.');
  }

  /// 停止测量
  Future<bool> stopMeasurement() {
    throw UnimplementedError('stopMeasurement() has not been implemented.');
  }

  // MARK: - 状态和数据获取方法

  /// 获取当前测量状态
  Future<String> getCurrentState() {
    throw UnimplementedError('getCurrentState() has not been implemented.');
  }

  /// 获取当前分贝值
  Future<double> getCurrentDecibel() {
    throw UnimplementedError('getCurrentDecibel() has not been implemented.');
  }

  /// 获取当前测量数据
  Future<DecibelMeasurement?> getCurrentMeasurement() {
    throw UnimplementedError(
      'getCurrentMeasurement() has not been implemented.',
    );
  }

  /// 获取统计信息（current, max, min）
  Future<Map<String, double>> getStatistics() {
    throw UnimplementedError('getStatistics() has not been implemented.');
  }

  /// 获取测量历史
  Future<List<DecibelMeasurement>> getMeasurementHistory() {
    throw UnimplementedError(
      'getMeasurementHistory() has not been implemented.',
    );
  }

  /// 获取当前完整统计信息
  Future<DecibelStatistics?> getCurrentStatistics() {
    throw UnimplementedError(
      'getCurrentStatistics() has not been implemented.',
    );
  }

  /// 获取实时LEQ值
  Future<double> getRealTimeLeq() {
    throw UnimplementedError('getRealTimeLeq() has not been implemented.');
  }

  /// 获取当前峰值
  Future<double> getCurrentPeak() {
    throw UnimplementedError('getCurrentPeak() has not been implemented.');
  }

  // MARK: - 校准方法

  /// 设置校准偏移
  Future<bool> setCalibrationOffset(double offset) {
    throw UnimplementedError(
      'setCalibrationOffset() has not been implemented.',
    );
  }

  /// 获取校准偏移
  Future<double> getCalibrationOffset() {
    throw UnimplementedError(
      'getCalibrationOffset() has not been implemented.',
    );
  }

  // MARK: - 频率权重方法

  /// 获取当前频率权重
  Future<String> getCurrentFrequencyWeighting() {
    throw UnimplementedError(
      'getCurrentFrequencyWeighting() has not been implemented.',
    );
  }

  /// 设置频率权重
  Future<bool> setFrequencyWeighting(String weighting) {
    throw UnimplementedError(
      'setFrequencyWeighting() has not been implemented.',
    );
  }

  /// 获取所有可用的频率权重
  Future<List<String>> getAvailableFrequencyWeightings() {
    throw UnimplementedError(
      'getAvailableFrequencyWeightings() has not been implemented.',
    );
  }

  /// 获取频率权重曲线数据
  Future<List<double>> getFrequencyWeightingCurve(String weighting) {
    throw UnimplementedError(
      'getFrequencyWeightingCurve() has not been implemented.',
    );
  }

  /// 获取频率权重列表（JSON格式）
  Future<String> getFrequencyWeightingsList() {
    throw UnimplementedError(
      'getFrequencyWeightingsList() has not been implemented.',
    );
  }

  // MARK: - 时间权重方法

  /// 获取当前时间权重
  Future<String> getCurrentTimeWeighting() {
    throw UnimplementedError(
      'getCurrentTimeWeighting() has not been implemented.',
    );
  }

  /// 设置时间权重
  Future<bool> setTimeWeighting(String weighting) {
    throw UnimplementedError('setTimeWeighting() has not been implemented.');
  }

  /// 获取所有可用的时间权重
  Future<List<String>> getAvailableTimeWeightings() {
    throw UnimplementedError(
      'getAvailableTimeWeightings() has not been implemented.',
    );
  }

  /// 获取时间权重列表（JSON格式）
  Future<String> getTimeWeightingsList() {
    throw UnimplementedError(
      'getTimeWeightingsList() has not been implemented.',
    );
  }

  // MARK: - 扩展的公共获取方法

  /// 获取格式化的测量时长（HH:mm:ss）
  Future<String> getFormattedMeasurementDuration() {
    throw UnimplementedError(
      'getFormattedMeasurementDuration() has not been implemented.',
    );
  }

  /// 获取测量时长（秒）
  Future<double> getMeasurementDuration() {
    throw UnimplementedError(
      'getMeasurementDuration() has not been implemented.',
    );
  }

  /// 获取权重显示文本（如：dB(A)F）
  Future<String> getWeightingDisplayText() {
    throw UnimplementedError(
      'getWeightingDisplayText() has not been implemented.',
    );
  }

  /// 获取最小分贝值
  Future<double> getMinDecibel() {
    throw UnimplementedError('getMinDecibel() has not been implemented.');
  }

  /// 获取最大分贝值
  Future<double> getMaxDecibel() {
    throw UnimplementedError('getMaxDecibel() has not been implemented.');
  }

  /// 获取LEQ值（等效连续声级）
  Future<double> getLeqDecibel() {
    throw UnimplementedError('getLeqDecibel() has not been implemented.');
  }

  // MARK: - 图表数据获取方法

  /// 获取时间历程图数据（JSON格式）
  Future<String> getTimeHistoryChartData({double timeRange = 60.0}) {
    throw UnimplementedError(
      'getTimeHistoryChartData() has not been implemented.',
    );
  }

  /// 获取实时指示器数据（JSON格式）
  Future<String> getRealTimeIndicatorData() {
    throw UnimplementedError(
      'getRealTimeIndicatorData() has not been implemented.',
    );
  }

  /// 获取频谱分析图数据（JSON格式）
  Future<String> getSpectrumChartData({String bandType = '1/3'}) {
    throw UnimplementedError(
      'getSpectrumChartData() has not been implemented.',
    );
  }

  /// 获取统计分布图数据（JSON格式）
  Future<String> getStatisticalDistributionChartData() {
    throw UnimplementedError(
      'getStatisticalDistributionChartData() has not been implemented.',
    );
  }

  /// 获取LEQ趋势图数据（JSON格式）
  Future<String> getLEQTrendChartData({double interval = 10.0}) {
    throw UnimplementedError(
      'getLEQTrendChartData() has not been implemented.',
    );
  }

  // MARK: - 设置方法

  /// 重置所有数据
  Future<bool> resetAllData() {
    throw UnimplementedError('resetAllData() has not been implemented.');
  }

  /// 清除历史记录
  Future<bool> clearHistory() {
    throw UnimplementedError('clearHistory() has not been implemented.');
  }

  // MARK: - 噪音测量计功能

  /// 获取完整的噪声剂量数据
  ///
  /// 返回包含剂量、TWA、预测时间等完整信息的数据对象
  /// 这是噪音测量计最主要的API方法
  ///
  /// - Parameter standard: 噪声限值标准，默认使用当前设置的标准
  /// - Returns: NoiseDoseData对象
  Future<Map<String, dynamic>> getNoiseDoseData({String? standard}) {
    throw UnimplementedError('getNoiseDoseData() has not been implemented.');
  }

  /// 检查是否超过限值
  ///
  /// 检查当前TWA或剂量是否超过指定标准的限值
  ///
  /// - Parameter standard: 噪声限值标准
  /// - Returns: 是否超过限值
  Future<bool> isExceedingLimit(String standard) {
    throw UnimplementedError('isExceedingLimit() has not been implemented.');
  }

  /// 获取限值比较结果
  ///
  /// 返回与指定标准的详细比较结果，包括余量、风险等级、建议措施
  ///
  /// - Parameter standard: 噪声限值标准
  /// - Returns: LimitComparisonResult对象
  Future<Map<String, dynamic>> getLimitComparisonResult(String standard) {
    throw UnimplementedError(
      'getLimitComparisonResult() has not been implemented.',
    );
  }

  /// 获取剂量累积图数据
  ///
  /// 返回剂量随时间累积的数据，用于绘制剂量累积图
  ///
  /// - Parameters:
  ///   - interval: 采样间隔（秒），默认60秒
  ///   - standard: 噪声限值标准
  /// - Returns: DoseAccumulationChartData对象
  Future<String> getDoseAccumulationChartData({
    double interval = 60.0,
    String? standard,
  }) {
    throw UnimplementedError(
      'getDoseAccumulationChartData() has not been implemented.',
    );
  }

  /// 获取TWA趋势图数据
  ///
  /// 返回TWA随时间变化的数据，用于绘制TWA趋势图
  ///
  /// - Parameters:
  ///   - interval: 采样间隔（秒），默认60秒
  ///   - standard: 噪声限值标准
  /// - Returns: TWATrendChartData对象
  Future<String> getTWATrendChartData({
    double interval = 60.0,
    String? standard,
  }) {
    throw UnimplementedError(
      'getTWATrendChartData() has not been implemented.',
    );
  }

  /// 设置噪声限值标准
  ///
  /// 切换使用的噪声限值标准（OSHA、NIOSH、GBZ、EU）
  ///
  /// - Parameter standard: 要设置的标准
  Future<bool> setNoiseStandard(String standard) {
    throw UnimplementedError('setNoiseStandard() has not been implemented.');
  }

  /// 获取当前噪声限值标准
  ///
  /// - Returns: 当前使用的标准
  Future<String> getCurrentNoiseStandard() {
    throw UnimplementedError(
      'getCurrentNoiseStandard() has not been implemented.',
    );
  }

  /// 获取所有可用的噪声限值标准列表
  ///
  /// - Returns: 所有标准的数组
  Future<List<String>> getAvailableNoiseStandards() {
    throw UnimplementedError(
      'getAvailableNoiseStandards() has not been implemented.',
    );
  }

  /// 生成噪音测量计综合报告
  ///
  /// 生成包含所有关键数据的完整报告，用于法规符合性评估
  ///
  /// - Parameter standard: 噪声限值标准
  /// - Returns: NoiseDosimeterReport对象，如果未开始测量则返回null
  Future<String?> generateNoiseDosimeterReport({String? standard}) {
    throw UnimplementedError(
      'generateNoiseDosimeterReport() has not been implemented.',
    );
  }

  /// 获取允许暴露时长表
  ///
  /// 根据当前测量数据生成允许暴露时长表，包含每个声级的累计暴露时间和剂量
  ///
  /// - Parameter standard: 噪声限值标准，默认使用当前设置的标准
  /// - Returns: PermissibleExposureDurationTable对象
  Future<String> getPermissibleExposureDurationTable({String? standard}) {
    throw UnimplementedError(
      'getPermissibleExposureDurationTable() has not been implemented.',
    );
  }
}
