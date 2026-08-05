import 'package:pp_inapp_purchase/src/transaction.dart';
import 'package:test/test.dart';

void main() {
  test('parses StoreKit revocation metadata', () {
    final transaction = Transaction.fromMap({
      'id': '1000001',
      'productID': 'chooser_origin_lifetime_price',
      'productType': 'nonConsumable',
      'hasRevocation': true,
      'revocationDate': 1784563200000,
      'revocationReason': 'other',
    });

    expect(transaction.hasRevocation, isTrue);
    expect(transaction.revocationDate, 1784563200000);
    expect(transaction.revocationReason, 'other');
    expect(transaction.toMap()['revocationReason'], 'other');
  });

  test('accepts legacy numeric revocation reasons without failing', () {
    final transaction = Transaction.fromMap({'revocationReason': 1});

    expect(transaction.revocationReason, '1');
  });
}
