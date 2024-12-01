import 'package:intl/intl.dart';

extension IntExtension on int {
  /// 毫秒转时间字符串
  String toDateStr({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(this);
    return DateFormat(format).format(dateTime);
  }
}
