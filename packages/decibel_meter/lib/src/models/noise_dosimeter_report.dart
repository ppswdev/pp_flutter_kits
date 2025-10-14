import 'dart:convert';
import 'noise_standard.dart';
import 'noise_dose_data.dart';
import 'limit_comparison_result.dart';

/// 报告统计信息
class ReportStatistics {
  /// 平均分贝值
  final double avg;

  /// 最小分贝值
  final double min;

  /// 最大分贝值
  final double max;

  /// 峰值分贝值
  final double peak;

  /// L10值
  final double l10;

  /// L50值
  final double l50;

  /// L90值
  final double l90;

  ReportStatistics({
    required this.avg,
    required this.min,
    required this.max,
    required this.peak,
    required this.l10,
    required this.l50,
    required this.l90,
  });

  factory ReportStatistics.fromMap(Map<String, dynamic> map) {
    return ReportStatistics(
      avg: (map['avg'] as num).toDouble(),
      min: (map['min'] as num).toDouble(),
      max: (map['max'] as num).toDouble(),
      peak: (map['peak'] as num).toDouble(),
      l10: (map['l10'] as num).toDouble(),
      l50: (map['l50'] as num).toDouble(),
      l90: (map['l90'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avg': avg,
      'min': min,
      'max': max,
      'peak': peak,
      'l10': l10,
      'l50': l50,
      'l90': l90,
    };
  }
}

/// 噪音测量计综合报告
///
/// 包含所有关键数据的完整报告，用于法规符合性评估
class NoiseDosimeterReport {
  /// 报告生成时间
  final DateTime reportTime;

  /// 测量开始时间
  final DateTime measurementStartTime;

  /// 测量结束时间
  final DateTime measurementEndTime;

  /// 测量时长（小时）
  final double measurementDuration;

  /// 使用的标准
  final NoiseStandard standard;

  /// 剂量数据
  final NoiseDoseData doseData;

  /// 限值比较结果
  final LimitComparisonResult comparisonResult;

  /// LEQ值
  final double leq;

  /// 统计信息
  final ReportStatistics statistics;

  NoiseDosimeterReport({
    required this.reportTime,
    required this.measurementStartTime,
    required this.measurementEndTime,
    required this.measurementDuration,
    required this.standard,
    required this.doseData,
    required this.comparisonResult,
    required this.leq,
    required this.statistics,
  });

  factory NoiseDosimeterReport.fromMap(Map<String, dynamic> map) {
    return NoiseDosimeterReport(
      reportTime: DateTime.parse(map['reportTime'] as String),
      measurementStartTime: DateTime.parse(
        map['measurementStartTime'] as String,
      ),
      measurementEndTime: DateTime.parse(map['measurementEndTime'] as String),
      measurementDuration: (map['measurementDuration'] as num).toDouble(),
      standard: NoiseStandard.values.firstWhere(
        (e) => e.name == map['standard'],
        orElse: () => NoiseStandard.niosh,
      ),
      doseData: NoiseDoseData.fromMap(map['doseData'] as Map<String, dynamic>),
      comparisonResult: LimitComparisonResult.fromMap(
        map['comparisonResult'] as Map<String, dynamic>,
      ),
      leq: (map['leq'] as num).toDouble(),
      statistics: ReportStatistics.fromMap(
        map['statistics'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportTime': reportTime.toIso8601String(),
      'measurementStartTime': measurementStartTime.toIso8601String(),
      'measurementEndTime': measurementEndTime.toIso8601String(),
      'measurementDuration': measurementDuration,
      'standard': standard.name,
      'doseData': doseData.toMap(),
      'comparisonResult': comparisonResult.toMap(),
      'leq': leq,
      'statistics': statistics.toMap(),
    };
  }

  /// 转换为JSON字符串
  String toJSON() {
    return jsonEncode(toMap());
  }

  /// 从JSON字符串创建
  static NoiseDosimeterReport? fromJSON(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return NoiseDosimeterReport.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  /// 获取报告摘要
  String get summary {
    final status = doseData.isExceeding ? '超标' : '符合标准';
    return '''
噪音测量计报告摘要
==================
标准：${standard.displayName}
测量时长：${measurementDuration.toStringAsFixed(1)}小时
TWA：${doseData.twa.toStringAsFixed(1)} dB(A)
剂量：${doseData.dosePercentage.toStringAsFixed(1)}%
状态：$status
风险等级：${doseData.riskLevel.description}
LEQ：${leq.toStringAsFixed(1)} dB(A)
''';
  }

  /// 获取合规性结论
  String get complianceConclusion {
    if (doseData.isExceeding) {
      return '不符合${standard.displayName}标准，需要立即采取控制措施';
    } else if (doseData.dosePercentage >= 50.0) {
      return '符合${standard.displayName}标准，但建议采取听力保护措施';
    } else {
      return '符合${standard.displayName}标准，在安全范围内';
    }
  }
}
