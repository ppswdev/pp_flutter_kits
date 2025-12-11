/// 订阅周期单位枚举
enum SubscriptionPeriodUnit { day, week, month, year, unknown }

/// 订阅优惠类型枚举
enum SubscriptionOfferType { introductory, promotional, winBack, unknown }

/// 订阅优惠支付模式枚举
enum SubscriptionOfferPaymentMode { payAsYouGo, payUpFront, freeTrial, unknown }

/// 订阅周期信息类
class SubscriptionPeriod {
  final int? value;
  final SubscriptionPeriodUnit? unit;

  SubscriptionPeriod({this.value, this.unit});

  factory SubscriptionPeriod.fromMap(Map<String, dynamic> map) {
    return SubscriptionPeriod(
      value: map['value'] as int?,
      unit: _stringToSubscriptionPeriodUnit(map['unit'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {'value': value, 'unit': _subscriptionPeriodUnitToString(unit)};
  }

  static SubscriptionPeriodUnit? _stringToSubscriptionPeriodUnit(String? unit) {
    switch (unit) {
      case 'day':
        return SubscriptionPeriodUnit.day;
      case 'week':
        return SubscriptionPeriodUnit.week;
      case 'month':
        return SubscriptionPeriodUnit.month;
      case 'year':
        return SubscriptionPeriodUnit.year;
      default:
        return SubscriptionPeriodUnit.unknown;
    }
  }

  static String? _subscriptionPeriodUnitToString(SubscriptionPeriodUnit? unit) {
    switch (unit) {
      case SubscriptionPeriodUnit.day:
        return 'day';
      case SubscriptionPeriodUnit.week:
        return 'week';
      case SubscriptionPeriodUnit.month:
        return 'month';
      case SubscriptionPeriodUnit.year:
        return 'year';
      default:
        return 'unknown';
    }
  }
}

/// 订阅优惠信息类
class SubscriptionOffer {
  final String? id;
  final SubscriptionOfferType? type;
  final String? displayPrice;
  final double? price;
  final SubscriptionOfferPaymentMode? paymentMode;
  final SubscriptionPeriod? period;
  final int? periodCount;

  SubscriptionOffer({
    this.id,
    this.type,
    this.displayPrice,
    this.price,
    this.paymentMode,
    this.period,
    this.periodCount,
  });

  factory SubscriptionOffer.fromMap(Map<String, dynamic> map) {
    return SubscriptionOffer(
      id: map['id'] as String?,
      type: _stringToSubscriptionOfferType(map['type'] as String?),
      displayPrice: map['displayPrice'] as String?,
      price: map['price'] as double?,
      paymentMode: _stringToSubscriptionOfferPaymentMode(
        map['paymentMode'] as String?,
      ),
      period: map['period'] != null
          ? SubscriptionPeriod.fromMap(map['period'] as Map<String, dynamic>)
          : null,
      periodCount: map['periodCount'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': _subscriptionOfferTypeToString(type),
      'displayPrice': displayPrice,
      'price': price,
      'paymentMode': _subscriptionOfferPaymentModeToString(paymentMode),
      'period': period?.toMap(),
      'periodCount': periodCount,
    };
  }

  static SubscriptionOfferType? _stringToSubscriptionOfferType(String? type) {
    switch (type) {
      case 'introductory':
        return SubscriptionOfferType.introductory;
      case 'promotional':
        return SubscriptionOfferType.promotional;
      case 'winBack':
        return SubscriptionOfferType.winBack;
      default:
        return SubscriptionOfferType.unknown;
    }
  }

  static String? _subscriptionOfferTypeToString(SubscriptionOfferType? type) {
    switch (type) {
      case SubscriptionOfferType.introductory:
        return 'introductory';
      case SubscriptionOfferType.promotional:
        return 'promotional';
      case SubscriptionOfferType.winBack:
        return 'winBack';
      default:
        return 'unknown';
    }
  }

  static SubscriptionOfferPaymentMode? _stringToSubscriptionOfferPaymentMode(
    String? mode,
  ) {
    switch (mode) {
      case 'payAsYouGo':
        return SubscriptionOfferPaymentMode.payAsYouGo;
      case 'payUpFront':
        return SubscriptionOfferPaymentMode.payUpFront;
      case 'freeTrial':
        return SubscriptionOfferPaymentMode.freeTrial;
      default:
        return SubscriptionOfferPaymentMode.unknown;
    }
  }

  static String? _subscriptionOfferPaymentModeToString(
    SubscriptionOfferPaymentMode? mode,
  ) {
    switch (mode) {
      case SubscriptionOfferPaymentMode.payAsYouGo:
        return 'payAsYouGo';
      case SubscriptionOfferPaymentMode.payUpFront:
        return 'payUpFront';
      case SubscriptionOfferPaymentMode.freeTrial:
        return 'freeTrial';
      default:
        return 'unknown';
    }
  }
}

/// 订阅信息类
class SubscriptionInfo {
  final String? subscriptionGroupID;
  final SubscriptionPeriod? subscriptionPeriod;
  final SubscriptionOffer? introductoryOffer;
  final List<SubscriptionOffer>? promotionalOffers;
  final List<SubscriptionOffer>? winBackOffers;

  SubscriptionInfo({
    this.subscriptionGroupID,
    this.subscriptionPeriod,
    this.introductoryOffer,
    this.promotionalOffers,
    this.winBackOffers,
  });

  factory SubscriptionInfo.fromMap(Map<String, dynamic> map) {
    return SubscriptionInfo(
      subscriptionGroupID: map['subscriptionGroupID'] as String?,
      subscriptionPeriod: map['subscriptionPeriod'] != null
          ? SubscriptionPeriod.fromMap(
              map['subscriptionPeriod'] as Map<String, dynamic>,
            )
          : null,
      introductoryOffer: map['introductoryOffer'] != null
          ? SubscriptionOffer.fromMap(
              map['introductoryOffer'] as Map<String, dynamic>,
            )
          : null,
      promotionalOffers: map['promotionalOffers'] != null
          ? (map['promotionalOffers'] as List<dynamic>)
                .map(
                  (item) =>
                      SubscriptionOffer.fromMap(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      winBackOffers: map['winBackOffers'] != null
          ? (map['winBackOffers'] as List<dynamic>)
                .map(
                  (item) =>
                      SubscriptionOffer.fromMap(item as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subscriptionGroupID': subscriptionGroupID,
      'subscriptionPeriod': subscriptionPeriod?.toMap(),
      'introductoryOffer': introductoryOffer?.toMap(),
      'promotionalOffers': promotionalOffers
          ?.map((offer) => offer.toMap())
          .toList(),
      'winBackOffers': winBackOffers?.map((offer) => offer.toMap()).toList(),
    };
  }
}

/// 产品信息类
class Product {
  final String? id;
  final String? displayName;
  final String? description;
  final double? price;
  final String? displayPrice;
  final String? type;
  final bool? isFamilyShareable;
  final String? jsonRepresentation;
  final SubscriptionInfo? subscription;

  Product({
    this.id,
    this.displayName,
    this.description,
    this.price,
    this.displayPrice,
    this.type,
    this.isFamilyShareable,
    this.jsonRepresentation,
    this.subscription,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String?,
      displayName: map['displayName'] as String?,
      description: map['description'] as String?,
      price: map['price'] as double?,
      displayPrice: map['displayPrice'] as String?,
      type: map['type'] as String?,
      isFamilyShareable: map['isFamilyShareable'] as bool?,
      jsonRepresentation: map['jsonRepresentation'] as String?,
      subscription: map['subscription'] != null
          ? SubscriptionInfo.fromMap(
              map['subscription'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'description': description,
      'price': price,
      'displayPrice': displayPrice,
      'type': type,
      'isFamilyShareable': isFamilyShareable,
      'jsonRepresentation': jsonRepresentation,
      'subscription': subscription?.toMap(),
    };
  }
}
