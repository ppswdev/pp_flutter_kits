extension IntExtension on int {
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
