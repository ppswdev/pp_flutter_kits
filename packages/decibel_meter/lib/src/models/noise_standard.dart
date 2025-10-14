/// 噪声限值标准
///
/// 定义不同的噪声限值标准，用于噪音测量计的剂量计算和限值比较
/// 符合国际职业健康标准
enum NoiseStandard {
  /// OSHA标准（美国职业安全与健康管理局）
  /// - TWA限值：90 dB(A)
  /// - 行动值：85 dB(A)
  /// - 交换率：5 dB
  /// - 基准限值：90 dB(A)
  osha('OSHA'),

  /// NIOSH标准（美国国家职业安全与健康研究所）
  /// - TWA限值：85 dB(A)
  /// - 行动值：85 dB(A)
  /// - 交换率：3 dB（更保守）
  /// - 基准限值：85 dB(A)
  niosh('NIOSH'),

  /// GBZ标准（中国国家标准）
  /// - TWA限值：85 dB(A)
  /// - 行动值：80 dB(A)
  /// - 交换率：3 dB
  /// - 基准限值：85 dB(A)
  gbz('GBZ'),

  /// EU标准（欧盟标准）
  /// - TWA限值：87 dB(A)
  /// - 行动值：80 dB(A)
  /// - 交换率：3 dB
  /// - 基准限值：87 dB(A)
  eu('EU');

  const NoiseStandard(this.displayName);

  /// 显示名称
  final String displayName;

  /// TWA限值（dB）
  double get twaLimit {
    switch (this) {
      case NoiseStandard.osha:
        return 90.0;
      case NoiseStandard.niosh:
      case NoiseStandard.gbz:
        return 85.0;
      case NoiseStandard.eu:
        return 87.0;
    }
  }

  /// 行动值（dB）
  double get actionLevel {
    switch (this) {
      case NoiseStandard.osha:
        return 85.0;
      case NoiseStandard.niosh:
        return 85.0;
      case NoiseStandard.gbz:
      case NoiseStandard.eu:
        return 80.0;
    }
  }

  /// 交换率（dB）
  double get exchangeRate {
    switch (this) {
      case NoiseStandard.osha:
        return 5.0;
      case NoiseStandard.niosh:
      case NoiseStandard.gbz:
      case NoiseStandard.eu:
        return 3.0;
    }
  }

  /// 基准限值（dB）
  double get criterionLevel {
    return twaLimit;
  }

  /// 获取标准描述
  String get description {
    switch (this) {
      case NoiseStandard.osha:
        return '美国职业安全与健康管理局标准';
      case NoiseStandard.niosh:
        return '美国国家职业安全与健康研究所标准（更保守）';
      case NoiseStandard.gbz:
        return '中国国家标准';
      case NoiseStandard.eu:
        return '欧盟标准';
    }
  }

  /// 获取标准详情
  String get details {
    return '$description\nTWA限值: $twaLimit dB(A)\n行动值: $actionLevel dB(A)\n交换率: $exchangeRate dB';
  }
}
