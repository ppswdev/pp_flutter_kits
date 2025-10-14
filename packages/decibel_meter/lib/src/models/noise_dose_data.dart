import 'noise_standard.dart';

/// 风险等级
enum RiskLevel {
  /// 低风险
  low('低风险'),

  /// 中等风险
  medium('中等风险'),

  /// 高风险
  high('高风险'),

  /// 极高风险
  veryHigh('极高风险');

  const RiskLevel(this.description);

  final String description;

  /// 根据剂量百分比判断风险等级
  static RiskLevel from(double dosePercentage) {
    if (dosePercentage < 25.0) {
      return RiskLevel.low;
    } else if (dosePercentage < 50.0) {
      return RiskLevel.medium;
    } else if (dosePercentage < 100.0) {
      return RiskLevel.high;
    } else {
      return RiskLevel.veryHigh;
    }
  }
}

/// 噪声剂量数据
///
/// 包含完整的噪声剂量信息，用于职业健康监测和法规符合性评估
class NoiseDoseData {
  /// 剂量百分比（%）
  final double dosePercentage;

  /// 剂量率（%/小时）
  final double doseRate;

  /// TWA值（时间加权平均值，dB）
  final double twa;

  /// 暴露时长（小时）
  final double duration;

  /// 使用的噪声限值标准
  final NoiseStandard standard;

  /// 是否超过限值
  final bool isExceeding;

  /// 限值余量（dB）
  final double limitMargin;

  /// 预测达到100%剂量的时间（小时）
  final double? predictedTimeToFullDose;

  /// 剩余允许时间（小时）
  final double? remainingAllowedTime;

  /// 风险等级
  final RiskLevel riskLevel;

  NoiseDoseData({
    required this.dosePercentage,
    required this.doseRate,
    required this.twa,
    required this.duration,
    required this.standard,
    required this.isExceeding,
    required this.limitMargin,
    this.predictedTimeToFullDose,
    this.remainingAllowedTime,
    required this.riskLevel,
  });

  factory NoiseDoseData.fromMap(Map<String, dynamic> map) {
    return NoiseDoseData(
      dosePercentage: (map['dosePercentage'] as num).toDouble(),
      doseRate: (map['doseRate'] as num).toDouble(),
      twa: (map['twa'] as num).toDouble(),
      duration: (map['duration'] as num).toDouble(),
      standard: NoiseStandard.values.firstWhere(
        (e) => e.name == map['standard'],
        orElse: () => NoiseStandard.niosh,
      ),
      isExceeding: map['isExceeding'] as bool,
      limitMargin: (map['limitMargin'] as num).toDouble(),
      predictedTimeToFullDose: map['predictedTimeToFullDose'] != null
          ? (map['predictedTimeToFullDose'] as num).toDouble()
          : null,
      remainingAllowedTime: map['remainingAllowedTime'] != null
          ? (map['remainingAllowedTime'] as num).toDouble()
          : null,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == map['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dosePercentage': dosePercentage,
      'doseRate': doseRate,
      'twa': twa,
      'duration': duration,
      'standard': standard.name,
      'isExceeding': isExceeding,
      'limitMargin': limitMargin,
      'predictedTimeToFullDose': predictedTimeToFullDose,
      'remainingAllowedTime': remainingAllowedTime,
      'riskLevel': riskLevel.name,
    };
  }

  /// 获取剂量状态描述
  String get doseStatus {
    if (dosePercentage >= 100.0) {
      return '已超标';
    } else if (dosePercentage >= 80.0) {
      return '接近限值';
    } else if (dosePercentage >= 50.0) {
      return '中等剂量';
    } else if (dosePercentage >= 25.0) {
      return '低剂量';
    } else {
      return '安全范围';
    }
  }

  /// 获取限值状态描述
  String get limitStatus {
    if (isExceeding) {
      return '已超过TWA限值';
    } else if (limitMargin <= 3.0) {
      return '接近TWA限值';
    } else {
      return '在安全范围内';
    }
  }
}
