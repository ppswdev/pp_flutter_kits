import 'package:test/test.dart';
import 'package:inapp_purchase/src/product.dart';

void main() {
  test('Product.fromMap should correctly parse Swift JSON structure', () {
    // Swift JSON structure provided by the user
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
        "introductoryOffer": {
          "id": null,
          "displayPrice": "\$0.00",
          "price": 0.0,
          "periodCount": 1,
          "type": "introductory",
          "paymentMode": "freeTrial",
          "period": {"value": 3, "unit": "day"},
        },
        "subscriptionPeriod": {"unit": "week", "value": 1},
        "promotionalOffers": [
          {
            "period": {"value": 1, "unit": "week"},
            "periodCount": 1,
            "id": "free1week",
            "displayPrice": "\$0.00",
            "price": 0.0,
            "type": "promotional",
            "paymentMode": "freeTrial",
          },
          {
            "paymentMode": "payAsYouGo",
            "price": 1.9899999999999998,
            "type": "promotional",
            "id": "payasyougo1week",
            "period": {"value": 1, "unit": "week"},
            "periodCount": 1,
            "displayPrice": "\$1.99",
          },
          {
            "paymentMode": "payUpFront",
            "displayPrice": "\$5.99",
            "periodCount": 1,
            "id": "payupfront1month",
            "period": {"value": 1, "unit": "month"},
            "type": "promotional",
            "price": 5.99,
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
    expect(product.subscription?.subscriptionPeriod, isNotNull);
    expect(product.subscription?.subscriptionPeriod?.value, equals(1));
    expect(
      product.subscription?.subscriptionPeriod?.unit,
      equals(SubscriptionPeriodUnit.week),
    );

    // Verify introductory offer
    expect(product.subscription?.introductoryOffer, isNotNull);
    expect(product.subscription?.introductoryOffer?.id, isNull);
    expect(
      product.subscription?.introductoryOffer?.displayPrice,
      equals("\$0.00"),
    );
    expect(product.subscription?.introductoryOffer?.price, equals(0.0));
    expect(product.subscription?.introductoryOffer?.periodCount, equals(1));
    expect(
      product.subscription?.introductoryOffer?.type,
      equals(SubscriptionOfferType.introductory),
    );
    expect(
      product.subscription?.introductoryOffer?.paymentMode,
      equals(SubscriptionOfferPaymentMode.freeTrial),
    );
    expect(product.subscription?.introductoryOffer?.period, isNotNull);
    expect(product.subscription?.introductoryOffer?.period?.value, equals(3));
    expect(
      product.subscription?.introductoryOffer?.period?.unit,
      equals(SubscriptionPeriodUnit.day),
    );

    // Verify promotional offers
    expect(product.subscription?.promotionalOffers, isNotNull);
    expect(product.subscription?.promotionalOffers?.length, equals(3));

    // First promotional offer
    expect(product.subscription?.promotionalOffers?[0].id, equals("free1week"));
    expect(
      product.subscription?.promotionalOffers?[0].displayPrice,
      equals("\$0.00"),
    );
    expect(product.subscription?.promotionalOffers?[0].price, equals(0.0));
    expect(product.subscription?.promotionalOffers?[0].periodCount, equals(1));
    expect(
      product.subscription?.promotionalOffers?[0].type,
      equals(SubscriptionOfferType.promotional),
    );
    expect(
      product.subscription?.promotionalOffers?[0].paymentMode,
      equals(SubscriptionOfferPaymentMode.freeTrial),
    );
    expect(product.subscription?.promotionalOffers?[0].period, isNotNull);
    expect(
      product.subscription?.promotionalOffers?[0].period?.value,
      equals(1),
    );
    expect(
      product.subscription?.promotionalOffers?[0].period?.unit,
      equals(SubscriptionPeriodUnit.week),
    );

    // Second promotional offer
    expect(
      product.subscription?.promotionalOffers?[1].id,
      equals("payasyougo1week"),
    );
    expect(
      product.subscription?.promotionalOffers?[1].displayPrice,
      equals("\$1.99"),
    );
    expect(
      product.subscription?.promotionalOffers?[1].price,
      equals(1.9899999999999998),
    );
    expect(product.subscription?.promotionalOffers?[1].periodCount, equals(1));
    expect(
      product.subscription?.promotionalOffers?[1].type,
      equals(SubscriptionOfferType.promotional),
    );
    expect(
      product.subscription?.promotionalOffers?[1].paymentMode,
      equals(SubscriptionOfferPaymentMode.payAsYouGo),
    );
    expect(product.subscription?.promotionalOffers?[1].period, isNotNull);
    expect(
      product.subscription?.promotionalOffers?[1].period?.value,
      equals(1),
    );
    expect(
      product.subscription?.promotionalOffers?[1].period?.unit,
      equals(SubscriptionPeriodUnit.week),
    );

    // Third promotional offer
    expect(
      product.subscription?.promotionalOffers?[2].id,
      equals("payupfront1month"),
    );
    expect(
      product.subscription?.promotionalOffers?[2].displayPrice,
      equals("\$5.99"),
    );
    expect(product.subscription?.promotionalOffers?[2].price, equals(5.99));
    expect(product.subscription?.promotionalOffers?[2].periodCount, equals(1));
    expect(
      product.subscription?.promotionalOffers?[2].type,
      equals(SubscriptionOfferType.promotional),
    );
    expect(
      product.subscription?.promotionalOffers?[2].paymentMode,
      equals(SubscriptionOfferPaymentMode.payUpFront),
    );
    expect(product.subscription?.promotionalOffers?[2].period, isNotNull);
    expect(
      product.subscription?.promotionalOffers?[2].period?.value,
      equals(1),
    );
    expect(
      product.subscription?.promotionalOffers?[2].period?.unit,
      equals(SubscriptionPeriodUnit.month),
    );

    // Verify win back offers
    expect(product.subscription?.winBackOffers, isNotNull);
    expect(product.subscription?.winBackOffers?.length, equals(0));
  });
}
