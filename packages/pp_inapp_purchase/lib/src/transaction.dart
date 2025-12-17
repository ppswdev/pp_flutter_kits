import 'enums.dart';

/// 交易信息类
class Transaction {
  final String? id;
  final String? productID;
  final ProductType? productType;
  final OwnershipType? ownershipType;
  final double? price;
  final String? currency;
  final String? originalID;
  final int? originalPurchaseDate;
  final int? purchaseDate;
  final int? purchasedQuantity;
  final PurchaseReason? purchaseReason;
  final String? subscriptionGroupID;
  final int? expirationDate;
  final bool? isUpgraded;
  final bool? hasRevocation;
  final int? revocationDate;
  final int? revocationReason;
  final String? environment;
  final String? appAccountToken;
  final String? appBundleID;
  final String? appTransactionID;
  final int? signedDate;
  final String? storefrontId;
  final String? storefrontCountryCode;
  final String? storefrontCurrency;
  final String? webOrderLineItemID;
  final String? deviceVerificationNonce;
  final String? deviceVerification;
  final TransactionOffer? offer;
  final bool isSubscribedButFreeTrailCancelled;

  Transaction({
    this.id,
    this.productID,
    this.productType,
    this.ownershipType,
    this.price,
    this.currency,
    this.originalID,
    this.originalPurchaseDate,
    this.purchaseDate,
    this.purchasedQuantity,
    this.purchaseReason,
    this.subscriptionGroupID,
    this.expirationDate,
    this.isUpgraded,
    this.hasRevocation,
    this.revocationDate,
    this.revocationReason,
    this.environment,
    this.appAccountToken,
    this.appBundleID,
    this.appTransactionID,
    this.signedDate,
    this.storefrontId,
    this.storefrontCountryCode,
    this.storefrontCurrency,
    this.webOrderLineItemID,
    this.deviceVerificationNonce,
    this.deviceVerification,
    this.offer,
    this.isSubscribedButFreeTrailCancelled = false,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String?,
      productID: map['productID'] as String?,
      productType: ProductTypeConverter.fromString(
        map['productType'] as String?,
      ),
      ownershipType: OwnershipTypeConverter.fromString(
        map['ownershipType'] as String?,
      ),
      price: map['price'] as double?,
      currency: map['currency'] as String?,
      originalID: map['originalID'] as String?,
      originalPurchaseDate: map['originalPurchaseDate'] as int?,
      purchaseDate: map['purchaseDate'] as int?,
      purchasedQuantity: map['purchasedQuantity'] as int?,
      purchaseReason: PurchaseReasonConverter.fromString(
        map['purchaseReason'] as String?,
      ),
      subscriptionGroupID: map['subscriptionGroupID'] as String?,
      expirationDate: map['expirationDate'] as int?,
      isUpgraded: map['isUpgraded'] as bool?,
      hasRevocation: map['hasRevocation'] as bool?,
      revocationDate: map['revocationDate'] as int?,
      revocationReason: map['revocationReason'] as int?,
      environment: map['environment'] as String?,
      appAccountToken: map['appAccountToken'] as String?,
      appBundleID: map['appBundleID'] as String?,
      appTransactionID: map['appTransactionID'] as String?,
      signedDate: map['signedDate'] as int?,
      storefrontId: map['storefrontId'] as String?,
      storefrontCountryCode: map['storefrontCountryCode'] as String?,
      storefrontCurrency: map['storefrontCurrency'] as String?,
      webOrderLineItemID: map['webOrderLineItemID'] as String?,
      deviceVerificationNonce: map['deviceVerificationNonce'] as String?,
      deviceVerification: map['deviceVerification'] as String?,
      offer: map['offer'] != null
          ? TransactionOffer.fromMap(map['offer'] as Map<String, dynamic>)
          : null,
      isSubscribedButFreeTrailCancelled:
          map['isSubscribedButFreeTrailCancelled'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productID': productID,
      'productType': ProductTypeConverter.toStringValue(productType),
      'ownershipType': OwnershipTypeConverter.toStringValue(ownershipType),
      'price': price,
      'currency': currency,
      'originalID': originalID,
      'originalPurchaseDate': originalPurchaseDate,
      'purchaseDate': purchaseDate,
      'purchasedQuantity': purchasedQuantity,
      'purchaseReason': PurchaseReasonConverter.toStringValue(purchaseReason),
      'subscriptionGroupID': subscriptionGroupID,
      'expirationDate': expirationDate,
      'isUpgraded': isUpgraded,
      'hasRevocation': hasRevocation,
      'revocationDate': revocationDate,
      'revocationReason': revocationReason,
      'environment': environment,
      'appAccountToken': appAccountToken,
      'appBundleID': appBundleID,
      'appTransactionID': appTransactionID,
      'signedDate': signedDate,
      'storefrontId': storefrontId,
      'storefrontCountryCode': storefrontCountryCode,
      'storefrontCurrency': storefrontCurrency,
      'webOrderLineItemID': webOrderLineItemID,
      'deviceVerificationNonce': deviceVerificationNonce,
      'deviceVerification': deviceVerification,
      'offer': offer?.toMap(),
      'isSubscribedButFreeTrailCancelled': isSubscribedButFreeTrailCancelled,
    };
  }
}

/// 交易优惠信息类
class TransactionOffer {
  final String? id;
  final SubscriptionOfferType? type;
  final SubscriptionOfferPaymentMode? paymentMode;
  final SubscriptionPeriodUnit? periodUnit;
  final int? periodCount;

  TransactionOffer({
    this.id,
    this.type,
    this.paymentMode,
    this.periodUnit,
    this.periodCount,
  });

  factory TransactionOffer.fromMap(Map<String, dynamic> map) {
    return TransactionOffer(
      id: map['id'] as String?,
      type: SubscriptionOfferTypeConverter.fromString(map['type'] as String?),
      paymentMode: SubscriptionOfferPaymentModeConverter.fromString(
        map['paymentMode'] as String?,
      ),
      periodUnit: SubscriptionPeriodUnitConverter.fromString(
        map['periodUnit'] as String?,
      ),
      periodCount: map['periodCount'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': SubscriptionOfferTypeConverter.toStringValue(type),
      'paymentMode': SubscriptionOfferPaymentModeConverter.toStringValue(
        paymentMode,
      ),
      'periodUnit': SubscriptionPeriodUnitConverter.toStringValue(periodUnit),
      'periodCount': periodCount,
    };
  }
}
