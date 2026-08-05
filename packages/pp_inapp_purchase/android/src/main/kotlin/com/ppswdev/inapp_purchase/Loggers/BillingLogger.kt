package com.ppswdev.inapp_purchase

import android.util.Log
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.Purchase

/** Centralized, filterable and credential-safe Google Play Billing logger. */
internal class BillingLogger {
    var isEnabled: Boolean = false

    fun log(
        stage: String,
        message: String
    ) {
        if (!isEnabled) return
        Log.d(TAG, "$PREFIX[$stage] $message")
    }

    fun billingResultSummary(result: BillingResult): String =
        "responseCode=${result.responseCode} message=${result.debugMessage.take(160)}"

    fun purchaseSummary(
        purchase: Purchase,
        primaryProductId: String?
    ): String =
        "productId=${primaryProductId ?: "unknown"} " +
            "state=${purchaseStateName(purchase.purchaseState)} " +
            "acknowledged=${purchase.isAcknowledged} " +
            "token=${maskedSuffix(purchase.purchaseToken)}"

    fun maskedSuffix(value: String?): String {
        if (value.isNullOrBlank()) return "none"
        return "***${value.takeLast(6)}"
    }

    private fun purchaseStateName(state: Int): String =
        when (state) {
            Purchase.PurchaseState.PENDING -> "PENDING"
            Purchase.PurchaseState.PURCHASED -> "PURCHASED"
            Purchase.PurchaseState.UNSPECIFIED_STATE -> "UNSPECIFIED"
            else -> state.toString()
        }

    private companion object {
        const val TAG = "pp_inapp_purchase"
        const val PREFIX = "[pp_inapp_purchase][NATIVE]"
    }
}
