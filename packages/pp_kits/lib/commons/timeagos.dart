import 'package:get_time_ago/get_time_ago.dart';

abstract class _LegacyMessages extends TimeAgoMessages {
  String prefixAgo();
  String suffixAgo();
  String justNowText(int seconds);
  String secsAgo(int seconds);
  String minAgo(int minutes);
  String minsAgo(int minutes);
  String hourAgo(int minutes);
  String hoursAgo(int hours);
  String dayAgo(int hours);
  String daysAgo(int days);
  String wordSeparator();

  @override
  String justNow(TimeAgoStyle style) => justNowText(0);

  @override
  String? relative(TimeUnit unit, int count, {
    required bool future,
    required TimeAgoStyle style,
  }) {
    final text = switch (unit) {
      TimeUnit.second => secsAgo(count),
      TimeUnit.minute => count == 1 ? minAgo(count) : minsAgo(count),
      TimeUnit.hour => count == 1 ? hourAgo(count * 60) : hoursAgo(count),
      TimeUnit.day => count == 1 ? dayAgo(count * 24) : daysAgo(count),
      _ => null,
    };
    if (text == null) return null;
    return [if (future) 'in' else prefixAgo(), text, if (!future) suffixAgo()]
        .where((part) => part.isNotEmpty)
        .join(wordSeparator());
  }
}

class FILMessages extends _LegacyMessages {
  @override
  String get intlLocale => 'fil';
  /// Prefix added before the time message.
  @override
  String prefixAgo() => '';

  /// Suffix added after the time message.
  @override
  String suffixAgo() => 'nakalipas';

  /// Message when the elapsed time is less than 15 seconds.
  @override
  String justNowText(int seconds) => 'ngayon lang';

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

class PLMessages extends _LegacyMessages {
  @override
  String get intlLocale => 'pl';
  /// Prefix added before the time message.
  @override
  String prefixAgo() => '';

  /// Suffix added after the time message.
  @override
  String suffixAgo() => 'temu';

  /// Message when the elapsed time is less than 15 seconds.
  @override
  String justNowText(int seconds) => 'przed chwilą';

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

class RUMessages extends _LegacyMessages {
  @override
  String get intlLocale => 'ru';
  /// Prefix added before the time message.
  @override
  String prefixAgo() => '';

  /// Suffix added after the time message.
  @override
  String suffixAgo() => 'назад';

  /// Message when the elapsed time is less than 15 seconds.
  @override
  String justNowText(int seconds) => 'только что';

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

class THMessages extends _LegacyMessages {
  @override
  String get intlLocale => 'th';
  /// Prefix added before the time message.
  @override
  String prefixAgo() => '';

  /// Suffix added after the time message.
  @override
  String suffixAgo() => 'ที่แล้ว';

  /// Message when the elapsed time is less than 15 seconds.
  @override
  String justNowText(int seconds) => 'เมื่อสักครู่';

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
