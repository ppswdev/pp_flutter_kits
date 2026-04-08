import 'package:get_time_ago/get_time_ago.dart';

class FILMessages implements Messages {
  /// Prefix added before the time message.
  @override
  String prefixAgo() => '';

  /// Suffix added after the time message.
  @override
  String suffixAgo() => 'nakalipas';

  /// Message when the elapsed time is less than 15 seconds.
  @override
  String justNow(int seconds) => 'ngayon lang';

  /// Message for when the elapsed time is less than a minute.
  @override
  String secsAgo(int seconds) => '$seconds segundo';

  /// Message for when the elapsed time is about a minute.
  @override
  String minAgo(int minutes) => 'isang minuto';

  /// Message for when the elapsed time is in minutes.
  @override
  String minsAgo(int minutes) => '$minutes minuto';

  /// Message for when the elapsed time is about an hour.
  @override
  String hourAgo(int minutes) => 'isang oras';

  /// Message for when the elapsed time is in hours.
  @override
  String hoursAgo(int hours) => '$hours oras';

  /// Message for when the elapsed time is about a day.
  @override
  String dayAgo(int hours) => 'isang araw';

  /// Message for when the elapsed time is in days.
  @override
  String daysAgo(int days) => '$days araw';

  /// Word separator to be used when joining the parts of the message.
  @override
  String wordSeparator() => ' ';
}

class PLMessages implements Messages {
  /// Prefix added before the time message.
  @override
  String prefixAgo() => '';

  /// Suffix added after the time message.
  @override
  String suffixAgo() => 'temu';

  /// Message when the elapsed time is less than 15 seconds.
  @override
  String justNow(int seconds) => 'przed chwilą';

  /// Message for when the elapsed time is less than a minute.
  @override
  String secsAgo(int seconds) => '$seconds sekund';

  /// Message for when the elapsed time is about a minute.
  @override
  String minAgo(int minutes) => 'minutę';

  /// Message for when the elapsed time is in minutes.
  @override
  String minsAgo(int minutes) => '$minutes minut';

  /// Message for when the elapsed time is about an hour.
  @override
  String hourAgo(int minutes) => 'godzinę';

  /// Message for when the elapsed time is in hours.
  @override
  String hoursAgo(int hours) => '$hours godzin';

  /// Message for when the elapsed time is about a day.
  @override
  String dayAgo(int hours) => 'dzień';

  /// Message for when the elapsed time is in days.
  @override
  String daysAgo(int days) => '$days dni';

  /// Word separator to be used when joining the parts of the message.
  @override
  String wordSeparator() => ' ';
}

class RUMessages implements Messages {
  /// Prefix added before the time message.
  @override
  String prefixAgo() => '';

  /// Suffix added after the time message.
  @override
  String suffixAgo() => 'назад';

  /// Message when the elapsed time is less than 15 seconds.
  @override
  String justNow(int seconds) => 'только что';

  /// Message for when the elapsed time is less than a minute.
  @override
  String secsAgo(int seconds) => '$seconds секунд';

  /// Message for when the elapsed time is about a minute.
  @override
  String minAgo(int minutes) => 'минуту';

  /// Message for when the elapsed time is in minutes.
  @override
  String minsAgo(int minutes) => '$minutes минут';

  /// Message for when the elapsed time is about an hour.
  @override
  String hourAgo(int minutes) => 'час';

  /// Message for when the elapsed time is in hours.
  @override
  String hoursAgo(int hours) => '$hours часов';

  /// Message for when the elapsed time is about a day.
  @override
  String dayAgo(int hours) => 'день';

  /// Message for when the elapsed time is in days.
  @override
  String daysAgo(int days) => '$days дней';

  /// Word separator to be used when joining the parts of the message.
  @override
  String wordSeparator() => ' ';
}

class THMessages implements Messages {
  /// Prefix added before the time message.
  @override
  String prefixAgo() => '';

  /// Suffix added after the time message.
  @override
  String suffixAgo() => 'ที่แล้ว';

  /// Message when the elapsed time is less than 15 seconds.
  @override
  String justNow(int seconds) => 'เมื่อสักครู่';

  /// Message for when the elapsed time is less than a minute.
  @override
  String secsAgo(int seconds) => '$seconds วินาที';

  /// Message for when the elapsed time is about a minute.
  @override
  String minAgo(int minutes) => 'หนึ่งนาที';

  /// Message for when the elapsed time is in minutes.
  @override
  String minsAgo(int minutes) => '$minutes นาที';

  /// Message for when the elapsed time is about an hour.
  @override
  String hourAgo(int minutes) => 'หนึ่งชั่วโมง';

  /// Message for when the elapsed time is in hours.
  @override
  String hoursAgo(int hours) => '$hours ชั่วโมง';

  /// Message for when the elapsed time is about a day.
  @override
  String dayAgo(int hours) => 'หนึ่งวัน';

  /// Message for when the elapsed time is in days.
  @override
  String daysAgo(int days) => '$days วัน';

  /// Word separator to be used when joining the parts of the message.
  @override
  String wordSeparator() => ' ';
}
