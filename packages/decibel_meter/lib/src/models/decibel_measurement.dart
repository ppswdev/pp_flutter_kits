/// 分贝测量结果
///
/// 表示单次分贝测量的完整结果，包含原始值、各种权重值、校准值和频谱数据
class DecibelMeasurement {
  /// 测量时间戳
  final DateTime timestamp;

  /// 原始分贝值（dB），未应用任何权重
  final double rawDecibel;

  /// A权重分贝值（dB），应用A权重后的值
  final double aWeightedDecibel;

  /// Fast时间权重分贝值（dB）
  final double fastDecibel;

  /// Slow时间权重分贝值（dB）
  final double slowDecibel;

  /// 校准后的分贝值（dB），应用了频率权重、时间权重和校准偏移
  final double calibratedDecibel;

  /// 频率频谱数据数组，用于频谱分析图
  final List<double> frequencySpectrum;

  /// 获取主要显示的分贝值
  final double displayDecibel;

  /// 获取分贝等级描述
  final String levelDescription;

  /// 获取分贝等级颜色
  final String levelColor;

  DecibelMeasurement({
    required this.timestamp,
    required this.rawDecibel,
    required this.aWeightedDecibel,
    required this.fastDecibel,
    required this.slowDecibel,
    required this.calibratedDecibel,
    required this.frequencySpectrum,
    required this.displayDecibel,
    required this.levelDescription,
    required this.levelColor,
  });

  factory DecibelMeasurement.fromMap(Map<String, dynamic> map) {
    return DecibelMeasurement(
      timestamp: DateTime.parse(map['timestamp'] as String),
      rawDecibel: (map['rawDecibel'] as num).toDouble(),
      aWeightedDecibel: (map['aWeightedDecibel'] as num).toDouble(),
      fastDecibel: (map['fastDecibel'] as num).toDouble(),
      slowDecibel: (map['slowDecibel'] as num).toDouble(),
      calibratedDecibel: (map['calibratedDecibel'] as num).toDouble(),
      frequencySpectrum: (map['frequencySpectrum'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      displayDecibel: (map['displayDecibel'] as num).toDouble(),
      levelDescription: map['levelDescription'] as String,
      levelColor: map['levelColor'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'rawDecibel': rawDecibel,
      'aWeightedDecibel': aWeightedDecibel,
      'fastDecibel': fastDecibel,
      'slowDecibel': slowDecibel,
      'calibratedDecibel': calibratedDecibel,
      'frequencySpectrum': frequencySpectrum,
      'displayDecibel': displayDecibel,
      'levelDescription': levelDescription,
      'levelColor': levelColor,
    };
  }
}
