library;

import 'decibel_meter_platform_interface.dart';
import 'src/models/decibel_models.dart';

export 'src/models/decibel_models.dart';

/// 分贝测量仪 - Flutter 插件主类
///
/// 提供专业的分贝测量功能，符合国际标准 IEC 61672-1、ISO 1996-1
///
/// **主要功能**：
/// - 实时音频采集和分贝计算
/// - 频率权重应用（A、B、C、Z、ITU-R 468）
/// - 时间权重应用（Fast、Slow、Impulse）
/// - 统计指标计算（AVG、MIN、MAX、PEAK、LEQ、L10、L50、L90）
/// - 图表数据生成（时间历程、频谱、统计分布、LEQ趋势）
/// - 校准功能
///
/// **使用示例**：
/// ```dart
/// final decibelMeter = DecibelMeter();
///
/// // 开始测量
/// await decibelMeter.startMeasurement();
///
/// // 获取当前分贝值
/// final decibel = await decibelMeter.getCurrentDecibel();
///
/// // 获取实时指示器数据
/// final indicatorJson = await decibelMeter.getRealTimeIndicatorData();
///
/// // 停止测量
/// await decibelMeter.stopMeasurement();
/// ```
class DecibelMeter {
  // MARK: - 基础方法

  /// 获取平台版本
  Future<String?> getPlatformVersion() {
    return DecibelMeterPlatform.instance.getPlatformVersion();
  }

  // MARK: - 核心测量方法

  /// 开始测量
  ///
  /// 启动音频采集和分贝测量，初始化所有统计值
  /// 如果已在测量中，则忽略此调用
  ///
  /// **功能**：
  /// - 请求麦克风权限
  /// - 启动音频引擎
  /// - 开始后台任务
  /// - 初始化统计值（MIN、MAX、PEAK）
  /// - 记录测量开始时间
  Future<bool> startMeasurement() {
    return DecibelMeterPlatform.instance.startMeasurement();
  }

  /// 停止测量
  ///
  /// 停止音频采集和分贝测量，计算最终统计信息
  ///
  /// **功能**：
  /// - 停止音频引擎
  /// - 结束后台任务
  /// - 计算最终统计信息（如果有测量数据）
  /// - 更新状态为idle
  Future<bool> stopMeasurement() {
    return DecibelMeterPlatform.instance.stopMeasurement();
  }

  // MARK: - 状态和数据获取方法

  /// 获取当前测量状态
  ///
  /// 返回值：
  /// - "idle" - 停止状态
  /// - "measuring" - 测量中
  /// - "error: xxx" - 错误状态（包含错误信息）
  Future<String> getCurrentState() {
    return DecibelMeterPlatform.instance.getCurrentState();
  }

  /// 获取当前分贝值（已应用权重和校准）
  Future<double> getCurrentDecibel() {
    return DecibelMeterPlatform.instance.getCurrentDecibel();
  }

  /// 获取当前测量数据
  ///
  /// 返回包含完整测量信息的对象，包括：
  /// - 原始分贝值
  /// - A权重分贝值
  /// - Fast/Slow时间权重值
  /// - 校准后的分贝值
  /// - 频谱数据
  Future<DecibelMeasurement?> getCurrentMeasurement() {
    return DecibelMeterPlatform.instance.getCurrentMeasurement();
  }

  /// 获取统计信息（current, max, min）
  ///
  /// 返回包含以下键的 Map：
  /// - "current": 当前分贝值
  /// - "max": 最大分贝值（应用时间权重）
  /// - "min": 最小分贝值（应用时间权重）
  Future<Map<String, double>> getStatistics() {
    return DecibelMeterPlatform.instance.getStatistics();
  }

  /// 获取测量历史记录
  ///
  /// 返回所有历史测量数据的数组（最多1000条）
  Future<List<DecibelMeasurement>> getMeasurementHistory() {
    return DecibelMeterPlatform.instance.getMeasurementHistory();
  }

  /// 获取当前完整统计信息
  ///
  /// 返回包含所有统计指标的对象：
  /// - AVG、MIN、MAX、PEAK
  /// - LEQ（等效连续声级）
  /// - L10、L50、L90（百分位数）
  /// - 标准偏差
  Future<DecibelStatistics?> getCurrentStatistics() {
    return DecibelMeterPlatform.instance.getCurrentStatistics();
  }

  /// 获取实时LEQ值（等效连续声级）
  ///
  /// LEQ是能量平均值，符合ISO 1996-1标准
  Future<double> getRealTimeLeq() {
    return DecibelMeterPlatform.instance.getRealTimeLeq();
  }

  /// 获取当前峰值（不应用时间权重）
  Future<double> getCurrentPeak() {
    return DecibelMeterPlatform.instance.getCurrentPeak();
  }

  // MARK: - 校准方法

  /// 设置校准偏移
  ///
  /// 用于补偿设备差异，正值表示增加，负值表示减少
  ///
  /// 参数：
  /// - offset: 校准偏移值（dB）
  Future<bool> setCalibrationOffset(double offset) {
    return DecibelMeterPlatform.instance.setCalibrationOffset(offset);
  }

  /// 获取当前校准偏移值
  Future<double> getCalibrationOffset() {
    return DecibelMeterPlatform.instance.getCalibrationOffset();
  }

  // MARK: - 频率权重方法

  /// 获取当前频率权重
  ///
  /// 返回值：
  /// - "A-weight" - A权重（最常用）
  /// - "B-weight" - B权重（已弃用）
  /// - "C-weight" - C权重
  /// - "Z-weight" - Z权重（无修正）
  /// - "ITU-R 468" - ITU-R 468权重
  Future<String> getCurrentFrequencyWeighting() {
    return DecibelMeterPlatform.instance.getCurrentFrequencyWeighting();
  }

  /// 设置频率权重
  ///
  /// 参数：
  /// - weighting: 频率权重类型（如 "A-weight", "C-weight"）
  Future<bool> setFrequencyWeighting(String weighting) {
    return DecibelMeterPlatform.instance.setFrequencyWeighting(weighting);
  }

  /// 获取所有可用的频率权重列表
  Future<List<String>> getAvailableFrequencyWeightings() {
    return DecibelMeterPlatform.instance.getAvailableFrequencyWeightings();
  }

  /// 获取频率权重曲线数据
  ///
  /// 参数：
  /// - weighting: 频率权重类型
  ///
  /// 返回值：频率响应曲线数据数组
  Future<List<double>> getFrequencyWeightingCurve(String weighting) {
    return DecibelMeterPlatform.instance.getFrequencyWeightingCurve(weighting);
  }

  /// 获取频率权重列表（JSON格式）
  ///
  /// 返回包含所有频率权重选项的 JSON 字符串，包括：
  /// - 显示名称
  /// - 符号
  /// - 描述
  /// - 标准
  /// - 当前选择
  Future<String> getFrequencyWeightingsList() {
    return DecibelMeterPlatform.instance.getFrequencyWeightingsList();
  }

  // MARK: - 时间权重方法

  /// 获取当前时间权重
  ///
  /// 返回值：
  /// - "Fast" - 快响应（125ms）
  /// - "Slow" - 慢响应（1000ms）
  /// - "Impulse" - 脉冲响应（35ms↑/1500ms↓）
  Future<String> getCurrentTimeWeighting() {
    return DecibelMeterPlatform.instance.getCurrentTimeWeighting();
  }

  /// 设置时间权重
  ///
  /// 参数：
  /// - weighting: 时间权重类型（如 "Fast", "Slow", "Impulse"）
  Future<bool> setTimeWeighting(String weighting) {
    return DecibelMeterPlatform.instance.setTimeWeighting(weighting);
  }

  /// 获取所有可用的时间权重列表
  Future<List<String>> getAvailableTimeWeightings() {
    return DecibelMeterPlatform.instance.getAvailableTimeWeightings();
  }

  /// 获取时间权重列表（JSON格式）
  ///
  /// 返回包含所有时间权重选项的 JSON 字符串，包括：
  /// - 显示名称
  /// - 符号
  /// - 描述
  /// - 应用场景
  /// - 标准
  /// - 当前选择
  Future<String> getTimeWeightingsList() {
    return DecibelMeterPlatform.instance.getTimeWeightingsList();
  }

  // MARK: - 扩展的公共获取方法

  /// 获取格式化的测量时长（HH:mm:ss）
  ///
  /// 返回格式：如 "00:05:23" 表示测量了5分23秒
  Future<String> getFormattedMeasurementDuration() {
    return DecibelMeterPlatform.instance.getFormattedMeasurementDuration();
  }

  /// 获取测量时长（秒）
  ///
  /// 返回从测量开始到现在的秒数
  Future<double> getMeasurementDuration() {
    return DecibelMeterPlatform.instance.getMeasurementDuration();
  }

  /// 获取权重显示文本
  ///
  /// 返回符合国际标准的权重显示格式
  ///
  /// 示例：
  /// - "dB(A)F" - A权重 + Fast时间权重
  /// - "dB(C)S" - C权重 + Slow时间权重
  Future<String> getWeightingDisplayText() {
    return DecibelMeterPlatform.instance.getWeightingDisplayText();
  }

  /// 获取最小分贝值（应用时间权重）
  Future<double> getMinDecibel() {
    return DecibelMeterPlatform.instance.getMinDecibel();
  }

  /// 获取最大分贝值（应用时间权重）
  Future<double> getMaxDecibel() {
    return DecibelMeterPlatform.instance.getMaxDecibel();
  }

  /// 获取LEQ值（等效连续声级）
  Future<double> getLeqDecibel() {
    return DecibelMeterPlatform.instance.getLeqDecibel();
  }

  // MARK: - 图表数据获取方法

  /// 获取时间历程图数据（JSON格式）
  ///
  /// 用于绘制实时分贝变化曲线
  ///
  /// 参数：
  /// - timeRange: 时间范围（秒），默认60秒，表示显示最近多少秒的数据
  ///
  /// 返回：JSON字符串，包含数据点、时间范围、分贝范围等
  Future<String> getTimeHistoryChartData({double timeRange = 60.0}) {
    return DecibelMeterPlatform.instance.getTimeHistoryChartData(
      timeRange: timeRange,
    );
  }

  /// 获取实时指示器数据（JSON格式）
  ///
  /// 包含所有关键测量指标：
  /// - currentDecibel: 当前分贝值
  /// - leq: 等效连续声级
  /// - min: 最小值
  /// - max: 最大值
  /// - peak: 峰值
  /// - weightingDisplay: 权重显示文本
  /// - timestamp: 时间戳
  ///
  /// 返回：JSON字符串
  Future<String> getRealTimeIndicatorData() {
    return DecibelMeterPlatform.instance.getRealTimeIndicatorData();
  }

  /// 获取频谱分析图数据（JSON格式）
  ///
  /// 用于显示各频段的声压级分布
  ///
  /// 参数：
  /// - bandType: 倍频程类型
  ///   - "1/1": 1/1倍频程（10个频点）
  ///   - "1/3": 1/3倍频程（30个频点，默认）
  ///
  /// 返回：JSON字符串，包含各频率点的声压级数据
  Future<String> getSpectrumChartData({String bandType = '1/3'}) {
    return DecibelMeterPlatform.instance.getSpectrumChartData(
      bandType: bandType,
    );
  }

  /// 获取统计分布图数据（JSON格式）
  ///
  /// 用于分析噪声的统计特性
  ///
  /// 包含关键指标：
  /// - L10: 10%时间超过的声级（噪声峰值特征）
  /// - L50: 50%时间超过的声级（中位数）
  /// - L90: 90%时间超过的声级（背景噪声水平）
  ///
  /// 返回：JSON字符串
  Future<String> getStatisticalDistributionChartData() {
    return DecibelMeterPlatform.instance.getStatisticalDistributionChartData();
  }

  /// 获取LEQ趋势图数据（JSON格式）
  ///
  /// 用于职业健康监测和长期暴露评估
  ///
  /// 参数：
  /// - interval: 采样间隔（秒），默认10秒
  ///
  /// 包含数据：
  /// - 时段LEQ：每个时间段内的LEQ值
  /// - 累积LEQ：从开始到当前的总体LEQ值
  ///
  /// 返回：JSON字符串
  Future<String> getLEQTrendChartData({double interval = 10.0}) {
    return DecibelMeterPlatform.instance.getLEQTrendChartData(
      interval: interval,
    );
  }

  // MARK: - 设置方法

  /// 重置所有数据
  ///
  /// 完全重置分贝测量仪，清除所有测量数据和设置
  ///
  /// **重置内容**：
  /// - 停止测量（如果正在测量）
  /// - 清除所有历史数据
  /// - 重置统计值（MIN=-1, MAX=-1, PEAK=-1, LEQ=0）
  /// - 重置校准偏移为0
  /// - 重置状态为idle
  ///
  /// **注意**：此操作不可恢复，会丢失所有测量数据
  Future<bool> resetAllData() {
    return DecibelMeterPlatform.instance.resetAllData();
  }

  /// 清除历史记录
  ///
  /// 清除所有测量历史数据，但保留当前测量状态和校准设置
  Future<bool> clearHistory() {
    return DecibelMeterPlatform.instance.clearHistory();
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
    return DecibelMeterPlatform.instance.getNoiseDoseData(standard: standard);
  }

  /// 检查是否超过限值
  ///
  /// 检查当前TWA或剂量是否超过指定标准的限值
  ///
  /// - Parameter standard: 噪声限值标准
  /// - Returns: 是否超过限值
  Future<bool> isExceedingLimit(String standard) {
    return DecibelMeterPlatform.instance.isExceedingLimit(standard);
  }

  /// 获取限值比较结果
  ///
  /// 返回与指定标准的详细比较结果，包括余量、风险等级、建议措施
  ///
  /// - Parameter standard: 噪声限值标准
  /// - Returns: LimitComparisonResult对象
  Future<Map<String, dynamic>> getLimitComparisonResult(String standard) {
    return DecibelMeterPlatform.instance.getLimitComparisonResult(standard);
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
    return DecibelMeterPlatform.instance.getDoseAccumulationChartData(
      interval: interval,
      standard: standard,
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
    return DecibelMeterPlatform.instance.getTWATrendChartData(
      interval: interval,
      standard: standard,
    );
  }

  /// 设置噪声限值标准
  ///
  /// 切换使用的噪声限值标准（OSHA、NIOSH、GBZ、EU）
  ///
  /// - Parameter standard: 要设置的标准
  Future<bool> setNoiseStandard(String standard) {
    return DecibelMeterPlatform.instance.setNoiseStandard(standard);
  }

  /// 获取当前噪声限值标准
  ///
  /// - Returns: 当前使用的标准
  Future<String> getCurrentNoiseStandard() {
    return DecibelMeterPlatform.instance.getCurrentNoiseStandard();
  }

  /// 获取所有可用的噪声限值标准列表
  ///
  /// - Returns: 所有标准的数组
  Future<List<String>> getAvailableNoiseStandards() {
    return DecibelMeterPlatform.instance.getAvailableNoiseStandards();
  }

  /// 生成噪音测量计综合报告
  ///
  /// 生成包含所有关键数据的完整报告，用于法规符合性评估
  ///
  /// - Parameter standard: 噪声限值标准
  /// - Returns: NoiseDosimeterReport对象，如果未开始测量则返回null
  Future<String?> generateNoiseDosimeterReport({String? standard}) {
    return DecibelMeterPlatform.instance.generateNoiseDosimeterReport(
      standard: standard,
    );
  }

  /// 获取允许暴露时长表
  ///
  /// 根据当前测量数据生成允许暴露时长表，包含每个声级的累计暴露时间和剂量
  ///
  /// - Parameter standard: 噪声限值标准，默认使用当前设置的标准
  /// - Returns: PermissibleExposureDurationTable对象
  Future<String> getPermissibleExposureDurationTable({String? standard}) {
    return DecibelMeterPlatform.instance.getPermissibleExposureDurationTable(
      standard: standard,
    );
  }
}
