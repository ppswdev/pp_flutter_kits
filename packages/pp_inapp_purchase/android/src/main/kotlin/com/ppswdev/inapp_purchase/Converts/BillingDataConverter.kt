package com.ppswdev.inapp_purchase

import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import java.util.Locale

/**
 * Isolates conversion from Google Play Billing models to the existing Flutter API maps.
 *
 * This class also owns deterministic subscription-offer selection so product rendering and
 * launchBillingFlow always use the same eligible offer.
 */
internal class BillingDataConverter(
    private val packageName: String
) {
    private var configuredProductIds = emptyList<String>()
    private var configuredLifetimeIds = emptySet<String>()
    private var autoSortProducts = true

    fun configure(
        productIds: List<String>,
        lifetimeIds: Set<String>,
        autoSortProducts: Boolean
    ) {
        configuredProductIds = productIds
        configuredLifetimeIds = lifetimeIds
        this.autoSortProducts = autoSortProducts
    }

    fun productMap(details: ProductDetails): Map<String, Any?> {
        val subscriptionOffer = selectedSubscriptionOffer(details)
        val basePhase = subscriptionOffer?.pricingPhases?.pricingPhaseList?.lastOrNull()
        val oneTimeOffer = details.oneTimePurchaseOfferDetailsList?.firstOrNull()
        val priceMicros = basePhase?.priceAmountMicros ?: oneTimeOffer?.priceAmountMicros
        val displayPrice = basePhase?.formattedPrice ?: oneTimeOffer?.formattedPrice
        val isLifetime = isLifetimeProduct(details.productId)

        return mapOf(
            "id" to details.productId,
            "displayName" to details.title,
            "description" to details.description,
            "price" to priceMicros?.toPriceDouble(),
            "displayPrice" to displayPrice,
            "type" to if (isLifetime) "nonConsumable" else "autoRenewable",
            "isFamilyShareable" to false,
            "jsonRepresentation" to details.toString(),
            "subscription" to if (isLifetime) null else subscriptionMap(details)
        )
    }

    fun transactionMap(
        purchase: Purchase,
        productDetailsById: Map<String, ProductDetails>,
        entitlementLeaseExpiryByToken: Map<String, Long>
    ): Map<String, Any?> {
        val productId = primaryProductId(purchase)
        val details = productId?.let { productDetailsById[it] }
        val isLifetime = productId != null && isLifetimeProduct(productId)
        // This is a bounded client cache lease, not Google Play's authoritative expiry time.
        val expirationDate =
            if (isLifetime) {
                null
            } else {
                entitlementLeaseExpiryByToken[purchase.purchaseToken]
            }
        return mapOf(
            "id" to (purchase.orderId ?: purchase.purchaseToken),
            "productID" to productId,
            "productType" to if (isLifetime) "nonConsumable" else "autoRenewable",
            "ownershipType" to "purchased",
            "price" to details?.let(::priceMicros)?.toPriceDouble(),
            "currency" to details?.let(::currency),
            "originalID" to purchase.purchaseToken,
            "originalPurchaseDate" to purchase.purchaseTime,
            "purchaseDate" to purchase.purchaseTime,
            "purchasedQuantity" to purchase.quantity,
            "purchaseReason" to "purchase",
            "subscriptionGroupID" to details?.let(::selectedSubscriptionOffer)?.basePlanId,
            "expirationDate" to expirationDate,
            "isUpgraded" to false,
            "hasRevocation" to false,
            "revocationDate" to null,
            "revocationReason" to null,
            "environment" to "Android",
            "appAccountToken" to purchase.accountIdentifiers?.obfuscatedAccountId,
            "appBundleID" to packageName,
            "appTransactionID" to purchase.purchaseToken,
            "signedDate" to purchase.purchaseTime,
            "storefrontId" to null,
            "storefrontCountryCode" to null,
            "storefrontCurrency" to details?.let(::currency),
            "webOrderLineItemID" to null,
            "deviceVerificationNonce" to null,
            "deviceVerification" to null,
            "offer" to null,
            "isSubscribedButFreeTrailCancelled" to false
        )
    }

    fun orderedProducts(productDetailsById: Map<String, ProductDetails>): List<ProductDetails> {
        if (!autoSortProducts) {
            return configuredProductIds.mapNotNull { productDetailsById[it] }
        }
        return productDetailsById.values.sortedWith(
            compareBy<ProductDetails> { isLifetimeProduct(it.productId) }
                .thenBy { priceMicros(it) ?: Long.MAX_VALUE }
                .thenBy {
                    configuredProductIds
                        .indexOf(it.productId)
                        .takeIf { index -> index >= 0 }
                        ?: Int.MAX_VALUE
                }
        )
    }

    fun containsConfiguredProduct(purchase: Purchase): Boolean =
        purchase.products.any(configuredProductIds::contains)

    fun primaryProductId(purchase: Purchase): String? =
        purchase.products.firstOrNull(configuredProductIds::contains)
            ?: purchase.products.firstOrNull()

    fun isLifetimePurchase(purchase: Purchase): Boolean =
        purchase.products.any(configuredLifetimeIds::contains)

    fun isLifetimeProduct(productId: String?): Boolean =
        productId != null && configuredLifetimeIds.contains(productId)

    fun hasIntroductoryOffer(details: ProductDetails): Boolean =
        details.subscriptionOfferDetails
            ?.any { offer ->
                offer.offerId != null && offer.pricingPhases.pricingPhaseList.size > 1
            }
            ?: false

    fun selectedSubscriptionOffer(
        details: ProductDetails
    ): ProductDetails.SubscriptionOfferDetails? =
        details.subscriptionOfferDetails
            ?.sortedWith(
                compareBy<ProductDetails.SubscriptionOfferDetails> { offer ->
                    when {
                        hasFreeTrialPhase(offer) -> 0
                        offer.offerId != null -> 1
                        else -> 2
                    }
                }.thenBy { it.basePlanId }
                    .thenBy { it.offerId.orEmpty() }
            )
            ?.firstOrNull()

    fun selectedOfferToken(details: ProductDetails): String? {
        val subscriptionToken = selectedSubscriptionOffer(details)?.offerToken
        if (!subscriptionToken.isNullOrBlank()) return subscriptionToken
        return details.oneTimePurchaseOfferDetailsList?.firstOrNull()?.offerToken
    }

    fun selectedButtonType(details: ProductDetails): SubscriptionLocale.ButtonType {
        val phases =
            selectedSubscriptionOffer(details)
                ?.pricingPhases
                ?.pricingPhaseList
                .orEmpty()
        if (phases.size <= 1) {
            return SubscriptionLocale.ButtonType.STANDARD
        }
        return when (paymentMode(phases.first())) {
            "freeTrial" -> SubscriptionLocale.ButtonType.FREE_TRIAL
            "payUpFront" -> SubscriptionLocale.ButtonType.PAY_UP_FRONT
            "payAsYouGo" -> SubscriptionLocale.ButtonType.PAY_AS_YOU_GO
            else -> SubscriptionLocale.ButtonType.STANDARD
        }
    }

    fun localizedSubtitle(
        details: ProductDetails,
        periodType: SubscriptionLocale.PeriodType,
        languageCode: String?
    ): String {
        if (isLifetimeProduct(details.productId)) {
            return SubscriptionLocale.subtitle(periodType, languageCode, null, null)
        }
        val phases =
            selectedSubscriptionOffer(details)
                ?.pricingPhases
                ?.pricingPhaseList
                .orEmpty()
        val basePhase = phases.lastOrNull() ?: return details.description
        val basePrice =
            SubscriptionLocale.Price(
                amountMicros = basePhase.priceAmountMicros,
                currencyCode = basePhase.priceCurrencyCode,
                formattedPrice = basePhase.formattedPrice
            )
        val introPhase = phases.firstOrNull().takeIf { phases.size > 1 }
        val introductoryPrice =
            introPhase?.let { phase ->
                val period = parseBillingPeriod(phase.billingPeriod)
                SubscriptionLocale.IntroductoryPrice(
                    price =
                        SubscriptionLocale.Price(
                            amountMicros = phase.priceAmountMicros,
                            currencyCode = phase.priceCurrencyCode,
                            formattedPrice = phase.formattedPrice
                        ),
                    periodCount = period.first ?: 1,
                    periodUnit = period.second ?: "unknown",
                    billingCycleCount = phase.billingCycleCount,
                    buttonType = selectedButtonType(details)
                )
            }
        return SubscriptionLocale.subtitle(
            periodType = periodType,
            languageCode = languageCode,
            basePrice = basePrice,
            introductoryPrice = introductoryPrice
        )
    }

    fun priceMicros(details: ProductDetails): Long? {
        val subscriptionPrice =
            selectedSubscriptionOffer(details)
                ?.pricingPhases
                ?.pricingPhaseList
                ?.lastOrNull()
                ?.priceAmountMicros
        return subscriptionPrice
            ?: details.oneTimePurchaseOfferDetailsList?.firstOrNull()?.priceAmountMicros
    }

    fun currency(details: ProductDetails): String? {
        val subscriptionCurrency =
            selectedSubscriptionOffer(details)
                ?.pricingPhases
                ?.pricingPhaseList
                ?.lastOrNull()
                ?.priceCurrencyCode
        return subscriptionCurrency
            ?: details.oneTimePurchaseOfferDetailsList?.firstOrNull()?.priceCurrencyCode
    }

    private fun subscriptionMap(details: ProductDetails): Map<String, Any?> {
        val offer = selectedSubscriptionOffer(details)
        val basePhase = offer?.pricingPhases?.pricingPhaseList?.lastOrNull()
        val period = parseBillingPeriod(basePhase?.billingPeriod)
        return mapOf(
            "subscriptionGroupID" to offer?.basePlanId,
            "subscriptionPeriodCount" to period.first,
            "subscriptionPeriodUnit" to period.second,
            "introductoryOffer" to introductoryOfferMap(details),
            "promotionalOffers" to emptyList<Map<String, Any?>>(),
            "winBackOffers" to emptyList<Map<String, Any?>>(),
            "isSubscribedButFreeTrailCancelled" to false,
            "isEligibleForIntroOffer" to hasIntroductoryOffer(details)
        )
    }

    private fun introductoryOfferMap(details: ProductDetails): Map<String, Any?>? {
        val offer = selectedSubscriptionOffer(details) ?: return null
        val phases = offer.pricingPhases.pricingPhaseList
        if (phases.size <= 1) return null
        val introPhase = phases.firstOrNull() ?: return null
        val period = parseBillingPeriod(introPhase.billingPeriod)
        return mapOf(
            "id" to offer.offerId,
            "type" to "introductory",
            "offerPeriodCount" to introPhase.billingCycleCount,
            "price" to introPhase.priceAmountMicros.toPriceDouble(),
            "displayPrice" to introPhase.formattedPrice,
            "paymentMode" to paymentMode(introPhase),
            "periodCount" to period.first,
            "periodUnit" to period.second
        )
    }

    private fun hasFreeTrialPhase(offer: ProductDetails.SubscriptionOfferDetails): Boolean =
        offer.pricingPhases.pricingPhaseList.any { phase ->
            phase.priceAmountMicros == 0L &&
                phase.recurrenceMode == ProductDetails.RecurrenceMode.FINITE_RECURRING
        }

    private fun paymentMode(phase: ProductDetails.PricingPhase): String =
        when {
            phase.priceAmountMicros == 0L -> "freeTrial"
            phase.recurrenceMode == ProductDetails.RecurrenceMode.FINITE_RECURRING ->
                "payAsYouGo"
            phase.recurrenceMode == ProductDetails.RecurrenceMode.INFINITE_RECURRING ->
                "payAsYouGo"
            phase.recurrenceMode == ProductDetails.RecurrenceMode.NON_RECURRING ->
                "payUpFront"
            else -> "unknown"
        }

    private fun parseBillingPeriod(period: String?): Pair<Int?, String?> {
        if (period.isNullOrBlank()) return null to "unknown"
        val match = Regex("""P(\d+)([DWMY])""").matchEntire(period)
            ?: return null to "unknown"
        val count = match.groupValues[1].toIntOrNull()
        val unit =
            when (match.groupValues[2].uppercase(Locale.US)) {
                "D" -> "day"
                "W" -> "week"
                "M" -> "month"
                "Y" -> "year"
                else -> "unknown"
            }
        return count to unit
    }

    private fun Long.toPriceDouble(): Double = this / 1_000_000.0
}
