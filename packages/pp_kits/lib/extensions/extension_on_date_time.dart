import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Returns Time Ago
  String get timeAgo => GetTimeAgo.parse(this);

  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return DateTime(year, month, day) == today;
  }

  /// Returns true if given date is yesterday
  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    return DateTime(year, month, day) == yesterday;
  }

  /// Returns true if given date is tomorrow
  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    return DateTime(year, month, day) == tomorrow;
  }

  /// return true if given year is an leap year
  bool isLeapYear(int year) {
    bool leapYear = false;

    bool leap = ((year % 100 == 0) && (year % 400 != 0));
    if (leap == true) {
      leapYear = false;
    } else if (year % 4 == 0) {
      leapYear = true;
    }

    return leapYear;
  }

  /// returns number of days in given month
  int daysInMonth(int monthNum, int year) {
    List<int> monthLength = List.filled(12, 0);

    monthLength[0] = 31;
    monthLength[2] = 31;
    monthLength[4] = 31;
    monthLength[6] = 31;
    monthLength[7] = 31;
    monthLength[9] = 31;
    monthLength[11] = 31;
    monthLength[3] = 30;
    monthLength[8] = 30;
    monthLength[5] = 30;
    monthLength[10] = 30;

    if (isLeapYear(year)) {
      monthLength[1] = 29;
    } else {
      monthLength[1] = 28;
    }

    return monthLength[monthNum - 1];
  }
}

extension DateTimeConverterExtension on DateTime {
  /// 毫秒转时间字符串
  String toDateStr({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(format).format(this);
  }

  /// 根据语言地区显示时间格式
  ///- 中文(zh_CN): "2024年3月15日"
  /// - 英文(en_US): "Mar 15, 2024"
  /// - 日文(ja_JP): "2024年3月15日"
  /// - 阿拉伯语(ar): "١٥ مارس ٢٠٢٤"
  /// - 德语(de): "15. März 2024"
  /// - 西班牙语(es): "15 de marzo de 2024"
  /// - 菲律宾语(fil): "Marso 15, 2024"
  /// - 法语(fr): "15 mars 2024"
  /// - 印尼语(id): "15 Maret 2024"
  /// - 意大利语(it): "15 marzo 2024"
  /// - 韩语(ko): "2024년 3월 15일"
  /// - 波兰语(pl): "15 marca 2024"
  /// - 葡萄牙语(pt): "15 de março de 2024"
  /// - 俄语(ru): "15 марта 2024 г."
  /// - 土耳其语(tr): "15 Mart 2024"
  /// - 越南语(vi): "15 tháng 3, 2024"
  /// - ...
  String toYMDDateStr({String? locale = 'en'}) {
    // 指定语言（例如：英文）
    var formatter = DateFormat.yMMMMd(locale); // May 4, 2025
    return formatter.format(this);
  }
}

extension DateTimeFromIntExtension on int {
  /// 毫秒转时间字符串
  String toDateStr({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(this);
    return DateFormat(format).format(dateTime);
  }

  /// 根据语言地区显示时间格式
  ///- 中文(zh_CN): "2024年3月15日"
  /// - 英文(en_US): "Mar 15, 2024"
  /// - 日文(ja_JP): "2024年3月15日"
  /// - 阿拉伯语(ar): "١٥ مارس ٢٠٢٤"
  /// - 德语(de): "15. März 2024"
  /// - 西班牙语(es): "15 de marzo de 2024"
  /// - 菲律宾语(fil): "Marso 15, 2024"
  /// - 法语(fr): "15 mars 2024"
  /// - 印尼语(id): "15 Maret 2024"
  /// - 意大利语(it): "15 marzo 2024"
  /// - 韩语(ko): "2024년 3월 15일"
  /// - 波兰语(pl): "15 marca 2024"
  /// - 葡萄牙语(pt): "15 de março de 2024"
  /// - 俄语(ru): "15 марта 2024 г."
  /// - 土耳其语(tr): "15 Mart 2024"
  /// - 越南语(vi): "15 tháng 3, 2024"
  /// - ...
  String toYMDDateStr({String? locale = 'en'}) {
    final date = DateTime.fromMillisecondsSinceEpoch(this);
    return date.toYMDDateStr(locale: locale);
  }
}
