import 'noise_standard.dart';
import 'noise_dose_data.dart';

/// 限值比较结果
///
/// 包含与指定标准的详细比较结果，用于法规符合性评估
class LimitComparisonResult {
  /// 使用的噪声限值标准
  final NoiseStandard standard;

  /// 当前TWA值（dB）
  final double currentTWA;

  /// TWA限值（dB）
  final double twaLimit;

  /// 当前剂量百分比（%）
  final double currentDose;

  /// 是否超过限值
  final bool isExceeding;

  /// 是否达到行动值
  final bool isActionLevelReached;

  /// 限值余量（dB）
  final double limitMargin;

  /// 剂量余量（%）
  final double doseMargin;

  /// 风险等级
  final RiskLevel riskLevel;

  /// 建议措施列表
  final List<String> recommendations;

  LimitComparisonResult({
    required this.standard,
    required this.currentTWA,
    required this.twaLimit,
    required this.currentDose,
    required this.isExceeding,
    required this.isActionLevelReached,
    required this.limitMargin,
    required this.doseMargin,
    required this.riskLevel,
    required this.recommendations,
  });

  factory LimitComparisonResult.fromMap(Map<String, dynamic> map) {
    return LimitComparisonResult(
      standard: NoiseStandard.values.firstWhere(
        (e) => e.name == map['standard'],
        orElse: () => NoiseStandard.niosh,
      ),
      currentTWA: (map['currentTWA'] as num).toDouble(),
      twaLimit: (map['twaLimit'] as num).toDouble(),
      currentDose: (map['currentDose'] as num).toDouble(),
      isExceeding: map['isExceeding'] as bool,
      isActionLevelReached: map['isActionLevelReached'] as bool,
      limitMargin: (map['limitMargin'] as num).toDouble(),
      doseMargin: (map['doseMargin'] as num).toDouble(),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == map['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      recommendations: (map['recommendations'] as List)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'standard': standard.name,
      'currentTWA': currentTWA,
      'twaLimit': twaLimit,
      'currentDose': currentDose,
      'isExceeding': isExceeding,
      'isActionLevelReached': isActionLevelReached,
      'limitMargin': limitMargin,
      'doseMargin': doseMargin,
      'riskLevel': riskLevel.name,
      'recommendations': recommendations,
    };
  }

  /// 获取符合性状态
  String get complianceStatus {
    if (isExceeding) {
      return '不符合标准';
    } else if (isActionLevelReached) {
      return '需要行动';
    } else {
      return '符合标准';
    }
  }

  /// 获取风险状态描述
  String get riskStatus {
    return '${riskLevel.description} - $complianceStatus';
  }
}
