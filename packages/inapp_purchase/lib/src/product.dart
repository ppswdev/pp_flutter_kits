import 'package:inapp_purchase/src/enums.dart';

/// 订阅优惠信息类
class SubscriptionOffer {
  final String? id;
  final SubscriptionOfferType? type;
  final int? offerPeriodCount;
  final double? price;
  final String? displayPrice;
  final SubscriptionOfferPaymentMode? paymentMode;
  final int? periodCount;
  final SubscriptionPeriodUnit? periodUnit;

  SubscriptionOffer({
    this.id,
    this.type,
    this.offerPeriodCount,
    this.price,
    this.displayPrice,
    this.paymentMode,
    this.periodCount,
    this.periodUnit,
  });

  factory SubscriptionOffer.fromMap(Map<String, dynamic> map) {
    return SubscriptionOffer(
      id: map['id'] as String?,
      type: SubscriptionOfferTypeConverter.fromString(map['type'] as String?),
      offerPeriodCount: map['offerPeriodCount'] as int?,
      price: map['price'] as double?,
      displayPrice: map['displayPrice'] as String?,
      paymentMode: SubscriptionOfferPaymentModeConverter.fromString(
        map['paymentMode'] as String?,
      ),
      periodCount: map['periodCount'] as int?,
      periodUnit: SubscriptionPeriodUnitConverter.fromString(
        map['periodUnit'] as String?,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': SubscriptionOfferTypeConverter.toStringValue(type),
      'offerPeriodCount': offerPeriodCount,
      'price': price,
      'displayPrice': displayPrice,
      'paymentMode': SubscriptionOfferPaymentModeConverter.toStringValue(
        paymentMode,
      ),
      'periodCount': periodCount,
      'periodUnit': SubscriptionPeriodUnitConverter.toStringValue(periodUnit),
    };
  }

  // 使用enums.dart中的转换器类
}

/// 订阅信息类
class SubscriptionInfo {
  final String? subscriptionGroupID;
  final int? subscriptionPeriodCount;
  final SubscriptionPeriodUnit? subscriptionPeriodUnit;
  final SubscriptionOffer? introductoryOffer;
  final List<SubscriptionOffer>? promotionalOffers;
  final List<SubscriptionOffer>? winBackOffers;

  SubscriptionInfo({
    this.subscriptionGroupID,
    this.subscriptionPeriodCount,
    this.subscriptionPeriodUnit,
    this.introductoryOffer,
    this.promotionalOffers,
    this.winBackOffers,
  });

  factory SubscriptionInfo.fromMap(Map<String, dynamic> map) {
    return SubscriptionInfo(
      subscriptionGroupID: map['subscriptionGroupID'] as String?,
      subscriptionPeriodCount: map['subscriptionPeriodCount'] as int?,
      subscriptionPeriodUnit: SubscriptionPeriodUnitConverter.fromString(
        map['subscriptionPeriodUnit'] as String?,
      ),
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
      'subscriptionPeriodCount': subscriptionPeriodCount,
      'subscriptionPeriodUnit': SubscriptionPeriodUnitConverter.toStringValue(
        subscriptionPeriodUnit,
      ),
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
