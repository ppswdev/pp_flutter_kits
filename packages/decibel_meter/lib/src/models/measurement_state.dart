/// 测量状态
///
/// 根据 IEC 61672-1 标准，专业声级计通常只需要2-3个基本状态
enum MeasurementState {
  /// 停止状态：未进行测量，等待开始
  idle,

  /// 测量状态：正在进行分贝测量和数据采集
  measuring,

  /// 错误状态：发生错误，包含错误描述信息
  error;

  static MeasurementState fromString(String str) {
    if (str.startsWith('error')) {
      return MeasurementState.error;
    }
    switch (str) {
      case 'idle':
        return MeasurementState.idle;
      case 'measuring':
        return MeasurementState.measuring;
      default:
        return MeasurementState.idle;
    }
  }

  /// 从字符串获取错误消息
  static String? getErrorMessage(String str) {
    if (str.startsWith('error: ')) {
      return str.substring(7);
    }
    return null;
  }
}
