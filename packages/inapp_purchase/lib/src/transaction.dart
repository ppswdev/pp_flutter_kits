class Transaction {
  final String? transactionId;
  final String? originalTransactionId;
  final String? productId;
  final String? productType;
  final String? purchaseDate;
  final int? purchaseDateTimestamp;
  final String? originalPurchaseDate;
  final int? originalPurchaseDateTimestamp;
  final String? expiresDate;
  final int? expiresDateTimestamp;
  final bool? isPurchased;
  final bool? isRevoked;
  final bool? isRestored;
  final bool? isExpired;
  final bool? isRenewed;
  final bool? isConsumed;
  final bool? isUpgraded;
  final String? storefront;
  final String? storefrontCountryCode;
  final String? cancellationReason;
  final String? revocationDate;
  final int? revocationDateTimestamp;
  final String? revocationReason;
  final int? quantity;
  final String? appAccountToken;
  final String? webOrderLineItemId;
  final Map<String, dynamic>? subscriptionGroup;
  final Map<String, dynamic>? subscriptionPeriod;
  final Map<String, dynamic>? introductoryOfferEligibility;
  final Map<String, dynamic>? renewalInfo;
  final String? renewalState;
  final bool? willAutoRenew;
  final String? promotionalOfferId;
  final String? type;
  final Map<String, dynamic>? verificationData;
  final String? signature;
  final String? receipt;
  final Map<String, dynamic>? transactionReceipt;
  final String? environment;
  final Map<String, dynamic>? offerDetails;
  final Map<String, dynamic>? renewalOfferDetails;
  final bool? isFamilyShareable;

  Transaction({
    this.transactionId,
    this.originalTransactionId,
    this.productId,
    this.productType,
    this.purchaseDate,
    this.purchaseDateTimestamp,
    this.originalPurchaseDate,
    this.originalPurchaseDateTimestamp,
    this.expiresDate,
    this.expiresDateTimestamp,
    this.isPurchased,
    this.isRevoked,
    this.isRestored,
    this.isExpired,
    this.isRenewed,
    this.isConsumed,
    this.isUpgraded,
    this.storefront,
    this.storefrontCountryCode,
    this.cancellationReason,
    this.revocationDate,
    this.revocationDateTimestamp,
    this.revocationReason,
    this.quantity,
    this.appAccountToken,
    this.webOrderLineItemId,
    this.subscriptionGroup,
    this.subscriptionPeriod,
    this.introductoryOfferEligibility,
    this.renewalInfo,
    this.renewalState,
    this.willAutoRenew,
    this.promotionalOfferId,
    this.type,
    this.verificationData,
    this.signature,
    this.receipt,
    this.transactionReceipt,
    this.environment,
    this.offerDetails,
    this.renewalOfferDetails,
    this.isFamilyShareable,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      transactionId: map['transactionId'] as String?,
      originalTransactionId: map['originalTransactionId'] as String?,
      productId: map['productId'] as String?,
      productType: map['productType'] as String?,
      purchaseDate: map['purchaseDate'] as String?,
      purchaseDateTimestamp: map['purchaseDateTimestamp'] as int?,
      originalPurchaseDate: map['originalPurchaseDate'] as String?,
      originalPurchaseDateTimestamp: map['originalPurchaseDateTimestamp'] as int?,
      expiresDate: map['expiresDate'] as String?,
      expiresDateTimestamp: map['expiresDateTimestamp'] as int?,
      isPurchased: map['isPurchased'] as bool?,
      isRevoked: map['isRevoked'] as bool?,
      isRestored: map['isRestored'] as bool?,
      isExpired: map['isExpired'] as bool?,
      isRenewed: map['isRenewed'] as bool?,
      isConsumed: map['isConsumed'] as bool?,
      isUpgraded: map['isUpgraded'] as bool?,
      storefront: map['storefront'] as String?,
      storefrontCountryCode: map['storefrontCountryCode'] as String?,
      cancellationReason: map['cancellationReason'] as String?,
      revocationDate: map['revocationDate'] as String?,
      revocationDateTimestamp: map['revocationDateTimestamp'] as int?,
      revocationReason: map['revocationReason'] as String?,
      quantity: map['quantity'] as int?,
      appAccountToken: map['appAccountToken'] as String?,
      webOrderLineItemId: map['webOrderLineItemId'] as String?,
      subscriptionGroup: map['subscriptionGroup'] as Map<String, dynamic>?,
      subscriptionPeriod: map['subscriptionPeriod'] as Map<String, dynamic>?,
      introductoryOfferEligibility: map['introductoryOfferEligibility'] as Map<String, dynamic>?,
      renewalInfo: map['renewalInfo'] as Map<String, dynamic>?,
      renewalState: map['renewalState'] as String?,
      willAutoRenew: map['willAutoRenew'] as bool?,
      promotionalOfferId: map['promotionalOfferId'] as String?,
      type: map['type'] as String?,
      verificationData: map['verificationData'] as Map<String, dynamic>?,
      signature: map['signature'] as String?,
      receipt: map['receipt'] as String?,
      transactionReceipt: map['transactionReceipt'] as Map<String, dynamic>?,
      environment: map['environment'] as String?,
      offerDetails: map['offerDetails'] as Map<String, dynamic>?,
      renewalOfferDetails: map['renewalOfferDetails'] as Map<String, dynamic>?,
      isFamilyShareable: map['isFamilyShareable'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'originalTransactionId': originalTransactionId,
      'productId': productId,
      'productType': productType,
      'purchaseDate': purchaseDate,
      'purchaseDateTimestamp': purchaseDateTimestamp,
      'originalPurchaseDate': originalPurchaseDate,
      'originalPurchaseDateTimestamp': originalPurchaseDateTimestamp,
      'expiresDate': expiresDate,
      'expiresDateTimestamp': expiresDateTimestamp,
      'isPurchased': isPurchased,
      'isRevoked': isRevoked,
      'isRestored': isRestored,
      'isExpired': isExpired,
      'isRenewed': isRenewed,
      'isConsumed': isConsumed,
      'isUpgraded': isUpgraded,
      'storefront': storefront,
      'storefrontCountryCode': storefrontCountryCode,
      'cancellationReason': cancellationReason,
      'revocationDate': revocationDate,
      'revocationDateTimestamp': revocationDateTimestamp,
      'revocationReason': revocationReason,
      'quantity': quantity,
      'appAccountToken': appAccountToken,
      'webOrderLineItemId': webOrderLineItemId,
      'subscriptionGroup': subscriptionGroup,
      'subscriptionPeriod': subscriptionPeriod,
      'introductoryOfferEligibility': introductoryOfferEligibility,
      'renewalInfo': renewalInfo,
      'renewalState': renewalState,
      'willAutoRenew': willAutoRenew,
      'promotionalOfferId': promotionalOfferId,
      'type': type,
      'verificationData': verificationData,
      'signature': signature,
      'receipt': receipt,
      'transactionReceipt': transactionReceipt,
      'environment': environment,
      'offerDetails': offerDetails,
      'renewalOfferDetails': renewalOfferDetails,
      'isFamilyShareable': isFamilyShareable,
    };
  }
}
