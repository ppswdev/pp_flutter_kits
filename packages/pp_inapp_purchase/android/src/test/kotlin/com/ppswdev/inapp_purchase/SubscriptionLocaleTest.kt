package com.ppswdev.inapp_purchase

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

internal class SubscriptionLocaleTest {
    @Test
    fun title_normalizesChineseScriptCodes() {
        assertEquals(
            "年度会员",
            SubscriptionLocale.title(
                SubscriptionLocale.PeriodType.YEAR,
                "zh-Hans"
            )
        )
        assertEquals(
            "年度會員",
            SubscriptionLocale.title(
                SubscriptionLocale.PeriodType.YEAR,
                "zh_TW"
            )
        )
    }

    @Test
    fun buttonText_matchesStoreKitCopy() {
        assertEquals(
            "Start Free Trial",
            SubscriptionLocale.buttonText(
                SubscriptionLocale.ButtonType.FREE_TRIAL,
                "en_US"
            )
        )
        assertEquals(
            "购买终身",
            SubscriptionLocale.buttonText(
                SubscriptionLocale.ButtonType.LIFETIME,
                "zh_Hans"
            )
        )
    }

    @Test
    fun subtitle_usesGooglePlayFormattedPrice() {
        val subtitle =
            SubscriptionLocale.subtitle(
                periodType = SubscriptionLocale.PeriodType.WEEK,
                languageCode = "en",
                basePrice =
                    SubscriptionLocale.Price(
                        amountMicros = 6990000,
                        currencyCode = "USD",
                        formattedPrice = "$6.99"
                    ),
                introductoryPrice = null
            )

        assertTrue(subtitle.contains("$6.99/week"))
    }

    @Test
    fun freeTrialSubtitle_includesTrialAndRecurringPrice() {
        val subtitle =
            SubscriptionLocale.subtitle(
                periodType = SubscriptionLocale.PeriodType.YEAR,
                languageCode = "en",
                basePrice =
                    SubscriptionLocale.Price(
                        amountMicros = 39990000,
                        currencyCode = "USD",
                        formattedPrice = "$39.99"
                    ),
                introductoryPrice =
                    SubscriptionLocale.IntroductoryPrice(
                        price =
                            SubscriptionLocale.Price(
                                amountMicros = 0,
                                currencyCode = "USD",
                                formattedPrice = "$0.00"
                            ),
                        periodCount = 7,
                        periodUnit = "day",
                        billingCycleCount = 1,
                        buttonType = SubscriptionLocale.ButtonType.FREE_TRIAL
                    )
            )

        assertTrue(subtitle.contains("Free for 7 days"))
        assertTrue(subtitle.contains("$39.99/year"))
    }
}
