import 'dart:convert';
import 'dart:io';
import 'package:inapp_purchase/src/enums.dart';
import 'package:inapp_purchase/src/transaction.dart';
import 'package:test/test.dart';

void main() {
  group('Transaction tests', () {
    test('Parse transaction.json file', () {
      // Read the JSON file
      final file = File(
        '/Users/xiaopin/Desktop/AppDev/Projects/pp_flutter_kits/packages/inapp_purchase/example/json/transaction.json',
      );
      final jsonString = file.readAsStringSync();
      final List<dynamic> jsonList = json.decode(jsonString);

      // Parse each transaction
      final transactions = jsonList
          .map((json) => Transaction.fromMap(json as Map<String, dynamic>))
          .toList();

      // Verify the number of transactions
      expect(transactions.length, 4);

      // Verify the first transaction
      final transaction0 = transactions[0];
      expect(transaction0.id, '0');
      expect(transaction0.productID, 'com.ppswdev.store.inapp.weeklyvip');
      expect(transaction0.productType, ProductType.autoRenewable);
      expect(transaction0.ownershipType, OwnershipType.purchased);
      expect(transaction0.price, 0.0);
      expect(transaction0.currency, 'usd');
      expect(transaction0.originalID, '0');
      expect(transaction0.originalPurchaseDate, 1765437130033);
      expect(transaction0.purchaseDate, 1765437130033);
      expect(transaction0.purchasedQuantity, 1);
      expect(transaction0.purchaseReason, PurchaseReason.purchase);
      expect(transaction0.subscriptionGroupID, '732E29F2');
      expect(transaction0.expirationDate, 1765437190033);
      expect(transaction0.isUpgraded, false);
      expect(transaction0.hasRevocation, false);
      expect(transaction0.revocationDate, null);
      expect(transaction0.revocationReason, null);
      expect(transaction0.environment, 'xcode');
      expect(transaction0.appAccountToken, '');
      expect(transaction0.appBundleID, 'com.ppswdev.StoreKit2');
      expect(transaction0.appTransactionID, '0');
      expect(transaction0.signedDate, 1765437130039);
      expect(transaction0.storefrontId, '143441');
      expect(transaction0.storefrontCountryCode, 'USA');
      expect(transaction0.storefrontCurrency, 'usd');
      expect(transaction0.webOrderLineItemID, '0');
      expect(
        transaction0.deviceVerificationNonce,
        'E23613F0-CFFB-42EA-9EAA-44E28FE07818',
      );
      expect(
        transaction0.deviceVerification,
        'fX78HN1fMkn9XpIBhafJeCVART5qXIutEib+Gsncvxu5jRzSi6dVW38W+ugj4izU',
      );

      // Verify the offer in the first transaction
      expect(transaction0.offer, isNotNull);
      expect(transaction0.offer?.id, null);
      expect(transaction0.offer?.type, SubscriptionOfferType.introductory);
      expect(
        transaction0.offer?.paymentMode,
        SubscriptionOfferPaymentMode.freeTrial,
      );
      expect(transaction0.offer?.periodUnit, SubscriptionPeriodUnit.day);
      expect(transaction0.offer?.periodCount, 3);

      // Verify the second transaction (non-renewable)
      final transaction1 = transactions[1];
      expect(transaction1.id, '4');
      expect(transaction1.productID, 'com.ppswdev.store.non.monthlyvip');
      expect(transaction1.productType, ProductType.nonRenewable);
      expect(transaction1.price, 19.99);
      expect(transaction1.offer, null);

      // Verify the third transaction (non-consumable)
      final transaction2 = transactions[2];
      expect(transaction2.id, '3');
      expect(transaction2.productID, 'com.ppswdev.store.lifetimevip');
      expect(transaction2.productType, ProductType.nonConsumable);
      expect(transaction2.price, 39.99);
      expect(transaction2.offer, null);

      // Verify the fourth transaction (consumable)
      final transaction3 = transactions[3];
      expect(transaction3.id, '2');
      expect(transaction3.productID, 'com.ppswdev.store.goldcoin.10');
      expect(transaction3.productType, ProductType.consumable);
      expect(transaction3.price, 0.99);
      expect(transaction3.offer, null);

      // Test toMap method
      final transactionMap = transaction0.toMap();
      expect(transactionMap['id'], '0');
      expect(transactionMap['productID'], 'com.ppswdev.store.inapp.weeklyvip');
      expect(transactionMap['productType'], 'autoRenewable');
      expect(transactionMap['ownershipType'], 'purchased');
      expect(transactionMap['price'], 0.0);
      expect(transactionMap['offer'], isNotNull);

      // Test round-trip serialization
      final roundTripTransaction = Transaction.fromMap(transactionMap);
      expect(roundTripTransaction.id, transaction0.id);
      expect(roundTripTransaction.productID, transaction0.productID);
      expect(roundTripTransaction.productType, transaction0.productType);
      expect(roundTripTransaction.ownershipType, transaction0.ownershipType);
      expect(roundTripTransaction.price, transaction0.price);
    });
  });
}
