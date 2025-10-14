/// 分贝统计指标
///
/// 包含完整的统计分析结果，用于评估噪声特性和暴露水平
/// 符合 ISO 1996-1 和 IEC 61672-1 标准的统计分析要求
class DecibelStatistics {
  /// 统计生成时间戳
  final DateTime timestamp;

  /// 测量持续时间（秒）
  final double measurementDuration;

  /// 样本数量（测量次数）
  final int sampleCount;

  // MARK: 基本统计指标

  /// AVG - 算术平均值（dB）
  final double avgDecibel;

  /// MIN - 最小值（dB），应用时间权重
  final double minDecibel;

  /// MAX - 最大值（dB），应用时间权重
  final double maxDecibel;

  /// PEAK - 峰值（dB），不应用时间权重，表示瞬时峰值
  final double peakDecibel;

  // MARK: 等效连续声级

  /// Leq - 等效连续声级（dB），能量平均值，符合ISO 1996-1标准
  final double leqDecibel;

  // MARK: 百分位数统计

  /// L10 - 超过10%时间的声级（dB），表示噪声峰值特征
  final double l10Decibel;

  /// L50 - 超过50%时间的声级（dB），即中位数
  final double l50Decibel;

  /// L90 - 超过90%时间的声级（dB），表示背景噪声水平
  final double l90Decibel;

  // MARK: 标准偏差

  /// 标准偏差（dB），表示数据的离散程度
  final double standardDeviation;

  /// 获取统计摘要
  final String summary;

  /// 获取详细统计信息
  final String detailedSummary;

  DecibelStatistics({
    required this.timestamp,
    required this.measurementDuration,
    required this.sampleCount,
    required this.avgDecibel,
    required this.minDecibel,
    required this.maxDecibel,
    required this.peakDecibel,
    required this.leqDecibel,
    required this.l10Decibel,
    required this.l50Decibel,
    required this.l90Decibel,
    required this.standardDeviation,
    required this.summary,
    required this.detailedSummary,
  });

  factory DecibelStatistics.fromMap(Map<String, dynamic> map) {
    return DecibelStatistics(
      timestamp: DateTime.parse(map['timestamp'] as String),
      measurementDuration: (map['measurementDuration'] as num).toDouble(),
      sampleCount: map['sampleCount'] as int,
      avgDecibel: (map['avgDecibel'] as num).toDouble(),
      minDecibel: (map['minDecibel'] as num).toDouble(),
      maxDecibel: (map['maxDecibel'] as num).toDouble(),
      peakDecibel: (map['peakDecibel'] as num).toDouble(),
      leqDecibel: (map['leqDecibel'] as num).toDouble(),
      l10Decibel: (map['l10Decibel'] as num).toDouble(),
      l50Decibel: (map['l50Decibel'] as num).toDouble(),
      l90Decibel: (map['l90Decibel'] as num).toDouble(),
      standardDeviation: (map['standardDeviation'] as num).toDouble(),
      summary: map['summary'] as String,
      detailedSummary: map['detailedSummary'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'measurementDuration': measurementDuration,
      'sampleCount': sampleCount,
      'avgDecibel': avgDecibel,
      'minDecibel': minDecibel,
      'maxDecibel': maxDecibel,
      'peakDecibel': peakDecibel,
      'leqDecibel': leqDecibel,
      'l10Decibel': l10Decibel,
      'l50Decibel': l50Decibel,
      'l90Decibel': l90Decibel,
      'standardDeviation': standardDeviation,
      'summary': summary,
      'detailedSummary': detailedSummary,
    };
  }
}
