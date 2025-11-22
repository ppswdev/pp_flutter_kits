import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';

/// DateTime 扩展方法
extension DateTimeExtension on DateTime {
  /// 获取距离当前时间的友好表达，如"2天前"。
  ///
  /// 返回结果：
  ///   返回一个字符串，表示时间的"XX ago"样式。
  ///
  /// 示例：
  /// ```dart
  /// DateTime time = DateTime.now().subtract(Duration(days:1));
  /// print(time.timeAgo); // e.g. "a day ago"
  /// ```
  String get timeAgo => GetTimeAgo.parse(this);

  /// 判断日期是否为今天
  ///
  /// 返回结果：
  ///   若日期为今天，返回true，否则返回false。
  ///
  /// 示例：
  /// ```dart
  /// DateTime today = DateTime.now();
  /// print(today.isToday); // true
  /// ```
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(year, month, day) == today;
  }

  /// 判断日期是否为昨天
  ///
  /// 返回结果：
  ///   若日期为昨天，返回true，否则返回false。
  ///
  /// 示例：
  /// ```dart
  /// DateTime yesterday = DateTime.now().subtract(Duration(days:1));
  /// print(yesterday.isYesterday); // true
  /// ```
  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return DateTime(year, month, day) == yesterday;
  }

  /// 判断日期是否为明天
  ///
  /// 返回结果：
  ///   若日期为明天，返回true，否则返回false。
  ///
  /// 示例：
  /// ```dart
  /// DateTime tomorrow = DateTime.now().add(Duration(days:1));
  /// print(tomorrow.isTomorrow); // true
  /// ```
  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return DateTime(year, month, day) == tomorrow;
  }

  /// 判断指定年份是否为闰年
  ///
  /// [year] 需要判断的年份
  ///
  /// 返回结果：
  ///   若为闰年返回true，否则返回false。
  ///
  /// 示例：
  /// ```dart
  /// print(DateTime.now().isLeapYear(2020)); // true
  /// print(DateTime.now().isLeapYear(2023)); // false
  /// ```
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

  /// 获取指定年月的天数
  ///
  /// [monthNum] 月份（1-12）
  /// [year] 年份
  ///
  /// 返回结果：
  ///   返回指定年月的天数，如2月闰年返回29，平年返回28。
  ///
  /// 示例：
  /// ```dart
  /// print(DateTime.now().daysInMonth(2, 2024)); // 29
  /// print(DateTime.now().daysInMonth(2, 2023)); // 28
  /// print(DateTime.now().daysInMonth(7, 2023)); // 31
  /// ```
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

/// DateTime 转换相关扩展方法
extension DateTimeConverterExtension on DateTime {
  /// 按指定格式将 DateTime 转为字符串。
  ///
  /// [format] 字符串格式，默认为 'yyyy-MM-dd HH:mm:ss'。
  ///
  /// 返回结果：
  ///   格式化后的时间字符串。
  ///
  /// 示例：
  /// ```dart
  /// DateTime dt = DateTime(2024, 3, 15, 16, 30, 0);
  /// print(dt.toDateStr(format: 'yyyy-MM-dd')); // '2024-03-15'
  /// ```
  String toDateStr({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(format).format(this);
  }

  /// 按指定语言返回年月日格式的日期字符串
  ///
  /// [locale] 语言地区代码，默认为'en'
  ///
  /// 返回结果：
  ///   本地化格式化后的日期字符串。
  ///
  /// 示例：
  /// ```dart
  /// DateTime dt = DateTime(2024, 3, 15);
  /// print(dt.toYMDDateStr(locale: 'en'));    // 'March 15, 2024'
  /// print(dt.toYMDDateStr(locale: 'zh_CN')); // '2024年3月15日'
  /// ```
  String toYMDDateStr({String? locale = 'en'}) {
    var formatter = DateFormat.yMMMMd(locale); // 例: May 4, 2025
    return formatter.format(this);
  }
}

/// int 扩展方法（通常为毫秒时间戳）
extension DateTimeFromIntExtension on int {
  /// 毫秒时间戳转为日期字符串
  ///
  /// [format] 字符串格式，默认为 'yyyy-MM-dd HH:mm:ss'。
  ///
  /// 返回结果：
  ///   格式化后的时间字符串。
  ///
  /// 示例：
  /// ```dart
  /// int timestamp = 1710441600000; // 2024-03-15 00:00:00
  /// print(timestamp.toDateStr(format: 'yyyy-MM-dd'));
  /// // 输出: '2024-03-15'
  /// ```
  String toDateStr({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(this);
    return DateFormat(format).format(dateTime);
  }

  /// 毫秒时间戳转为本地化日期年月日字符串
  ///
  /// [locale] 语言地区代码，默认为'en'
  ///
  /// 返回结果：
  ///   本地化格式化后的日期字符串。
  ///
  /// 示例：
  /// ```dart
  /// int timestamp = 1710441600000; // 2024-03-15
  /// print(timestamp.toYMDDateStr(locale: 'en'));      // 'March 15, 2024'
  /// print(timestamp.toYMDDateStr(locale: 'zh_CN'));   // '2024年3月15日'
  /// ```
  String toYMDDateStr({String? locale = 'en'}) {
    final date = DateTime.fromMillisecondsSinceEpoch(this);
    return date.toYMDDateStr(locale: locale);
  }
}
