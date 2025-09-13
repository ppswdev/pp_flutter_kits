import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class SubsLocale {
  /// 将StoreKit的周期单位转换为标准单位
  static String getUnit(SKProductSubscriptionPeriodWrapper? period) {
    if (period == null) return 'day';

    final unit = period.unit.name;
    final numberOfUnits = period.numberOfUnits;

    switch (unit.toLowerCase()) {
      case 'week':
      case 'weeks':
        if (numberOfUnits >= 52) {
          return 'year';
        }
        if (numberOfUnits >= 4) {
          return 'month';
        }
        return 'week';
      case 'month':
      case 'months':
        if (numberOfUnits >= 12) {
          return 'year';
        }
        return 'month';
      case 'year':
      case 'years':
        return 'year';
      default:
        if (numberOfUnits >= 365) {
          return 'year';
        }
        if (numberOfUnits >= 30) {
          return 'month';
        }
        if (numberOfUnits >= 7) {
          return 'week';
        }
        return 'day';
    }
  }

  /// 获取本地化的单位文本
  static String _getLocalizedUnit(
    String languageCode,
    int numberOfPeriods,
    String unit,
  ) {
    switch (languageCode) {
      case 'ar':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'يوم' : 'أيام';
          case 'week':
            return numberOfPeriods == 1 ? 'أسبوع' : 'أسابيع';
          case 'month':
            return numberOfPeriods == 1 ? 'شهر' : 'أشهر';
          case 'year':
            return numberOfPeriods == 1 ? 'سنة' : 'سنوات';
          default:
            return numberOfPeriods == 1 ? 'يوم' : 'أيام';
        }
      case 'de':
        switch (unit) {
          case 'day':
            return 'Täg';
          case 'week':
            return 'Wochen';
          case 'month':
            return 'Monat';
          case 'year':
            return 'Jahr';
          default:
            return 'Täg';
        }
      case 'en':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'day' : 'days';
          case 'week':
            return numberOfPeriods == 1 ? 'week' : 'weeks';
          case 'month':
            return numberOfPeriods == 1 ? 'month' : 'months';
          case 'year':
            return numberOfPeriods == 1 ? 'year' : 'years';
          default:
            return numberOfPeriods == 1 ? 'day' : 'days';
        }
      case 'es':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'día' : 'días';
          case 'week':
            return numberOfPeriods == 1 ? 'semana' : 'semanas';
          case 'month':
            return numberOfPeriods == 1 ? 'mes' : 'meses';
          case 'year':
            return numberOfPeriods == 1 ? 'año' : 'años';
          default:
            return numberOfPeriods == 1 ? 'día' : 'días';
        }
      case 'fil':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'araw' : 'araw';
          case 'week':
            return numberOfPeriods == 1 ? 'linggo' : 'linggo';
          case 'month':
            return numberOfPeriods == 1 ? 'buwan' : 'buwan';
          case 'year':
            return numberOfPeriods == 1 ? 'taon' : 'taon';
          default:
            return numberOfPeriods == 1 ? 'araw' : 'araw';
        }
      case 'fr':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'jour' : 'jours';
          case 'week':
            return numberOfPeriods == 1 ? 'semaine' : 'semaines';
          case 'month':
            return numberOfPeriods == 1 ? 'mois' : 'mois';
          case 'year':
            return numberOfPeriods == 1 ? 'an' : 'ans';
          default:
            return numberOfPeriods == 1 ? 'jour' : 'jours';
        }
      case 'id':
        switch (unit) {
          case 'day':
            return 'hari';
          case 'week':
            return 'minggu';
          case 'month':
            return 'bulan';
          case 'year':
            return 'tahun';
          default:
            return 'hari';
        }
      case 'it':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'giorno' : 'giorni';
          case 'week':
            return numberOfPeriods == 1 ? 'settimana' : 'settimane';
          case 'month':
            return numberOfPeriods == 1 ? 'mese' : 'mesi';
          case 'year':
            return numberOfPeriods == 1 ? 'anno' : 'anni';
          default:
            return numberOfPeriods == 1 ? 'giorno' : 'giorni';
        }
      case 'ja':
        switch (unit) {
          case 'day':
            return '日間';
          case 'week':
            return '週間';
          case 'month':
            return 'ヶ月';
          case 'year':
            return '年間';
          default:
            return '日間';
        }
      case 'ko':
        switch (unit) {
          case 'day':
            return '일';
          case 'week':
            return '주';
          case 'month':
            return '개월';
          case 'year':
            return '년';
          default:
            return '일';
        }
      case 'pl':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'dzień' : 'dni';
          case 'week':
            return numberOfPeriods == 1 ? 'tydzień' : 'tygodni';
          case 'month':
            return numberOfPeriods == 1 ? 'miesiąc' : 'miesięcy';
          case 'year':
            return numberOfPeriods == 1 ? 'rok' : 'lat';
          default:
            return numberOfPeriods == 1 ? 'dzień' : 'dni';
        }
      case 'pt':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'dia' : 'dias';
          case 'week':
            return numberOfPeriods == 1 ? 'semana' : 'semanas';
          case 'month':
            return numberOfPeriods == 1 ? 'mês' : 'meses';
          case 'year':
            return numberOfPeriods == 1 ? 'ano' : 'anos';
          default:
            return numberOfPeriods == 1 ? 'dia' : 'dias';
        }
      case 'ru':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'день' : 'дней';
          case 'week':
            return numberOfPeriods == 1 ? 'неделя' : 'недель';
          case 'month':
            return numberOfPeriods == 1 ? 'месяц' : 'месяцев';
          case 'year':
            return numberOfPeriods == 1 ? 'год' : 'лет';
          default:
            return numberOfPeriods == 1 ? 'день' : 'дней';
        }
      case 'th':
        switch (unit) {
          case 'day':
            return 'วัน';
          case 'week':
            return 'สัปดาห์';
          case 'month':
            return 'เดือน';
          case 'year':
            return 'ปี';
          default:
            return 'วัน';
        }
      case 'tr':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'gün' : 'gün';
          case 'week':
            return numberOfPeriods == 1 ? 'hafta' : 'hafta';
          case 'month':
            return numberOfPeriods == 1 ? 'ay' : 'ay';
          case 'year':
            return numberOfPeriods == 1 ? 'yıl' : 'yıl';
          default:
            return numberOfPeriods == 1 ? 'gün' : 'gün';
        }
      case 'uk':
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'день' : 'днів';
          case 'week':
            return numberOfPeriods == 1 ? 'тиждень' : 'тижнів';
          case 'month':
            return numberOfPeriods == 1 ? 'місяць' : 'місяців';
          case 'year':
            return numberOfPeriods == 1 ? 'рік' : 'років';
          default:
            return numberOfPeriods == 1 ? 'день' : 'днів';
        }
      case 'vi':
        switch (unit) {
          case 'day':
            return 'ngày';
          case 'week':
            return 'tuần';
          case 'month':
            return 'tháng';
          case 'year':
            return 'năm';
          default:
            return 'ngày';
        }
      case 'zh_Hans':
        switch (unit) {
          case 'day':
            return '天';
          case 'week':
            return '周';
          case 'month':
            return '月';
          case 'year':
            return '年';
          default:
            return '天';
        }
      case 'zh_Hant':
        switch (unit) {
          case 'day':
            return '天';
          case 'week':
            return '周';
          case 'month':
            return '月';
          case 'year':
            return '年';
          default:
            return '天';
        }
      default:
        // 默认返回英语
        switch (unit) {
          case 'day':
            return numberOfPeriods == 1 ? 'day' : 'days';
          case 'week':
            return numberOfPeriods == 1 ? 'week' : 'weeks';
          case 'month':
            return numberOfPeriods == 1 ? 'month' : 'months';
          case 'year':
            return numberOfPeriods == 1 ? 'year' : 'years';
          default:
            return numberOfPeriods == 1 ? 'day' : 'days';
        }
    }
  }

  /// 订阅标题（标准长度）
  static String subscriptionTitle(
    String duration,
    String languageCode, {
    bool isShort = false,
  }) {
    switch (languageCode) {
      case 'ar':
        switch (duration) {
          case 'week':
            return isShort ? 'أسبوعي' : 'اشتراك أسبوعي';
          case 'month':
            return isShort ? 'شهري' : 'اشتراك شهري';
          case 'year':
            return isShort ? 'سنوي' : 'اشتراك سنوي';
          case 'lifetime':
            return isShort ? 'مدى الحياة' : 'اشتراك مدى الحياة';
          default:
            return isShort ? 'أسبوعي' : 'اشتراك أسبوعي';
        }
      case 'de':
        switch (duration) {
          case 'week':
            return isShort ? 'Woche' : 'Wöchentliches Abo';
          case 'month':
            return isShort ? 'Monat' : 'Monatliches Abo';
          case 'year':
            return isShort ? 'Jahr' : 'Jährliches Abo';
          case 'lifetime':
            return isShort ? 'Lebenslang' : 'Lebenslanges Abo';
          default:
            return isShort ? 'Woche' : 'Wöchentliches Abo';
        }
      case 'en':
        switch (duration) {
          case 'week':
            return isShort ? 'Weekly' : 'Weekly Subscription';
          case 'month':
            return isShort ? 'Monthly' : 'Monthly Subscription';
          case 'year':
            return isShort ? 'Yearly' : 'Annual Subscription';
          case 'lifetime':
            return isShort ? 'Lifetime' : 'Lifetime Membership';
          default:
            return isShort ? 'Weekly' : 'Weekly Subscription';
        }
      case 'es':
        switch (duration) {
          case 'week':
            return isShort ? 'Semanal' : 'Suscripción semanal';
          case 'month':
            return isShort ? 'Mensual' : 'Suscripción mensual';
          case 'year':
            return isShort ? 'Anual' : 'Suscripción anual';
          case 'lifetime':
            return isShort ? 'De por vida' : 'Suscripción de por vida';
          default:
            return isShort ? 'Semanal' : 'Suscripción semanal';
        }
      case 'fil':
        switch (duration) {
          case 'week':
            return isShort ? 'Lingguhan' : 'Lingguhang Subscription';
          case 'month':
            return isShort ? 'Buwanang' : 'Buwanang Subscription';
          case 'year':
            return isShort ? 'Taunan' : 'Taunang Subscription';
          case 'lifetime':
            return isShort
                ? 'Panghabang-buhay'
                : 'Panghabang-buhay na Subscription';
          default:
            return isShort ? 'Lingguhan' : 'Lingguhang Subscription';
        }
      case 'fr':
        switch (duration) {
          case 'week':
            return isShort ? 'Hebdo' : 'Abonnement hebdomadaire';
          case 'month':
            return isShort ? 'Mensuel' : 'Abonnement mensuel';
          case 'year':
            return isShort ? 'Annuel' : 'Abonnement annuel';
          case 'lifetime':
            return isShort ? 'À vie' : 'Abonnement à vie';
          default:
            return isShort ? 'Hebdo' : 'Abonnement hebdomadaire';
        }
      case 'id':
        switch (duration) {
          case 'week':
            return isShort ? 'Mingguan' : 'Langganan mingguan';
          case 'month':
            return isShort ? 'Bulanan' : 'Langganan bulanan';
          case 'year':
            return isShort ? 'Tahunan' : 'Langganan tahunan';
          case 'lifetime':
            return isShort ? 'Seumur hidup' : 'Langganan seumur hidup';
          default:
            return isShort ? 'Mingguan' : 'Langganan mingguan';
        }
      case 'it':
        switch (duration) {
          case 'week':
            return isShort ? 'Sett.' : 'Abbonamento settimanale';
          case 'month':
            return isShort ? 'Mese' : 'Abbonamento mensile';
          case 'year':
            return isShort ? 'Anno' : 'Abbonamento annuale';
          case 'lifetime':
            return isShort ? 'A vita' : 'Abbonamento a vita';
          default:
            return isShort ? 'Sett.' : 'Abbonamento settimanale';
        }
      case 'ja':
        switch (duration) {
          case 'week':
            return isShort ? '週額' : '週額プラン';
          case 'month':
            return isShort ? '月額' : '月額プラン';
          case 'year':
            return isShort ? '年額' : '年額プラン';
          case 'lifetime':
            return isShort ? '生涯' : '生涯プラン';
          default:
            return isShort ? '週額' : '週額プラン';
        }
      case 'ko':
        switch (duration) {
          case 'week':
            return isShort ? '주간' : '주간 구독';
          case 'month':
            return isShort ? '월간' : '월간 구독';
          case 'year':
            return isShort ? '연간' : '연간 구독';
          case 'lifetime':
            return isShort ? '평생' : '평생 회원권';
          default:
            return isShort ? '주간' : '주간 구독';
        }
      case 'pl':
        switch (duration) {
          case 'week':
            return isShort ? 'Tyg.' : 'Subskrypcja tygodniowa';
          case 'month':
            return isShort ? 'Mies.' : 'Subskrypcja miesięczna';
          case 'year':
            return isShort ? 'Rocznie' : 'Subskrypcja roczna';
          case 'lifetime':
            return isShort ? 'Dożywotnia' : 'Subskrypcja dożywotnia';
          default:
            return isShort ? 'Tyg.' : 'Subskrypcja tygodniowa';
        }
      case 'pt':
        switch (duration) {
          case 'week':
            return isShort ? 'Semanal' : 'Assinatura semanal';
          case 'month':
            return isShort ? 'Mensal' : 'Assinatura mensal';
          case 'year':
            return isShort ? 'Anual' : 'Assinatura anual';
          case 'lifetime':
            return isShort ? 'Vitalício' : 'Assinatura vitalícia';
          default:
            return isShort ? 'Semanal' : 'Assinatura semanal';
        }
      case 'ru':
        switch (duration) {
          case 'week':
            return isShort ? 'Неделя' : 'Еженедельная подписка';
          case 'month':
            return isShort ? 'Месяц' : 'Ежемесячная подписка';
          case 'year':
            return isShort ? 'Год' : 'Годовая подписка';
          case 'lifetime':
            return isShort ? 'Навсегда' : 'Пожизненная подписка';
          default:
            return isShort ? 'Неделя' : 'Еженедельная подписка';
        }
      case 'th':
        switch (duration) {
          case 'week':
            return isShort ? 'รายสัปดาห์' : 'สมัครสมาชิกแบบรายสัปดาห์';
          case 'month':
            return isShort ? 'รายเดือน' : 'สมัครสมาชิกแบบรายเดือน';
          case 'year':
            return isShort ? 'รายปี' : 'สมัครสมาชิกแบบรายปี';
          case 'lifetime':
            return isShort ? 'ตลอดชีพ' : 'สมาชิกตลอดชีพ';
          default:
            return isShort ? 'รายสัปดาห์' : 'สมัครสมาชิกแบบรายสัปดาห์';
        }
      case 'tr':
        switch (duration) {
          case 'week':
            return isShort ? 'Haftalık' : 'Haftalık abonelik';
          case 'month':
            return isShort ? 'Aylık' : 'Aylık abonelik';
          case 'year':
            return isShort ? 'Yıllık' : 'Yıllık abonelik';
          case 'lifetime':
            return isShort ? 'Ömür boyu' : 'Ömür boyu abonelik';
          default:
            return isShort ? 'Haftalık' : 'Haftalık abonelik';
        }
      case 'uk':
        switch (duration) {
          case 'week':
            return isShort ? 'Тиж.' : 'Тижнева підписка';
          case 'month':
            return isShort ? 'Міс.' : 'Місячна підписка';
          case 'year':
            return isShort ? 'Рік' : 'Річна підписка';
          case 'lifetime':
            return isShort ? 'Довічна' : 'Довічна підписка';
          default:
            return isShort ? 'Тиж.' : 'Тижнева підписка';
        }
      case 'vi':
        switch (duration) {
          case 'week':
            return isShort ? 'Tuần' : 'Gói thuê bao hàng tuần';
          case 'month':
            return isShort ? 'Tháng' : 'Gói thuê bao hàng tháng';
          case 'year':
            return isShort ? 'Năm' : 'Gói thuê bao hàng năm';
          case 'lifetime':
            return isShort ? 'Trọn đời' : 'Gói trọn đời';
          default:
            return isShort ? 'Tuần' : 'Gói thuê bao hàng tuần';
        }
      case 'zh_Hans':
        switch (duration) {
          case 'week':
            return isShort ? '周会员' : '每周会员';
          case 'month':
            return isShort ? '月会员' : '每月会员';
          case 'year':
            return isShort ? '年会员' : '年度会员';
          case 'lifetime':
            return isShort ? '终身会员' : '终身会员';
          default:
            return isShort ? '周会员' : '每周会员';
        }
      case 'zh_Hant':
        switch (duration) {
          case 'week':
            return isShort ? '週會員' : '每週會員';
          case 'month':
            return isShort ? '月會員' : '每月會員';
          case 'year':
            return isShort ? '年會員' : '年度會員';
          case 'lifetime':
            return isShort ? '終身會員' : '終身會員';
          default:
            return isShort ? '週會員' : '每週會員';
        }
      default:
        // 默认返回英语
        switch (duration) {
          case 'week':
            return isShort ? 'Weekly' : 'Weekly Subscription';
          case 'month':
            return isShort ? 'Monthly' : 'Monthly Subscription';
          case 'year':
            return isShort ? 'Yearly' : 'Annual Subscription';
          case 'lifetime':
            return isShort ? 'Lifetime' : 'Lifetime Membership';
          default:
            return isShort ? 'Weekly' : 'Weekly Subscription';
        }
    }
  }

  // 默认副标题
  static String defaultSubtitle(
    SKProductWrapper skProduct,
    String duration,
    String languageCode,
  ) {
    final price = skProduct.price;
    final currencySymbol = skProduct.priceLocale.currencySymbol;
    final productUnit = _getLocalizedUnit(
      languageCode,
      1,
      getUnit(skProduct.subscriptionPeriod),
    );

    // 原价订阅描述：灵活选择、性价比之选、最优惠
    final description = SubsLocale.defaultSubDescription(
      duration,
      languageCode,
    );

    // 根据订阅类型和地区文化习惯显示价格
    switch (duration) {
      case 'week':
        return '$description,${_buildDefaultPrice(languageCode, price, currencySymbol, productUnit)}';
      case 'month':
        return '$description,${_buildMonthlyPrice(languageCode, price, currencySymbol)}';
      case 'year':
        return '$description,${_buildYearlyPrice(languageCode, price, currencySymbol)}';
      default:
        return '$description,${_buildDefaultPrice(languageCode, price, currencySymbol, productUnit)}';
    }
  }

  /// 获取订阅类型描述词
  static String defaultSubDescription(String duration, String languageCode) {
    switch (languageCode) {
      case 'ar':
        switch (duration) {
          case 'week':
            return 'مرونة';
          case 'month':
            return 'قيمة ممتازة';
          case 'year':
            return 'الأكثر توفيراً';
          default:
            return '';
        }
      case 'de':
        switch (duration) {
          case 'week':
            return 'Flexibilität';
          case 'month':
            return 'Bester Wert';
          case 'year':
            return 'Meist gespart';
          default:
            return '';
        }
      case 'en':
        switch (duration) {
          case 'week':
            return 'Flexible';
          case 'month':
            return 'Best Value';
          case 'year':
            return 'Most Popular';
          default:
            return '';
        }
      case 'es':
        switch (duration) {
          case 'week':
            return 'Flexible';
          case 'month':
            return 'Mejor Valor';
          case 'year':
            return 'Más Popular';
          default:
            return '';
        }
      case 'fil':
        switch (duration) {
          case 'week':
            return 'Nakakalag';
          case 'month':
            return 'Pinakamahusay na Halaga';
          case 'year':
            return 'Pinakasikat';
          default:
            return '';
        }
      case 'fr':
        switch (duration) {
          case 'week':
            return 'Flexible';
          case 'month':
            return 'Meilleur Rapport';
          case 'year':
            return 'Plus Populaire';
          default:
            return '';
        }
      case 'id':
        switch (duration) {
          case 'week':
            return 'Fleksibel';
          case 'month':
            return 'Nilai Terbaik';
          case 'year':
            return 'Paling Populer';
          default:
            return '';
        }
      case 'it':
        switch (duration) {
          case 'week':
            return 'Flessibile';
          case 'month':
            return 'Miglior Valore';
          case 'year':
            return 'Più Popolare';
          default:
            return '';
        }
      case 'ja':
        switch (duration) {
          case 'week':
            return '柔軟性';
          case 'month':
            return 'お得';
          case 'year':
            return '人気';
          default:
            return '';
        }
      case 'ko':
        switch (duration) {
          case 'week':
            return '유연함';
          case 'month':
            return '최고 가치';
          case 'year':
            return '인기';
          default:
            return '';
        }
      case 'pl':
        switch (duration) {
          case 'week':
            return 'Elastyczność';
          case 'month':
            return 'Najlepsza Wartość';
          case 'year':
            return 'Najpopularniejsze';
          default:
            return '';
        }
      case 'pt':
        switch (duration) {
          case 'week':
            return 'Flexível';
          case 'month':
            return 'Melhor Valor';
          case 'year':
            return 'Mais Popular';
          default:
            return '';
        }
      case 'ru':
        switch (duration) {
          case 'week':
            return 'Гибкость';
          case 'month':
            return 'Лучшая Цена';
          case 'year':
            return 'Популярный';
          default:
            return '';
        }
      case 'th':
        switch (duration) {
          case 'week':
            return 'ยืดหยุ่น';
          case 'month':
            return 'คุ้มค่าที่สุด';
          case 'year':
            return 'ยอดนิยม';
          default:
            return '';
        }
      case 'tr':
        switch (duration) {
          case 'week':
            return 'Esnek';
          case 'month':
            return 'En İyi Değer';
          case 'year':
            return 'En Popüler';
          default:
            return '';
        }
      case 'uk':
        switch (duration) {
          case 'week':
            return 'Гнучкість';
          case 'month':
            return 'Найкраща Ціна';
          case 'year':
            return 'Популярний';
          default:
            return '';
        }
      case 'vi':
        switch (duration) {
          case 'week':
            return 'Linh hoạt';
          case 'month':
            return 'Giá trị tốt nhất';
          case 'year':
            return 'Phổ biến nhất';
          default:
            return '';
        }
      case 'zh_Hans':
        switch (duration) {
          case 'week':
            return '灵活选择';
          case 'month':
            return '性价比之选';
          case 'year':
            return '最优惠';
          default:
            return '';
        }
      case 'zh_Hant':
        switch (duration) {
          case 'week':
            return '靈活選擇';
          case 'month':
            return '性價比之選';
          case 'year':
            return '最優惠';
          default:
            return '';
        }
      default:
        switch (duration) {
          case 'week':
            return 'Flexible';
          case 'month':
            return 'Best Value';
          case 'year':
            return 'Most Popular';
          default:
            return '';
        }
    }
  }

  /// 默认订阅价格显示
  static String _buildDefaultPrice(
    String languageCode,
    String price,
    String currencySymbol,
    String productUnit,
  ) {
    switch (languageCode) {
      case 'ar':
        return '$currencySymbol$price/$productUnit';
      case 'de':
        return '$currencySymbol$price/$productUnit';
      case 'en':
        return '$currencySymbol$price/$productUnit';
      case 'es':
        return '$currencySymbol$price/$productUnit';
      case 'fil':
        return '$currencySymbol$price/$productUnit';
      case 'fr':
        return '$currencySymbol$price/$productUnit';
      case 'id':
        return '$currencySymbol$price/$productUnit';
      case 'it':
        return '$currencySymbol$price/$productUnit';
      case 'ja':
        return '$currencySymbol$price/$productUnit';
      case 'ko':
        return '$currencySymbol$price/$productUnit';
      case 'pl':
        return '$currencySymbol$price/$productUnit';
      case 'pt':
        return '$currencySymbol$price/$productUnit';
      case 'ru':
        return '$currencySymbol$price/$productUnit';
      case 'th':
        return '$currencySymbol$price/$productUnit';
      case 'tr':
        return '$currencySymbol$price/$productUnit';
      case 'uk':
        return '$currencySymbol$price/$productUnit';
      case 'vi':
        return '$currencySymbol$price/$productUnit';
      case 'zh_Hans':
        return '每$productUnit$currencySymbol$price元';
      case 'zh_Hant':
        return '每$productUnit$currencySymbol$price';
      default:
        return '$currencySymbol$price/$productUnit';
    }
  }

  /// 月订阅价格显示 - 突出性价比
  static String _buildMonthlyPrice(
    String languageCode,
    String price,
    String currencySymbol,
  ) {
    final monthlyPrice = double.tryParse(price) ?? 0;
    final weeklyPrice = monthlyPrice / 4.33;

    switch (languageCode) {
      case 'ar':
        return '$currencySymbol$price/شهر · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/أسبوع';
      case 'de':
        return '$currencySymbol$price/Monat · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/Woche';
      case 'en':
        return '$currencySymbol$price/month · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/week';
      case 'es':
        return '$currencySymbol$price/mes · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/semana';
      case 'fil':
        return '$currencySymbol$price/buwan · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/linggo';
      case 'fr':
        return '$currencySymbol$price/mois · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/semaine';
      case 'id':
        return '$currencySymbol$price/bulan · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/minggu';
      case 'it':
        return '$currencySymbol$price/mese · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/settimana';
      case 'ja':
        return '$currencySymbol$price/月 · 約$currencySymbol${weeklyPrice.toStringAsFixed(1)}/週';
      case 'ko':
        return '$currencySymbol$price/월 · 약$currencySymbol${weeklyPrice.toStringAsFixed(1)}/주';
      case 'pl':
        return '$currencySymbol$price/miesiąc · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/tydzień';
      case 'pt':
        return '$currencySymbol$price/mês · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/semana';
      case 'ru':
        return '$currencySymbol$price/мес · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/нед';
      case 'th':
        return '$currencySymbol$price/เดือน · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/สัปดาห์';
      case 'tr':
        return '$currencySymbol$price/ay · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/hafta';
      case 'uk':
        return '$currencySymbol$price/міс · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/тиж';
      case 'vi':
        return '$currencySymbol$price/tháng · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/tuần';
      case 'zh_Hans':
        return '每月$currencySymbol$price元 · 约$currencySymbol${weeklyPrice.toStringAsFixed(1)}元/周';
      case 'zh_Hant':
        return '每月$currencySymbol$price · 約$currencySymbol${weeklyPrice.toStringAsFixed(1)}/周';
      default:
        return '$currencySymbol$price/month · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/week';
    }
  }

  /// 年订阅价格显示 - 突出最大优惠
  static String _buildYearlyPrice(
    String languageCode,
    String price,
    String currencySymbol,
  ) {
    final yearlyPrice = double.tryParse(price) ?? 0;
    final weeklyPrice = yearlyPrice / 52;

    switch (languageCode) {
      case 'ar':
        return '$currencySymbol$price/سنة · فقط $currencySymbol${weeklyPrice.toStringAsFixed(1)}/أسبوع';
      case 'de':
        return '$currencySymbol$price/Jahr · nur $currencySymbol${weeklyPrice.toStringAsFixed(1)}/Woche';
      case 'en':
        return '$currencySymbol$price/year · only $currencySymbol${weeklyPrice.toStringAsFixed(1)}/week';
      case 'es':
        return '$currencySymbol$price/año · solo $currencySymbol${weeklyPrice.toStringAsFixed(1)}/semana';
      case 'fil':
        return '$currencySymbol$price/taon · $currencySymbol${weeklyPrice.toStringAsFixed(1)}/linggo lang';
      case 'fr':
        return '$currencySymbol$price/an · seulement $currencySymbol${weeklyPrice.toStringAsFixed(1)}/semaine';
      case 'id':
        return '$currencySymbol$price/tahun · hanya $currencySymbol${weeklyPrice.toStringAsFixed(1)}/minggu';
      case 'it':
        return '$currencySymbol$price/anno · solo $currencySymbol${weeklyPrice.toStringAsFixed(1)}/settimana';
      case 'ja':
        return '$currencySymbol$price/年 · わずか$currencySymbol${weeklyPrice.toStringAsFixed(1)}/週';
      case 'ko':
        return '$currencySymbol$price/년 · 단$currencySymbol${weeklyPrice.toStringAsFixed(1)}/주';
      case 'pl':
        return '$currencySymbol$price/rok · tylko $currencySymbol${weeklyPrice.toStringAsFixed(1)}/tydzień';
      case 'pt':
        return '$currencySymbol$price/ano · apenas $currencySymbol${weeklyPrice.toStringAsFixed(1)}/semana';
      case 'ru':
        return '$currencySymbol$price/год · всего $currencySymbol${weeklyPrice.toStringAsFixed(1)}/нед';
      case 'th':
        return '$currencySymbol$price/ปี · เพียง $currencySymbol${weeklyPrice.toStringAsFixed(1)}/สัปดาห์';
      case 'tr':
        return '$currencySymbol$price/yıl · sadece $currencySymbol${weeklyPrice.toStringAsFixed(1)}/hafta';
      case 'uk':
        return '$currencySymbol$price/рік · ~$currencySymbol${weeklyPrice.toStringAsFixed(1)}/тиж';
      case 'vi':
        return '$currencySymbol$price/năm · chỉ $currencySymbol${weeklyPrice.toStringAsFixed(1)}/tuần';
      case 'zh_Hans':
        return '每年$currencySymbol$price元 · 仅$currencySymbol${weeklyPrice.toStringAsFixed(1)}元/周';
      case 'zh_Hant':
        return '每年$currencySymbol$price · 僅$currencySymbol${weeklyPrice.toStringAsFixed(1)}/周';
      default:
        return '$currencySymbol$price/year · only $currencySymbol${weeklyPrice.toStringAsFixed(1)}/week';
    }
  }

  /// 获取免费试用期的时间单位本地化文本
  ///
  /// [skProduct] 产品信息
  ///
  /// [languageCode] 语言代码：支持ar,de,en,es,fil,fr,id,it,ja,ko,pl,pt,ru,th,tr,uk,vi,zh_Hans,zh_Hant, 默认是en
  static String introductoryPriceSubtitle(
    SKProductWrapper skProduct,
    String languageCode,
  ) {
    if (skProduct.introductoryPrice == null) {
      return '';
    }
    final price = skProduct.price;
    final currencySymbol = skProduct.priceLocale.currencySymbol;
    final introductoryPrice = skProduct.introductoryPrice!;
    final productUnit = _getLocalizedUnit(
      languageCode,
      1,
      getUnit(skProduct.subscriptionPeriod),
    );
    switch (introductoryPrice.paymentMode) {
      case SKProductDiscountPaymentMode.payAsYouGo:
        // 按需付费：显示折扣价格
        final numberOfPeriods = introductoryPrice.numberOfPeriods;
        return _buildPayAsYouGoText(
          languageCode,
          introductoryPrice.price,
          currencySymbol,
          productUnit,
          numberOfPeriods,
        );

      case SKProductDiscountPaymentMode.payUpFront:
        // 预付：显示节省金额和折扣价格
        return _buildPayUpFrontText(
          languageCode,
          introductoryPrice.price,
          price,
          currencySymbol,
          productUnit,
        );

      case SKProductDiscountPaymentMode.freeTrail:
        // 免费试用：显示试用期和后续价格
        final numberOfPeriods =
            introductoryPrice.subscriptionPeriod.numberOfUnits;
        final trialUnit = getUnit(introductoryPrice.subscriptionPeriod);
        final unit1 = _getLocalizedUnit(
          languageCode,
          numberOfPeriods,
          trialUnit,
        );
        return _buildFreeTrialText(
          languageCode,
          numberOfPeriods,
          unit1,
          productUnit,
          price,
          currencySymbol,
        );
      default:
        return '';
    }
  }

  /// 获取折扣文本
  ///
  /// [skProduct] 产品信息
  /// [languageCode] 语言代码：支持ar,de,en,es,fil,fr,id,it,ja,ko,pl,pt,ru,th,tr,uk,vi,zh_Hans,zh_Hant, 默认是en
  static String discountSubtitle(
    SKProductWrapper skProduct,
    String languageCode,
  ) {
    if (skProduct.discounts.isEmpty) {
      return '';
    }
    final price = skProduct.price;
    final currencySymbol = skProduct.priceLocale.currencySymbol;
    final discount = skProduct.discounts.first;
    final productUnit = _getLocalizedUnit(
      languageCode,
      1,
      getUnit(skProduct.subscriptionPeriod),
    );
    switch (discount.paymentMode) {
      case SKProductDiscountPaymentMode.payAsYouGo:
        // 按需付费：显示折扣价格
        final numberOfPeriods = discount.numberOfPeriods;
        return _buildPayAsYouGoText(
          languageCode,
          discount.price,
          currencySymbol,
          productUnit,
          numberOfPeriods,
        );

      case SKProductDiscountPaymentMode.payUpFront:
        // 预付：显示节省金额和折扣价格
        return _buildPayUpFrontText(
          languageCode,
          discount.price,
          price,
          currencySymbol,
          productUnit,
        );

      case SKProductDiscountPaymentMode.freeTrail:
        // 免费试用：显示试用期和后续价格
        final numberOfPeriods = discount.subscriptionPeriod.numberOfUnits;
        final trialUnit = getUnit(discount.subscriptionPeriod);
        final unit1 = _getLocalizedUnit(
          languageCode,
          numberOfPeriods,
          trialUnit,
        );
        return _buildFreeTrialText(
          languageCode,
          numberOfPeriods,
          unit1,
          productUnit,
          price,
          currencySymbol,
        );
      default:
        return '';
    }
  }

  /// 构建按需付费文本
  static String _buildPayAsYouGoText(
    String languageCode,
    String introPrice,
    String currencySymbol,
    String productUnit,
    int numberOfPeriods,
  ) {
    switch (languageCode) {
      case 'ar':
        if (numberOfPeriods == 1) {
          return 'عرض خاص: $currencySymbol$introPrice/$productUnit (الأسبوع الأول)';
        } else {
          return 'عرض خاص: $currencySymbol$introPrice/$productUnit (الأسبوعين الأولين)';
        }
      case 'de':
        if (numberOfPeriods == 1) {
          return 'Sonderangebot: $currencySymbol$introPrice/$productUnit (erste Woche)';
        } else {
          return 'Sonderangebot: $currencySymbol$introPrice/$productUnit (erste $numberOfPeriods Wochen)';
        }
      case 'en':
        if (numberOfPeriods == 1) {
          return 'Special offer: $currencySymbol$introPrice/$productUnit (first $productUnit)';
        } else {
          return 'Special offer: $currencySymbol$introPrice/$productUnit (first $numberOfPeriods ${productUnit}s)';
        }
      case 'es':
        if (numberOfPeriods == 1) {
          return 'Oferta especial: $currencySymbol$introPrice/$productUnit (primer $productUnit)';
        } else {
          return 'Oferta especial: $currencySymbol$introPrice/$productUnit (primeros $numberOfPeriods ${productUnit}s)';
        }
      case 'fil':
        if (numberOfPeriods == 1) {
          return 'Espesyal na alok: $currencySymbol$introPrice/$productUnit (unang $productUnit)';
        } else {
          return 'Espesyal na alok: $currencySymbol$introPrice/$productUnit (unang $numberOfPeriods ${productUnit}s)';
        }
      case 'fr':
        if (numberOfPeriods == 1) {
          return 'Offre spéciale: $currencySymbol$introPrice/$productUnit (premier $productUnit)';
        } else {
          return 'Offre spéciale: $currencySymbol$introPrice/$productUnit (premiers $numberOfPeriods ${productUnit}s)';
        }
      case 'id':
        if (numberOfPeriods == 1) {
          return 'Penawaran khusus: $currencySymbol$introPrice/$productUnit ($productUnit pertama)';
        } else {
          return 'Penawaran khusus: $currencySymbol$introPrice/$productUnit ($numberOfPeriods $productUnit pertama)';
        }
      case 'it':
        if (numberOfPeriods == 1) {
          return 'Offerta speciale: $currencySymbol$introPrice/$productUnit (primo $productUnit)';
        } else {
          return 'Offerta speciale: $currencySymbol$introPrice/$productUnit (primi $numberOfPeriods ${productUnit}s)';
        }
      case 'ja':
        if (numberOfPeriods == 1) {
          return '特別価格: $currencySymbol$introPrice/$productUnit (初回$productUnit)';
        } else {
          return '特別価格: $currencySymbol$introPrice/$productUnit (初回$numberOfPeriods$productUnit)';
        }
      case 'ko':
        if (numberOfPeriods == 1) {
          return '특별 할인: $currencySymbol$introPrice/$productUnit (첫 $productUnit)';
        } else {
          return '특별 할인: $currencySymbol$introPrice/$productUnit (첫 $numberOfPeriods$productUnit)';
        }
      case 'pl':
        if (numberOfPeriods == 1) {
          return 'Oferta specjalna: $currencySymbol$introPrice/$productUnit (pierwszy $productUnit)';
        } else {
          return 'Oferta specjalna: $currencySymbol$introPrice/$productUnit (pierwsze $numberOfPeriods ${productUnit}s)';
        }
      case 'pt':
        if (numberOfPeriods == 1) {
          return 'Oferta especial: $currencySymbol$introPrice/$productUnit (primeiro $productUnit)';
        } else {
          return 'Oferta especial: $currencySymbol$introPrice/$productUnit (primeiros $numberOfPeriods ${productUnit}s)';
        }
      case 'ru':
        if (numberOfPeriods == 1) {
          return 'Специальное предложение: $currencySymbol$introPrice/$productUnit (первый $productUnit)';
        } else {
          return 'Специальное предложение: $currencySymbol$introPrice/$productUnit (первые $numberOfPeriods ${productUnit}s)';
        }
      case 'th':
        if (numberOfPeriods == 1) {
          return 'ข้อเสนอพิเศษ: $currencySymbol$introPrice/$productUnit ($productUnitแรก)';
        } else {
          return 'ข้อเสนอพิเศษ: $currencySymbol$introPrice/$productUnit ($numberOfPeriods $productUnitแรก)';
        }
      case 'tr':
        if (numberOfPeriods == 1) {
          return 'Özel teklif: $currencySymbol$introPrice/$productUnit (ilk $productUnit)';
        } else {
          return 'Özel teklif: $currencySymbol$introPrice/$productUnit (ilk $numberOfPeriods $productUnit)';
        }
      case 'uk':
        if (numberOfPeriods == 1) {
          return 'Спеціальна пропозиція: $currencySymbol$introPrice/$productUnit (перший $productUnit)';
        } else {
          return 'Спеціальна пропозиція: $currencySymbol$introPrice/$productUnit (перші $numberOfPeriods ${productUnit}s)';
        }
      case 'vi':
        if (numberOfPeriods == 1) {
          return 'Ưu đãi đặc biệt: $currencySymbol$introPrice/$productUnit ($productUnit đầu tiên)';
        } else {
          return 'Ưu đãi đặc biệt: $currencySymbol$introPrice/$productUnit ($numberOfPeriods $productUnit đầu tiên)';
        }
      case 'zh_Hans':
        if (numberOfPeriods == 1) {
          return '限时优惠: 每$productUnit$currencySymbol$introPrice元（首$productUnit）';
        } else {
          return '限时优惠: 每$productUnit$currencySymbol$introPrice元（前$numberOfPeriods$productUnit）';
        }
      case 'zh_Hant':
        if (numberOfPeriods == 1) {
          return '限時優惠: 每$productUnit$currencySymbol$introPrice（首$productUnit）';
        } else {
          return '限時優惠: 每$productUnit$currencySymbol$introPrice（前$numberOfPeriods$productUnit）';
        }
      default:
        if (numberOfPeriods == 1) {
          return 'Special offer: $currencySymbol$introPrice/$productUnit (first $productUnit)';
        } else {
          return 'Special offer: $currencySymbol$introPrice/$productUnit (first $numberOfPeriods ${productUnit}s)';
        }
    }
  }

  /// 构建预付文本
  static String _buildPayUpFrontText(
    String languageCode,
    String introPrice,
    String originalPrice,
    String currencySymbol,
    String productUnit,
  ) {
    // 计算折扣百分比
    final original = double.tryParse(originalPrice) ?? 0;
    final discounted = double.tryParse(introPrice) ?? 0;
    final discountPercent =
        original > 0 ? ((original - discounted) / original * 100).round() : 0;

    switch (languageCode) {
      case 'ar':
        return 'وفر $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'de':
        return 'Spare $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'en':
        return 'Save $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'es':
        return 'Ahorra $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'fil':
        return 'Makatipid ng $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'fr':
        return 'Économisez $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'id':
        return 'Hemat $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'it':
        return 'Risparmia $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'ja':
        return '$discountPercent%OFF: $currencySymbol$introPrice/$productUnit';
      case 'ko':
        return '$discountPercent% 할인: $currencySymbol$introPrice/$productUnit';
      case 'pl':
        return 'Zaoszczędź $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'pt':
        return 'Economize $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'ru':
        return 'Экономия $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'th':
        return 'ประหยัด $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'tr':
        return '%$discountPercent tasarruf: $currencySymbol$introPrice/$productUnit';
      case 'uk':
        return 'Економія $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'vi':
        return 'Tiết kiệm $discountPercent%: $currencySymbol$introPrice/$productUnit';
      case 'zh_Hans':
        return '节省$discountPercent%: 每$productUnit$currencySymbol$introPrice元';
      case 'zh_Hant':
        return '節省$discountPercent%: 每$productUnit$currencySymbol$introPrice';
      default:
        return 'Save $discountPercent%: $currencySymbol$introPrice/$productUnit';
    }
  }

  /// 构建试用期文本
  static String _buildFreeTrialText(
    String languageCode,
    int numberOfPeriods,
    String trialPeriodUnit,
    String productUnit,
    String price,
    String currencySymbol,
  ) {
    switch (languageCode) {
      case 'ar':
        return 'تجربة مجانية $numberOfPeriods $trialPeriodUnit، ثم $currencySymbol$price/$productUnit';
      case 'de':
        return '$numberOfPeriods-${trialPeriodUnit}ige kostenlose Testphase, dann $currencySymbol$price/$productUnit';
      case 'en':
        return 'Free trial $numberOfPeriods $trialPeriodUnit, then $currencySymbol$price/$productUnit';
      case 'es':
        return 'Prueba gratuita $numberOfPeriods $trialPeriodUnit, luego $currencySymbol$price/$productUnit';
      case 'fil':
        return 'Libreng pagsubok $numberOfPeriods $trialPeriodUnit, pagkatapos $currencySymbol$price/$productUnit';
      case 'fr':
        return 'Essai gratuit $numberOfPeriods $trialPeriodUnit, puis $currencySymbol$price/$productUnit';
      case 'id':
        return 'Coba gratis $numberOfPeriods $trialPeriodUnit, lalu $currencySymbol$price/$productUnit';
      case 'it':
        return 'Prova gratuita $numberOfPeriods $trialPeriodUnit, poi $currencySymbol$price/$productUnit';
      case 'ja':
        return '$numberOfPeriods$trialPeriodUnit無料トライアル、その後$currencySymbol$price/$productUnit';
      case 'ko':
        return '$numberOfPeriods$trialPeriodUnit 무료 체험, 이후 $currencySymbol$price/$productUnit';
      case 'pl':
        return 'Bezpłatny okres próbny $numberOfPeriods $trialPeriodUnit, następnie $currencySymbol$price/$productUnit';
      case 'pt':
        return 'Teste gratuito $numberOfPeriods $trialPeriodUnit, depois $currencySymbol$price/$productUnit';
      case 'ru':
        return 'Бесплатная пробная версия $numberOfPeriods $trialPeriodUnit, затем $currencySymbol$price/$productUnit';
      case 'th':
        return 'ทดลองใช้ฟรี $numberOfPeriods $trialPeriodUnit จากนั้น $currencySymbol$price/$productUnit';
      case 'tr':
        return '$numberOfPeriods $trialPeriodUnit ücretsiz deneme, sonrasında $currencySymbol$price/$productUnit';
      case 'uk':
        return 'Безкоштовна пробна версія $numberOfPeriods $trialPeriodUnit, потім $currencySymbol$price/$productUnit';
      case 'vi':
        return 'Dùng thử miễn phí $numberOfPeriods $trialPeriodUnit, sau đó $currencySymbol$price/$productUnit';
      case 'zh_Hans':
        return '免费试用 $numberOfPeriods $trialPeriodUnit，然后每$productUnit$currencySymbol$price元';
      case 'zh_Hant':
        return '免費試用 $numberOfPeriods $trialPeriodUnit，然後每$productUnit$currencySymbol$price';
      default:
        return 'Free trial $numberOfPeriods $trialPeriodUnit, then $currencySymbol$price/$productUnit';
    }
  }
}
