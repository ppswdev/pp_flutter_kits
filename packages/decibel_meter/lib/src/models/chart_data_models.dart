import 'dart:convert';
import 'noise_standard.dart';

/// 剂量累积数据点
class DoseAccumulationPoint {
  /// 时间戳
  final DateTime timestamp;

  /// 累积剂量（%）
  final double cumulativeDose;

  /// 当前TWA值（dB）
  final double currentTWA;

  /// 暴露时间（小时）
  final double exposureTime;

  DoseAccumulationPoint({
    required this.timestamp,
    required this.cumulativeDose,
    required this.currentTWA,
    required this.exposureTime,
  });

  factory DoseAccumulationPoint.fromMap(Map<String, dynamic> map) {
    return DoseAccumulationPoint(
      timestamp: DateTime.parse(map['timestamp'] as String),
      cumulativeDose: (map['cumulativeDose'] as num).toDouble(),
      currentTWA: (map['currentTWA'] as num).toDouble(),
      exposureTime: (map['exposureTime'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'cumulativeDose': cumulativeDose,
      'currentTWA': currentTWA,
      'exposureTime': exposureTime,
    };
  }
}

/// 剂量累积图数据
class DoseAccumulationChartData {
  /// 数据点数组
  final List<DoseAccumulationPoint> dataPoints;

  /// 当前剂量（%）
  final double currentDose;

  /// 限值线（100%）
  final double limitLine;

  /// 使用的标准
  final NoiseStandard standard;

  /// 时间范围（小时）
  final double timeRange;

  /// 图表标题
  final String title;

  DoseAccumulationChartData({
    required this.dataPoints,
    required this.currentDose,
    required this.limitLine,
    required this.standard,
    required this.timeRange,
    required this.title,
  });

  factory DoseAccumulationChartData.fromMap(Map<String, dynamic> map) {
    return DoseAccumulationChartData(
      dataPoints: (map['dataPoints'] as List)
          .map((e) => DoseAccumulationPoint.fromMap(e as Map<String, dynamic>))
          .toList(),
      currentDose: (map['currentDose'] as num).toDouble(),
      limitLine: (map['limitLine'] as num).toDouble(),
      standard: NoiseStandard.values.firstWhere(
        (e) => e.name == map['standard'],
        orElse: () => NoiseStandard.niosh,
      ),
      timeRange: (map['timeRange'] as num).toDouble(),
      title: map['title'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dataPoints': dataPoints.map((e) => e.toMap()).toList(),
      'currentDose': currentDose,
      'limitLine': limitLine,
      'standard': standard.name,
      'timeRange': timeRange,
      'title': title,
    };
  }

  /// 转换为JSON字符串
  String toJSON() {
    return jsonEncode(toMap());
  }

  /// 从JSON字符串创建
  static DoseAccumulationChartData? fromJSON(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return DoseAccumulationChartData.fromMap(map);
    } catch (e) {
      return null;
    }
  }
}

/// TWA趋势数据点
class TWATrendDataPoint {
  /// 时间戳
  final DateTime timestamp;

  /// TWA值（dB）
  final double twa;

  /// 暴露时间（小时）
  final double exposureTime;

  /// 剂量百分比（%）
  final double dosePercentage;

  TWATrendDataPoint({
    required this.timestamp,
    required this.twa,
    required this.exposureTime,
    required this.dosePercentage,
  });

  factory TWATrendDataPoint.fromMap(Map<String, dynamic> map) {
    return TWATrendDataPoint(
      timestamp: DateTime.parse(map['timestamp'] as String),
      twa: (map['twa'] as num).toDouble(),
      exposureTime: (map['exposureTime'] as num).toDouble(),
      dosePercentage: (map['dosePercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'twa': twa,
      'exposureTime': exposureTime,
      'dosePercentage': dosePercentage,
    };
  }
}

/// TWA趋势图数据
class TWATrendChartData {
  /// 数据点数组
  final List<TWATrendDataPoint> dataPoints;

  /// 当前TWA值（dB）
  final double currentTWA;

  /// 限值线（dB）
  final double limitLine;

  /// 使用的标准
  final NoiseStandard standard;

  /// 时间范围（小时）
  final double timeRange;

  /// 图表标题
  final String title;

  TWATrendChartData({
    required this.dataPoints,
    required this.currentTWA,
    required this.limitLine,
    required this.standard,
    required this.timeRange,
    required this.title,
  });

  factory TWATrendChartData.fromMap(Map<String, dynamic> map) {
    return TWATrendChartData(
      dataPoints: (map['dataPoints'] as List)
          .map((e) => TWATrendDataPoint.fromMap(e as Map<String, dynamic>))
          .toList(),
      currentTWA: (map['currentTWA'] as num).toDouble(),
      limitLine: (map['limitLine'] as num).toDouble(),
      standard: NoiseStandard.values.firstWhere(
        (e) => e.name == map['standard'],
        orElse: () => NoiseStandard.niosh,
      ),
      timeRange: (map['timeRange'] as num).toDouble(),
      title: map['title'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dataPoints': dataPoints.map((e) => e.toMap()).toList(),
      'currentTWA': currentTWA,
      'limitLine': limitLine,
      'standard': standard.name,
      'timeRange': timeRange,
      'title': title,
    };
  }

  /// 转换为JSON字符串
  String toJSON() {
    return jsonEncode(toMap());
  }

  /// 从JSON字符串创建
  static TWATrendChartData? fromJSON(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return TWATrendChartData.fromMap(map);
    } catch (e) {
      return null;
    }
  }
}

/// 允许暴露时长
class PermissibleExposureDuration {
  /// 声级（dB）
  final double soundLevel;

  /// 允许时长（秒）
  final double allowedDuration;

  /// 累计时长（秒）
  final double accumulatedDuration;

  /// 是否为天花板限值
  final bool isCeilingLimit;

  PermissibleExposureDuration({
    required this.soundLevel,
    required this.allowedDuration,
    required this.accumulatedDuration,
    required this.isCeilingLimit,
  });

  factory PermissibleExposureDuration.fromMap(Map<String, dynamic> map) {
    return PermissibleExposureDuration(
      soundLevel: (map['soundLevel'] as num).toDouble(),
      allowedDuration: (map['allowedDuration'] as num).toDouble(),
      accumulatedDuration: (map['accumulatedDuration'] as num).toDouble(),
      isCeilingLimit: map['isCeilingLimit'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'soundLevel': soundLevel,
      'allowedDuration': allowedDuration,
      'accumulatedDuration': accumulatedDuration,
      'isCeilingLimit': isCeilingLimit,
    };
  }

  /// 获取允许时长（小时）
  double get allowedDurationHours {
    return allowedDuration / 3600.0;
  }

  /// 获取累计时长（小时）
  double get accumulatedDurationHours {
    return accumulatedDuration / 3600.0;
  }

  /// 获取当前声级剂量百分比
  double get currentLevelDose {
    return (accumulatedDuration / allowedDuration) * 100.0;
  }

  /// 格式化允许时长
  String get formattedAllowedDuration {
    final hours = (allowedDuration / 3600.0).floor();
    final minutes = ((allowedDuration % 3600.0) / 60.0).floor();
    return '${hours}h ${minutes}m';
  }

  /// 格式化累计时长
  String get formattedAccumulatedDuration {
    final hours = (accumulatedDuration / 3600.0).floor();
    final minutes = ((accumulatedDuration % 3600.0) / 60.0).floor();
    return '${hours}h ${minutes}m';
  }
}

/// 允许暴露时长表
class PermissibleExposureDurationTable {
  /// 使用的标准
  final NoiseStandard standard;

  /// 基准限值（dB）
  final double criterionLevel;

  /// 交换率（dB）
  final double exchangeRate;

  /// 天花板限值（dB）
  final double ceilingLimit;

  /// 时长数据数组
  final List<PermissibleExposureDuration> durations;

  PermissibleExposureDurationTable({
    required this.standard,
    required this.criterionLevel,
    required this.exchangeRate,
    required this.ceilingLimit,
    required this.durations,
  });

  factory PermissibleExposureDurationTable.fromMap(Map<String, dynamic> map) {
    return PermissibleExposureDurationTable(
      standard: NoiseStandard.values.firstWhere(
        (e) => e.name == map['standard'],
        orElse: () => NoiseStandard.niosh,
      ),
      criterionLevel: (map['criterionLevel'] as num).toDouble(),
      exchangeRate: (map['exchangeRate'] as num).toDouble(),
      ceilingLimit: (map['ceilingLimit'] as num).toDouble(),
      durations: (map['durations'] as List)
          .map(
            (e) =>
                PermissibleExposureDuration.fromMap(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'standard': standard.name,
      'criterionLevel': criterionLevel,
      'exchangeRate': exchangeRate,
      'ceilingLimit': ceilingLimit,
      'durations': durations.map((e) => e.toMap()).toList(),
    };
  }

  /// 计算总剂量百分比
  double get totalDose {
    return durations.fold(
      0.0,
      (sum, duration) => sum + duration.currentLevelDose,
    );
  }

  /// 获取超标声级数量
  int get exceedingLevelsCount {
    return durations
        .where((duration) => duration.currentLevelDose > 100.0)
        .length;
  }

  /// 转换为JSON字符串
  String toJSON() {
    return jsonEncode(toMap());
  }

  /// 从JSON字符串创建
  static PermissibleExposureDurationTable? fromJSON(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return PermissibleExposureDurationTable.fromMap(map);
    } catch (e) {
      return null;
    }
  }
}
