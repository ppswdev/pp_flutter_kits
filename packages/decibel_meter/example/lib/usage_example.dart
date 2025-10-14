import 'package:decibel_meter/decibel_meter.dart';
import 'dart:async';
import 'dart:convert';

/// DecibelMeter 使用示例
///
/// 演示如何使用分贝测量仪的所有功能
class DecibelMeterUsageExample {
  final DecibelMeter _decibelMeter = DecibelMeter();

  /// 示例1: 基本测量流程
  Future<void> basicMeasurementExample() async {
    print('=== 基本测量流程 ===');

    // 1. 开始测量
    final started = await _decibelMeter.startMeasurement();
    print('开始测量: $started');

    // 2. 等待一段时间以收集数据
    await Future.delayed(const Duration(seconds: 5));

    // 3. 获取当前分贝值
    final currentDecibel = await _decibelMeter.getCurrentDecibel();
    print('当前分贝: ${currentDecibel.toStringAsFixed(1)} dB');

    // 4. 获取统计信息
    final stats = await _decibelMeter.getStatistics();
    print('当前: ${stats["current"]?.toStringAsFixed(1)} dB');
    print('最大: ${stats["max"]?.toStringAsFixed(1)} dB');
    print('最小: ${stats["min"]?.toStringAsFixed(1)} dB');

    // 5. 停止测量
    final stopped = await _decibelMeter.stopMeasurement();
    print('停止测量: $stopped\n');
  }

  /// 示例2: 获取详细测量数据
  Future<void> detailedMeasurementExample() async {
    print('=== 详细测量数据 ===');

    await _decibelMeter.startMeasurement();
    await Future.delayed(const Duration(seconds: 3));

    // 获取当前测量数据
    final measurement = await _decibelMeter.getCurrentMeasurement();
    if (measurement != null) {
      print('时间戳: ${measurement.timestamp}');
      print('原始分贝: ${measurement.rawDecibel.toStringAsFixed(1)} dB');
      print('A权重分贝: ${measurement.aWeightedDecibel.toStringAsFixed(1)} dB');
      print('Fast权重: ${measurement.fastDecibel.toStringAsFixed(1)} dB');
      print('Slow权重: ${measurement.slowDecibel.toStringAsFixed(1)} dB');
      print('校准后分贝: ${measurement.calibratedDecibel.toStringAsFixed(1)} dB');
      print('等级描述: ${measurement.levelDescription}');
      print('等级颜色: ${measurement.levelColor}');
    }

    await _decibelMeter.stopMeasurement();
    print('');
  }

  /// 示例3: 完整统计信息
  Future<void> statisticsExample() async {
    print('=== 完整统计信息 ===');

    await _decibelMeter.startMeasurement();
    await Future.delayed(const Duration(seconds: 10));

    // 获取完整统计信息
    final statistics = await _decibelMeter.getCurrentStatistics();
    if (statistics != null) {
      print('样本数量: ${statistics.sampleCount}');
      print('测量时长: ${statistics.measurementDuration.toStringAsFixed(1)} 秒');
      print('AVG: ${statistics.avgDecibel.toStringAsFixed(1)} dB');
      print('MIN: ${statistics.minDecibel.toStringAsFixed(1)} dB');
      print('MAX: ${statistics.maxDecibel.toStringAsFixed(1)} dB');
      print('PEAK: ${statistics.peakDecibel.toStringAsFixed(1)} dB');
      print('LEQ: ${statistics.leqDecibel.toStringAsFixed(1)} dB');
      print('L10: ${statistics.l10Decibel.toStringAsFixed(1)} dB');
      print('L50: ${statistics.l50Decibel.toStringAsFixed(1)} dB');
      print('L90: ${statistics.l90Decibel.toStringAsFixed(1)} dB');
      print('标准偏差: ${statistics.standardDeviation.toStringAsFixed(2)} dB');
      print('摘要: ${statistics.summary}');
    }

    await _decibelMeter.stopMeasurement();
    print('');
  }

  /// 示例4: 频率权重设置
  Future<void> frequencyWeightingExample() async {
    print('=== 频率权重设置 ===');

    // 获取所有可用的频率权重
    final weightings = await _decibelMeter.getAvailableFrequencyWeightings();
    print('可用频率权重: ${weightings.join(", ")}');

    // 获取当前频率权重
    final current = await _decibelMeter.getCurrentFrequencyWeighting();
    print('当前频率权重: $current');

    // 设置为C权重
    await _decibelMeter.setFrequencyWeighting('C-weight');
    final newWeighting = await _decibelMeter.getCurrentFrequencyWeighting();
    print('新频率权重: $newWeighting');

    // 获取频率权重列表（JSON格式）
    final weightingsList = await _decibelMeter.getFrequencyWeightingsList();
    final decoded = jsonDecode(weightingsList);
    print('频率权重列表: ${decoded["options"]?.length ?? 0} 个选项');
    print('当前选择: ${decoded["currentSelection"]}\n');
  }

  /// 示例5: 时间权重设置
  Future<void> timeWeightingExample() async {
    print('=== 时间权重设置 ===');

    // 获取所有可用的时间权重
    final weightings = await _decibelMeter.getAvailableTimeWeightings();
    print('可用时间权重: ${weightings.join(", ")}');

    // 获取当前时间权重
    final current = await _decibelMeter.getCurrentTimeWeighting();
    print('当前时间权重: $current');

    // 设置为Slow权重
    await _decibelMeter.setTimeWeighting('Slow');
    final newWeighting = await _decibelMeter.getCurrentTimeWeighting();
    print('新时间权重: $newWeighting');

    // 获取权重显示文本
    final displayText = await _decibelMeter.getWeightingDisplayText();
    print('权重显示文本: $displayText\n');
  }

  /// 示例6: 校准功能
  Future<void> calibrationExample() async {
    print('=== 校准功能 ===');

    // 获取当前校准偏移
    final offset = await _decibelMeter.getCalibrationOffset();
    print('当前校准偏移: ${offset.toStringAsFixed(1)} dB');

    // 设置校准偏移为 +3.0 dB
    await _decibelMeter.setCalibrationOffset(3.0);
    final newOffset = await _decibelMeter.getCalibrationOffset();
    print('新校准偏移: ${newOffset.toStringAsFixed(1)} dB');

    // 重置校准
    await _decibelMeter.setCalibrationOffset(0.0);
    print('校准已重置\n');
  }

  /// 示例7: 实时指示器数据
  Future<void> realTimeIndicatorExample() async {
    print('=== 实时指示器数据 ===');

    await _decibelMeter.startMeasurement();
    await Future.delayed(const Duration(seconds: 5));

    // 获取实时指示器数据（JSON格式）
    final indicatorJson = await _decibelMeter.getRealTimeIndicatorData();
    final indicator = jsonDecode(indicatorJson);

    print('当前分贝: ${indicator["currentDecibel"]} dB');
    print('LEQ: ${indicator["leq"]} dB');
    print('MIN: ${indicator["min"]} dB');
    print('MAX: ${indicator["max"]} dB');
    print('PEAK: ${indicator["peak"]} dB');
    print('权重显示: ${indicator["weightingDisplay"]}');
    print('时间戳: ${indicator["timestamp"]}');

    await _decibelMeter.stopMeasurement();
    print('');
  }

  /// 示例8: 时间历程图数据
  Future<void> timeHistoryChartExample() async {
    print('=== 时间历程图数据 ===');

    await _decibelMeter.startMeasurement();
    await Future.delayed(const Duration(seconds: 10));

    // 获取最近60秒的时间历程图数据
    final chartJson = await _decibelMeter.getTimeHistoryChartData(
      timeRange: 60.0,
    );
    final chart = jsonDecode(chartJson);

    print('数据点数量: ${chart["dataPoints"]?.length ?? 0}');
    print('时间范围: ${chart["timeRange"]} 秒');
    print('分贝范围: ${chart["minDecibel"]} - ${chart["maxDecibel"]} dB');
    print('图表标题: ${chart["title"]}');

    await _decibelMeter.stopMeasurement();
    print('');
  }

  /// 示例9: 频谱分析图数据
  Future<void> spectrumChartExample() async {
    print('=== 频谱分析图数据 ===');

    await _decibelMeter.startMeasurement();
    await Future.delayed(const Duration(seconds: 3));

    // 获取1/3倍频程频谱数据
    final spectrumJson = await _decibelMeter.getSpectrumChartData(
      bandType: '1/3',
    );
    final spectrum = jsonDecode(spectrumJson);

    print('倍频程类型: ${spectrum["bandType"]}');
    print('数据点数量: ${spectrum["dataPoints"]?.length ?? 0}');
    print(
      '频率范围: ${spectrum["frequencyRangeMin"]} - ${spectrum["frequencyRangeMax"]} Hz',
    );
    print('图表标题: ${spectrum["title"]}');

    await _decibelMeter.stopMeasurement();
    print('');
  }

  /// 示例10: 统计分布图数据
  Future<void> statisticalDistributionExample() async {
    print('=== 统计分布图数据 ===');

    await _decibelMeter.startMeasurement();
    await Future.delayed(const Duration(seconds: 15));

    // 获取统计分布图数据
    final distributionJson = await _decibelMeter
        .getStatisticalDistributionChartData();
    final distribution = jsonDecode(distributionJson);

    print('L10: ${distribution["l10"]} dB (噪声峰值)');
    print('L50: ${distribution["l50"]} dB (中位数)');
    print('L90: ${distribution["l90"]} dB (背景噪声)');
    print('数据点数量: ${distribution["dataPoints"]?.length ?? 0}');
    print('图表标题: ${distribution["title"]}');

    await _decibelMeter.stopMeasurement();
    print('');
  }

  /// 示例11: LEQ趋势图数据
  Future<void> leqTrendExample() async {
    print('=== LEQ趋势图数据 ===');

    await _decibelMeter.startMeasurement();
    await Future.delayed(const Duration(seconds: 30));

    // 获取LEQ趋势图数据（每10秒一个数据点）
    final leqTrendJson = await _decibelMeter.getLEQTrendChartData(
      interval: 10.0,
    );
    final leqTrend = jsonDecode(leqTrendJson);

    print('当前LEQ: ${leqTrend["currentLeq"]} dB');
    print('时间范围: ${leqTrend["timeRange"]} 秒');
    print('数据点数量: ${leqTrend["dataPoints"]?.length ?? 0}');
    print('图表标题: ${leqTrend["title"]}');

    await _decibelMeter.stopMeasurement();
    print('');
  }

  /// 示例12: 测量历史记录
  Future<void> measurementHistoryExample() async {
    print('=== 测量历史记录 ===');

    await _decibelMeter.startMeasurement();
    await Future.delayed(const Duration(seconds: 5));

    // 获取测量历史
    final history = await _decibelMeter.getMeasurementHistory();
    print('历史记录数量: ${history.length}');

    if (history.isNotEmpty) {
      print('第一条记录:');
      final first = history.first;
      print('  时间: ${first.timestamp}');
      print('  分贝: ${first.calibratedDecibel.toStringAsFixed(1)} dB');
      print('  等级: ${first.levelDescription}');

      print('最后一条记录:');
      final last = history.last;
      print('  时间: ${last.timestamp}');
      print('  分贝: ${last.calibratedDecibel.toStringAsFixed(1)} dB');
      print('  等级: ${last.levelDescription}');
    }

    await _decibelMeter.stopMeasurement();
    print('');
  }

  /// 示例13: 测量时长
  Future<void> measurementDurationExample() async {
    print('=== 测量时长 ===');

    await _decibelMeter.startMeasurement();

    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 1));
      final formatted = await _decibelMeter.getFormattedMeasurementDuration();
      final seconds = await _decibelMeter.getMeasurementDuration();
      print('时长: $formatted (${seconds.toStringAsFixed(1)}秒)');
    }

    await _decibelMeter.stopMeasurement();
    print('');
  }

  /// 示例14: 重置和清除
  Future<void> resetAndClearExample() async {
    print('=== 重置和清除 ===');

    await _decibelMeter.startMeasurement();
    await Future.delayed(const Duration(seconds: 3));

    // 清除历史记录（保留当前测量状态）
    await _decibelMeter.clearHistory();
    print('历史记录已清除');

    final history = await _decibelMeter.getMeasurementHistory();
    print('历史记录数量: ${history.length}');

    // 重置所有数据（停止测量并清除所有数据）
    await _decibelMeter.resetAllData();
    print('所有数据已重置');

    final state = await _decibelMeter.getCurrentState();
    print('当前状态: $state\n');
  }

  /// 运行所有示例
  Future<void> runAllExamples() async {
    print('========================================');
    print('   DecibelMeter 使用示例');
    print('========================================\n');

    try {
      await basicMeasurementExample();
      await detailedMeasurementExample();
      await statisticsExample();
      await frequencyWeightingExample();
      await timeWeightingExample();
      await calibrationExample();
      await realTimeIndicatorExample();
      await timeHistoryChartExample();
      await spectrumChartExample();
      await statisticalDistributionExample();
      await leqTrendExample();
      await measurementHistoryExample();
      await measurementDurationExample();
      await resetAndClearExample();
      await noiseDosimeterExample();

      print('========================================');
      print('   所有示例运行完成！');
      print('========================================');
    } catch (e) {
      print('错误: $e');
    }
  }

  /// 噪音测量计功能示例
  Future<void> noiseDosimeterExample() async {
    print('\n🔊 噪音测量计功能示例');
    print('=' * 50);

    // 设置噪声限值标准
    print('\n📋 设置噪声限值标准...');
    await _decibelMeter.setNoiseStandard('niosh');
    final currentStandard = await _decibelMeter.getCurrentNoiseStandard();
    print('当前标准: $currentStandard');

    // 获取所有可用的噪声限值标准
    final availableStandards = await _decibelMeter.getAvailableNoiseStandards();
    print('可用标准: $availableStandards');

    // 获取噪声剂量数据
    print('\n📊 获取噪声剂量数据...');
    final doseData = await _decibelMeter.getNoiseDoseData(standard: 'niosh');
    print('剂量百分比: ${doseData["dosePercentage"]}%');
    print('剂量率: ${doseData["doseRate"]} %/小时');
    print('TWA值: ${doseData["twa"]} dB(A)');
    print('暴露时长: ${doseData["duration"]} 小时');
    print('是否超标: ${doseData["isExceeding"]}');
    print('限值余量: ${doseData["limitMargin"]} dB');
    print('风险等级: ${doseData["riskLevel"]}');

    // 检查是否超过限值
    print('\n⚠️ 检查限值...');
    final isExceeding = await _decibelMeter.isExceedingLimit('niosh');
    print('是否超过NIOSH限值: $isExceeding');

    // 获取限值比较结果
    print('\n📈 获取限值比较结果...');
    final comparisonResult = await _decibelMeter.getLimitComparisonResult(
      'niosh',
    );
    print('当前TWA: ${comparisonResult["currentTWA"]} dB(A)');
    print('TWA限值: ${comparisonResult["twaLimit"]} dB(A)');
    print('当前剂量: ${comparisonResult["currentDose"]}%');
    print('符合性状态: ${comparisonResult["isExceeding"] ? "超标" : "符合标准"}');
    print('建议措施: ${comparisonResult["recommendations"]}');

    // 获取剂量累积图数据
    print('\n📈 获取剂量累积图数据...');
    final doseChartJson = await _decibelMeter.getDoseAccumulationChartData(
      interval: 60.0,
      standard: 'niosh',
    );
    final doseChart = jsonDecode(doseChartJson);
    print('当前剂量: ${doseChart["currentDose"]}%');
    print('限值线: ${doseChart["limitLine"]}%');
    print('时间范围: ${doseChart["timeRange"]} 小时');
    print('数据点数量: ${doseChart["dataPoints"]?.length ?? 0}');

    // 获取TWA趋势图数据
    print('\n📈 获取TWA趋势图数据...');
    final twaChartJson = await _decibelMeter.getTWATrendChartData(
      interval: 60.0,
      standard: 'niosh',
    );
    final twaChart = jsonDecode(twaChartJson);
    print('当前TWA: ${twaChart["currentTWA"]} dB(A)');
    print('限值线: ${twaChart["limitLine"]} dB(A)');
    print('时间范围: ${twaChart["timeRange"]} 小时');
    print('数据点数量: ${twaChart["dataPoints"]?.length ?? 0}');

    // 获取允许暴露时长表
    print('\n📋 获取允许暴露时长表...');
    final durationTableJson = await _decibelMeter
        .getPermissibleExposureDurationTable(standard: 'niosh');
    final durationTable = jsonDecode(durationTableJson);
    print('标准: ${durationTable["standard"]}');
    print('基准限值: ${durationTable["criterionLevel"]} dB(A)');
    print('交换率: ${durationTable["exchangeRate"]} dB');
    print('天花板限值: ${durationTable["ceilingLimit"]} dB(A)');
    print('总剂量: ${durationTable["totalDose"]}%');
    print('超标声级数: ${durationTable["exceedingLevelsCount"]}');

    // 显示前5个暴露时长数据
    final durations = durationTable["durations"] as List?;
    if (durations != null && durations.isNotEmpty) {
      print('前5个暴露时长数据:');
      for (int i = 0; i < (durations.length < 5 ? durations.length : 5); i++) {
        final duration = durations[i];
        print(
          '  ${duration["soundLevel"]} dB(A): ${duration["formattedAccumulatedDuration"]} / ${duration["formattedAllowedDuration"]} (${duration["currentLevelDose"]}%)',
        );
      }
    }

    // 生成噪音测量计综合报告
    print('\n📄 生成综合报告...');
    final reportJson = await _decibelMeter.generateNoiseDosimeterReport(
      standard: 'niosh',
    );
    if (reportJson != null) {
      final report = jsonDecode(reportJson);
      print('报告生成时间: ${report["reportTime"]}');
      print('测量开始时间: ${report["measurementStartTime"]}');
      print('测量结束时间: ${report["measurementEndTime"]}');
      print('测量时长: ${report["measurementDuration"]} 小时');
      print('使用标准: ${report["standard"]}');
      print('最终TWA: ${report["doseData"]["twa"]} dB(A)');
      print('最终剂量: ${report["doseData"]["dosePercentage"]}%');
      print('合规性结论: ${report["complianceConclusion"]}');
    } else {
      print('无法生成报告（可能未开始测量）');
    }

    print('✅ 噪音测量计功能示例完成');
  }
}

/// 主函数
void main() async {
  final example = DecibelMeterUsageExample();
  await example.runAllExamples();
}
