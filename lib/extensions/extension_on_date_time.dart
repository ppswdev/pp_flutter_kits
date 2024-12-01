import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExtension on DateTime {
  /// Returns Time Ago
  String get timeAgo => timeago.format(this);

  /// Returns true if given date is today
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
