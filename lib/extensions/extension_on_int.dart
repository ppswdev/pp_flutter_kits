import 'package:intl/intl.dart';

extension IntExtension on int {
  /// 毫秒转时间字符串
  String toDateStr({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(this);
    return DateFormat(format).format(dateTime);
  }

  /// 是否是闰年
  bool isLeapYear() {
    bool leapYear = false;

    bool leap = ((this % 100 == 0) && (this % 400 != 0));
    if (leap == true) {
      leapYear = false;
    } else if (this % 4 == 0) {
      leapYear = true;
    }

    return leapYear;
  }
}
