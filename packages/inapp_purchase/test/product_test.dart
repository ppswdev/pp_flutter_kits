import 'package:test/test.dart';
import 'package:inapp_purchase/src/enums.dart';
import 'package:inapp_purchase/src/product.dart';

void main() {
  test('Product.fromMap should correctly parse Swift JSON structure', () {
    // Updated JSON structure to match product.json format
    final Map<String, dynamic> swiftJson = {
      "displayPrice": "\$9.99",
      "type": "autoRenewable",
      "description": "Weekly VIP of in app",
      "isFamilyShareable": false,
      "displayName": "Weekly VIP InApp",
      "id": "com.ppswdev.store.inapp.weeklyvip",
      "jsonRepresentation":
          "{\"attributes\":{\"description\":{\"standard\":\"Weekly VIP of in app\"},\"icuLocale\":\"en_US@currency=USD\",\"isFamilyShareable\":0,\"kind\":\"Auto-Renewable Subscription\",\"name\":\"Weekly VIP InApp\",\"offerName\":\"com.ppswdev.store.inapp.weeklyvip\",\"offers\":[{\"currencyCode\":\"USD\",\"discounts\":[{\"modeType\":\"FreeTrial\",\"numOfPeriods\":1,\"offerId\":\"free1week\",\"priceFormatted\":\"\$0.00\",\"priceString\":\"0.00\",\"recurringSubscriptionPeriod\":\"P1W\",\"type\":\"AdhocOffer\"},{\"modeType\":\"PayAsYouGo\",\"numOfPeriods\":1,\"offerId\":\"payasyougo1week\",\"priceFormatted\":\"\$1.99\",\"priceString\":\"1.99\",\"recurringSubscriptionPeriod\":\"P1W\",\"type\":\"AdhocOffer\"},{\"modeType\":\"PayUpFront\",\"numOfPeriods\":1,\"offerId\":\"payupfront1month\",\"priceFormatted\":\"\$5.99\",\"priceString\":\"5.99\",\"recurringSubscriptionPeriod\":\"P1M\",\"type\":\"AdhocOffer\"},{\"modeType\":\"FreeTrial\",\"numOfPeriods\":1,\"priceFormatted\":\"\$0.00\",\"priceString\":\"0.00\",\"recurringSubscriptionPeriod\":\"P3D\",\"type\":\"IntroOffer\"}],\"priceFormatted\":\"\$9.99\",\"priceString\":\"9.99\",\"recurringSubscriptionPeriod\":\"P1W\"}],\"subscriptionFamilyId\":\"732E29F2\",\"subscriptionFamilyName\":\"mysubs\",\"subscriptionFamilyRank\":1},\"href\":\"/v1/catalog/usa/in-apps/D7180163\",\"id\":\"D7180163\",\"type\":\"in-apps\"}",
      "price": 9.99,
      "subscription": {
        "subscriptionGroupID": "732E29F2",
        "subscriptionPeriodCount": 1,
        "subscriptionPeriodUnit": "week",
        "introductoryOffer": {
          "id": null,
          "type": "introductory",
          "offerPeriodCount": 1,
          "price": 0.0,
          "displayPrice": "\$0.00",
          "paymentMode": "freeTrial",
          "periodCount": 3,
          "periodUnit": "day",
        },
        "promotionalOffers": [
          {
            "id": "free1week",
            "type": "promotional",
            "offerPeriodCount": 1,
            "price": 0.0,
            "displayPrice": "\$0.00",
            "paymentMode": "freeTrial",
            "periodCount": 1,
            "periodUnit": "week",
          },
          {
            "id": "payasyougo1week",
            "type": "promotional",
            "offerPeriodCount": 1,
            "price": 1.99,
            "displayPrice": "\$1.99",
            "paymentMode": "payAsYouGo",
            "periodCount": 1,
            "periodUnit": "week",
          },
          {
            "id": "payupfront1month",
            "type": "promotional",
            "offerPeriodCount": 1,
            "price": 5.99,
            "displayPrice": "\$5.99",
            "paymentMode": "payUpFront",
            "periodCount": 1,
            "periodUnit": "month",
          },
        ],
        "winBackOffers": [],
      },
    };

    // Try to parse the JSON using Product.fromMap
    final Product product = Product.fromMap(swiftJson);

    // Verify all top-level properties
    expect(product.id, equals("com.ppswdev.store.inapp.weeklyvip"));
    expect(product.displayName, equals("Weekly VIP InApp"));
    expect(product.description, equals("Weekly VIP of in app"));
    expect(product.price, equals(9.99));
    expect(product.displayPrice, equals("\$9.99"));
    expect(product.type, equals("autoRenewable"));
    expect(product.isFamilyShareable, equals(false));
    expect(product.jsonRepresentation, isNotEmpty);

    // Verify subscription properties
    expect(product.subscription, isNotNull);
    expect(product.subscription?.subscriptionGroupID, equals("732E29F2"));

    // Verify subscription period
    expect(product.subscription?.subscriptionPeriodCount, equals(1));
    expect(
      product.subscription?.subscriptionPeriodUnit,
      equals(SubscriptionPeriodUnit.week),
    );

    // Verify introductory offer
    expect(product.subscription?.introductoryOffer, isNotNull);
    expect(product.subscription?.introductoryOffer?.id, isNull);
    expect(
      product.subscription?.introductoryOffer?.type,
      equals(SubscriptionOfferType.introductory),
    );
    expect(
      product.subscription?.introductoryOffer?.offerPeriodCount,
      equals(1),
    );
    expect(product.subscription?.introductoryOffer?.price, equals(0.0));
    expect(
      product.subscription?.introductoryOffer?.displayPrice,
      equals("\$0.00"),
    );
    expect(
      product.subscription?.introductoryOffer?.paymentMode,
      equals(SubscriptionOfferPaymentMode.freeTrial),
    );
    expect(product.subscription?.introductoryOffer?.periodCount, equals(3));
    expect(
      product.subscription?.introductoryOffer?.periodUnit,
      equals(SubscriptionPeriodUnit.day),
    );

    // Verify promotional offers
    expect(product.subscription?.promotionalOffers, isNotNull);
    expect(product.subscription?.promotionalOffers?.length, equals(3));

    // First promotional offer
    expect(product.subscription?.promotionalOffers?[0].id, equals("free1week"));
    expect(
      product.subscription?.promotionalOffers?[0].type,
      equals(SubscriptionOfferType.promotional),
    );
    expect(
      product.subscription?.promotionalOffers?[0].offerPeriodCount,
      equals(1),
    );
    expect(product.subscription?.promotionalOffers?[0].price, equals(0.0));
    expect(
      product.subscription?.promotionalOffers?[0].displayPrice,
      equals("\$0.00"),
    );
    expect(
      product.subscription?.promotionalOffers?[0].paymentMode,
      equals(SubscriptionOfferPaymentMode.freeTrial),
    );
    expect(product.subscription?.promotionalOffers?[0].periodCount, equals(1));
    expect(
      product.subscription?.promotionalOffers?[0].periodUnit,
      equals(SubscriptionPeriodUnit.week),
    );

    // Second promotional offer
    expect(
      product.subscription?.promotionalOffers?[1].id,
      equals("payasyougo1week"),
    );
    expect(
      product.subscription?.promotionalOffers?[1].type,
      equals(SubscriptionOfferType.promotional),
    );
    expect(
      product.subscription?.promotionalOffers?[1].offerPeriodCount,
      equals(1),
    );
    expect(product.subscription?.promotionalOffers?[1].price, equals(1.99));
    expect(
      product.subscription?.promotionalOffers?[1].displayPrice,
      equals("\$1.99"),
    );
    expect(
      product.subscription?.promotionalOffers?[1].paymentMode,
      equals(SubscriptionOfferPaymentMode.payAsYouGo),
    );
    expect(product.subscription?.promotionalOffers?[1].periodCount, equals(1));
    expect(
      product.subscription?.promotionalOffers?[1].periodUnit,
      equals(SubscriptionPeriodUnit.week),
    );

    // Third promotional offer
    expect(
      product.subscription?.promotionalOffers?[2].id,
      equals("payupfront1month"),
    );
    expect(
      product.subscription?.promotionalOffers?[2].type,
      equals(SubscriptionOfferType.promotional),
    );
    expect(
      product.subscription?.promotionalOffers?[2].offerPeriodCount,
      equals(1),
    );
    expect(product.subscription?.promotionalOffers?[2].price, equals(5.99));
    expect(
      product.subscription?.promotionalOffers?[2].displayPrice,
      equals("\$5.99"),
    );
    expect(
      product.subscription?.promotionalOffers?[2].paymentMode,
      equals(SubscriptionOfferPaymentMode.payUpFront),
    );
    expect(product.subscription?.promotionalOffers?[2].periodCount, equals(1));
    expect(
      product.subscription?.promotionalOffers?[2].periodUnit,
      equals(SubscriptionPeriodUnit.month),
    );

    // Verify win back offers
    expect(product.subscription?.winBackOffers, isNotNull);
    expect(product.subscription?.winBackOffers?.length, equals(0));
  });
}
