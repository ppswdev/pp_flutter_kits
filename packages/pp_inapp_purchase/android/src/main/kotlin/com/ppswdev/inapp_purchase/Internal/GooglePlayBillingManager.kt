package com.ppswdev.inapp_purchase

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicInteger

internal data class BillingConfiguration(
    val productIds: List<String>,
    val lifetimeIds: Set<String>,
    val autoSortProducts: Boolean,
    val showLog: Boolean,
    val deferAcknowledgement: Boolean
)

/**
 * Owns the Google Play Billing lifecycle, product queries, purchases and entitlement snapshots.
 *
 * Flutter channels stay in [InappPurchasePlugin]; all BillingClient behavior is encapsulated here.
 */
internal class GooglePlayBillingManager(
    context: Context,
    private val stateEvents: BillingStreamHandler,
    private val productEvents: BillingStreamHandler,
    private val transactionEvents: BillingStreamHandler
) : PurchasesUpdatedListener {
    private val appContext = context.applicationContext
    private val logger = BillingLogger()
    private val converter = BillingDataConverter(appContext.packageName)

    private var activity: Activity? = null
    private var billingClient: BillingClient? = null
    private var connecting = false
    private val pendingReadyActions = mutableListOf<PendingReadyAction>()

    private var configuredProductIds = emptyList<String>()
    private var configuredLifetimeIds = emptySet<String>()
    private var deferAcknowledgement = false

    private val productDetailsById = linkedMapOf<String, ProductDetails>()
    private val validPurchasesByToken = linkedMapOf<String, Purchase>()
    private val latestPurchasesByToken = linkedMapOf<String, Purchase>()
    private val entitlementLeaseExpiryByToken = linkedMapOf<String, Long>()

    private data class PendingReadyAction(
        val onReady: () -> Unit,
        val onError: (BillingResult) -> Unit
    )

    fun configure(
        configuration: BillingConfiguration,
        result: MethodChannel.Result
    ) {
        configuredProductIds = configuration.productIds
        configuredLifetimeIds = configuration.lifetimeIds
        deferAcknowledgement = configuration.deferAcknowledgement
        converter.configure(
            productIds = configuration.productIds,
            lifetimeIds = configuration.lifetimeIds,
            autoSortProducts = configuration.autoSortProducts
        )
        logger.isEnabled = configuration.showLog
        logFlow(
            "CONFIG",
            "productIds=$configuredProductIds lifetimeIds=$configuredLifetimeIds " +
                "deferAcknowledgement=$deferAcknowledgement"
        )
        ensureReady(result) {
            queryAllProducts { billingResult ->
                logFlow("CONFIG", "query products ${resultSummary(billingResult)}")
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    refreshPurchasesInternal(sendEvent = true) { refreshResult ->
                        logFlow(
                            "CONFIG",
                            "initial purchase refresh ${resultSummary(refreshResult)}"
                        )
                        if (refreshResult.responseCode == BillingClient.BillingResponseCode.OK) {
                            result.success(null)
                        } else {
                            result.error(
                                "query_purchases_failed",
                                refreshResult.debugMessage,
                                refreshResult.responseCode
                            )
                        }
                    }
                } else {
                    result.error(
                        "query_products_failed",
                        billingResult.debugMessage,
                        billingResult.responseCode
                    )
                }
            }
        }
    }

    fun productMap(productId: String?): Map<String, Any?>? =
        productId
            ?.let(productDetailsById::get)
            ?.let(converter::productMap)

    fun allProductMaps(): List<Map<String, Any?>> =
        orderedProductDetails().map(converter::productMap)

    fun autoRenewableProductMaps(): List<Map<String, Any?>> =
        orderedProductDetails()
            .filterNot { converter.isLifetimeProduct(it.productId) }
            .map(converter::productMap)

    fun nonConsumableProductMaps(): List<Map<String, Any?>> =
        orderedProductDetails()
            .filter { converter.isLifetimeProduct(it.productId) }
            .map(converter::productMap)

    fun validTransactionMaps(): List<Map<String, Any?>> =
        validPurchasesByToken.values.map(::transactionMap)

    fun latestTransactionMaps(): List<Map<String, Any?>> =
        latestPurchasesByToken.values.map(::transactionMap)

    fun isPurchased(productId: String?): Boolean =
        validPurchasesByToken.values.any { purchase ->
            purchase.products.contains(productId)
        }

    fun isEligibleForIntroOffer(productId: String?): Boolean =
        productId
            ?.let(productDetailsById::get)
            ?.let(converter::hasIntroductoryOffer)
            ?: false

    fun hasActiveSubscription(): Boolean =
        validPurchasesByToken.values.any { purchase ->
            !converter.isLifetimePurchase(purchase)
        }

    fun vipTitle(
        productId: String?,
        periodType: String?,
        languageCode: String?
    ): String =
        if (productId != null && productDetailsById.containsKey(productId)) {
            SubscriptionLocale.title(
                SubscriptionLocale.periodType(periodType),
                languageCode
            )
        } else {
            ""
        }

    fun vipSubtitle(
        productId: String?,
        periodType: String?,
        languageCode: String?
    ): String {
        val details = productId?.let(productDetailsById::get) ?: return ""
        return converter.localizedSubtitle(
            details = details,
            periodType = SubscriptionLocale.periodType(periodType),
            languageCode = languageCode
        )
    }

    fun vipButtonText(
        productId: String?,
        languageCode: String?
    ): String {
        val details = productId?.let(productDetailsById::get) ?: return ""
        val buttonType =
            if (converter.isLifetimeProduct(productId)) {
                SubscriptionLocale.ButtonType.LIFETIME
            } else {
                converter.selectedButtonType(details)
            }
        return SubscriptionLocale.buttonText(buttonType, languageCode)
    }

    fun purchase(
        productId: String?,
        result: MethodChannel.Result
    ) {
        logFlow("PURCHASE", "request productId=${productId ?: "none"}")
        if (productId.isNullOrBlank()) {
            logFlow("PURCHASE", "rejected reason=missing_product_id")
            result.error("missing_product_id", "productId is required", null)
            return
        }
        if (!configuredProductIds.contains(productId)) {
            logFlow("PURCHASE", "rejected productId=$productId reason=not_configured")
            result.error(
                "product_not_configured",
                "Product is not configured: $productId",
                null
            )
            return
        }

        val currentActivity = activity
        if (currentActivity == null) {
            logFlow("PURCHASE", "rejected productId=$productId reason=activity_unavailable")
            result.error("activity_unavailable", "Android Activity is not attached", null)
            return
        }

        ensureReady(result) {
            val productType =
                if (configuredLifetimeIds.contains(productId)) {
                    BillingClient.ProductType.INAPP
                } else {
                    BillingClient.ProductType.SUBS
                }
            logFlow("PURCHASE", "query latest productId=$productId type=$productType")
            // Re-query immediately before launchBillingFlow so details and offer token stay aligned.
            queryProducts(listOf(productId), productType) { queryResult ->
                if (queryResult.responseCode != BillingClient.BillingResponseCode.OK) {
                    logFlow(
                        "PURCHASE",
                        "query failed productId=$productId ${resultSummary(queryResult)}"
                    )
                    result.error(
                        "query_product_failed",
                        queryResult.debugMessage,
                        queryResult.responseCode
                    )
                    return@queryProducts
                }
                val details = productDetailsById[productId]
                if (details == null) {
                    logFlow("PURCHASE", "rejected productId=$productId reason=details_missing")
                    result.error("product_not_found", "Product not found: $productId", null)
                    return@queryProducts
                }

                val selectedOffer = converter.selectedSubscriptionOffer(details)
                logFlow(
                    "PURCHASE",
                    "details ready productId=$productId type=$productType " +
                        "basePlanId=${selectedOffer?.basePlanId ?: "none"} " +
                        "offerId=${selectedOffer?.offerId ?: "none"}"
                )
                sendState("purchasing", productId = productId)
                val paramsBuilder =
                    BillingFlowParams.ProductDetailsParams
                        .newBuilder()
                        .setProductDetails(details)
                converter.selectedOfferToken(details)?.let(paramsBuilder::setOfferToken)

                val billingFlowParams =
                    BillingFlowParams
                        .newBuilder()
                        .setProductDetailsParamsList(listOf(paramsBuilder.build()))
                        .build()
                val billingResult =
                    billingClient?.launchBillingFlow(currentActivity, billingFlowParams)
                logFlow(
                    "PURCHASE",
                    "launchBillingFlow productId=$productId " +
                        (billingResult?.let(::resultSummary) ?: "result=unavailable")
                )
                if (billingResult?.responseCode == BillingClient.BillingResponseCode.OK) {
                    result.success(null)
                } else {
                    sendState(
                        "purchaseFailed",
                        productId = productId,
                        error = billingResult?.debugMessage ?: "Unable to launch billing flow"
                    )
                    result.error(
                        "launch_billing_failed",
                        billingResult?.debugMessage ?: "Unable to launch billing flow",
                        billingResult?.responseCode
                    )
                }
            }
        }
    }

    fun restorePurchases(result: MethodChannel.Result) {
        sendState("restoringPurchases")
        ensureReady(result) {
            refreshPurchasesInternal(sendEvent = true) { billingResult ->
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    sendState("restorePurchasesSuccess")
                    result.success(null)
                } else {
                    sendState("restorePurchasesFailed", error = billingResult.debugMessage)
                    result.error(
                        "restore_purchases_failed",
                        billingResult.debugMessage,
                        billingResult.responseCode
                    )
                }
            }
        }
    }

    fun refreshPurchases(result: MethodChannel.Result) {
        ensureReady(result) {
            refreshPurchasesInternal(sendEvent = true) { billingResult ->
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    result.success(null)
                } else {
                    result.error(
                        "query_purchases_failed",
                        billingResult.debugMessage,
                        billingResult.responseCode
                    )
                }
            }
        }
    }

    /**
     * Completes acknowledgement only after Flutter reports an authoritative backend decision.
     *
     * A rejected or unavailable verification must not acknowledge or grant the purchase.
     */
    fun completePurchaseVerification(
        purchaseToken: String?,
        approved: Boolean,
        emitPurchaseSuccess: Boolean,
        result: MethodChannel.Result
    ) {
        if (purchaseToken.isNullOrBlank()) {
            result.error("missing_purchase_token", "purchaseToken is required", null)
            return
        }
        val purchase =
            validPurchasesByToken[purchaseToken] ?: latestPurchasesByToken[purchaseToken]
        if (purchase == null) {
            result.error(
                "purchase_not_found",
                "No current purchase matches the supplied token",
                null
            )
            return
        }
        if (!approved) {
            validPurchasesByToken.remove(purchaseToken)
            sendTransactionSnapshot()
            sendState(
                "purchaseFailed",
                productId = converter.primaryProductId(purchase),
                error = "Backend purchase verification rejected"
            )
            result.success(null)
            return
        }

        acknowledgePurchases(listOf(purchase)) { acknowledgeResult ->
            if (acknowledgeResult.responseCode != BillingClient.BillingResponseCode.OK) {
                result.error(
                    "acknowledge_purchase_failed",
                    acknowledgeResult.debugMessage,
                    acknowledgeResult.responseCode
                )
                return@acknowledgePurchases
            }
            validPurchasesByToken[purchase.purchaseToken] = purchase
            latestPurchasesByToken[purchase.purchaseToken] = purchase
            if (emitPurchaseSuccess) {
                sendState(
                    "purchaseSuccess",
                    productId = converter.primaryProductId(purchase),
                    transaction = transactionMap(purchase)
                )
            }
            sendTransactionSnapshot()
            result.success(null)
        }
    }

    fun showManageSubscriptions(result: MethodChannel.Result) {
        try {
            val uri =
                Uri.parse(
                    "https://play.google.com/store/account/subscriptions" +
                        "?package=${appContext.packageName}"
                )
            val intent =
                Intent(Intent.ACTION_VIEW, uri).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            appContext.startActivity(intent)
            result.success(null)
        } catch (error: Exception) {
            result.error("open_subscriptions_failed", error.message, null)
        }
    }

    fun attachActivity(activity: Activity) {
        this.activity = activity
    }

    fun detachActivity() {
        activity = null
    }

    fun close() {
        pendingReadyActions.clear()
        billingClient?.endConnection()
        billingClient = null
        connecting = false
        activity = null
    }

    override fun onPurchasesUpdated(
        billingResult: BillingResult,
        purchases: MutableList<Purchase>?
    ) {
        logFlow(
            "CALLBACK",
            "onPurchasesUpdated ${resultSummary(billingResult)} " +
                "count=${purchases.orEmpty().size}"
        )
        purchases.orEmpty().forEach { purchase ->
            logFlow("CALLBACK", purchaseSummary(purchase))
        }
        when (billingResult.responseCode) {
            BillingClient.BillingResponseCode.OK -> handleSuccessfulPurchaseCallback(purchases)
            BillingClient.BillingResponseCode.USER_CANCELED -> {
                logFlow("CALLBACK", "user cancelled purchase flow")
                sendState("purchaseCancelled")
            }
            BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED -> {
                logFlow("CALLBACK", "item already owned; refresh current purchases")
                refreshPurchasesInternal(sendEvent = true)
            }
            else -> {
                logFlow("CALLBACK", "purchase failed ${resultSummary(billingResult)}")
                sendState(
                    "purchaseFailed",
                    error = billingResult.debugMessage.ifBlank {
                        "Billing response ${billingResult.responseCode}"
                    }
                )
            }
        }
    }

    private fun handleSuccessfulPurchaseCallback(purchases: List<Purchase>?) {
        val purchased =
            purchases
                .orEmpty()
                .filter { purchase ->
                    when (purchase.purchaseState) {
                        Purchase.PurchaseState.PENDING -> {
                            logFlow("CALLBACK", "pending ${purchaseSummary(purchase)}")
                            sendState(
                                "purchasePending",
                                productId = converter.primaryProductId(purchase)
                            )
                            false
                        }
                        Purchase.PurchaseState.PURCHASED -> true
                        else -> false
                    }
                }
                .filter(converter::containsConfiguredProduct)

        logFlow("CALLBACK", "purchased configured count=${purchased.size}")
        if (deferAcknowledgement) {
            purchased.forEach { purchase ->
                validPurchasesByToken[purchase.purchaseToken] = purchase
                latestPurchasesByToken[purchase.purchaseToken] = purchase
                logFlow(
                    "VERIFY",
                    "backend verification required ${purchaseSummary(purchase)}"
                )
                sendState(
                    "purchaseVerificationRequired",
                    productId = converter.primaryProductId(purchase),
                    transaction = transactionMap(purchase)
                )
            }
            sendTransactionSnapshot()
            return
        }
        acknowledgePurchases(purchased) { acknowledgeResult ->
            logFlow("ACK", "purchase callback ${resultSummary(acknowledgeResult)}")
            if (acknowledgeResult.responseCode != BillingClient.BillingResponseCode.OK) {
                sendState(
                    "purchaseFailed",
                    productId = purchased.firstOrNull()?.let(converter::primaryProductId),
                    error = acknowledgeResult.debugMessage
                )
                return@acknowledgePurchases
            }

            val leaseExpiry = System.currentTimeMillis() + CLIENT_ENTITLEMENT_LEASE_MS
            purchased.forEach { purchase ->
                validPurchasesByToken[purchase.purchaseToken] = purchase
                latestPurchasesByToken[purchase.purchaseToken] = purchase
                if (!converter.isLifetimePurchase(purchase)) {
                    entitlementLeaseExpiryByToken[purchase.purchaseToken] = leaseExpiry
                }
                logFlow("ENTITLEMENT", "purchase accepted ${purchaseSummary(purchase)}")
                sendState(
                    "purchaseSuccess",
                    productId = converter.primaryProductId(purchase),
                    transaction = transactionMap(purchase)
                )
            }
            refreshPurchasesInternal(sendEvent = true)
        }
    }

    private fun ensureReady(
        result: MethodChannel.Result,
        action: () -> Unit
    ) {
        val client = billingClient ?: createBillingClient()
        if (client.isReady) {
            logFlow("CONNECTION", "BillingClient already ready")
            action()
            return
        }

        logFlow(
            "CONNECTION",
            "queue action pending=${pendingReadyActions.size + 1} connecting=$connecting"
        )
        pendingReadyActions.add(
            PendingReadyAction(
                onReady = action,
                onError = { billingResult ->
                    result.error(
                        "billing_setup_failed",
                        billingResult.debugMessage,
                        billingResult.responseCode
                    )
                }
            )
        )
        if (connecting) return

        connecting = true
        logFlow("CONNECTION", "start BillingClient connection")
        client.startConnection(
            object : BillingClientStateListener {
                override fun onBillingSetupFinished(billingResult: BillingResult) {
                    connecting = false
                    logFlow(
                        "CONNECTION",
                        "setup finished ${resultSummary(billingResult)} " +
                            "queued=${pendingReadyActions.size}"
                    )
                    val actions = pendingReadyActions.toList()
                    pendingReadyActions.clear()
                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                        actions.forEach { it.onReady.invoke() }
                    } else {
                        actions.forEach { it.onError.invoke(billingResult) }
                    }
                }

                override fun onBillingServiceDisconnected() {
                    connecting = false
                    logFlow("CONNECTION", "Billing service disconnected")
                }
            }
        )
    }

    private fun createBillingClient(): BillingClient {
        val client =
            BillingClient
                .newBuilder(appContext)
                .setListener(this)
                .enablePendingPurchases(
                    PendingPurchasesParams
                        .newBuilder()
                        .enableOneTimeProducts()
                        .build()
                )
                .build()
        billingClient = client
        return client
    }

    private fun queryAllProducts(onComplete: (BillingResult) -> Unit) {
        productDetailsById.clear()
        sendState("loadingProducts")

        val subscriptionIds = configuredProductIds.filterNot(configuredLifetimeIds::contains)
        val oneTimeIds = configuredProductIds.filter(configuredLifetimeIds::contains)
        logFlow(
            "PRODUCTS",
            "query all subscriptions=$subscriptionIds oneTime=$oneTimeIds"
        )
        val pending = AtomicInteger(0)
        var finalResult: BillingResult? = null

        fun finish(result: BillingResult) {
            if (finalResult == null || result.responseCode != BillingClient.BillingResponseCode.OK) {
                finalResult = result
            }
            if (pending.decrementAndGet() == 0) {
                val ordered = orderedProductDetails()
                productDetailsById.clear()
                ordered.forEach { productDetailsById[it.productId] = it }
                productEvents.send(ordered.map(converter::productMap))
                sendState("productsLoaded")
                logFlow(
                    "PRODUCTS",
                    "query all complete count=${ordered.size} " +
                        "ids=${ordered.map { it.productId }}"
                )
                onComplete(finalResult ?: result)
            }
        }

        if (subscriptionIds.isNotEmpty()) {
            pending.incrementAndGet()
            queryProducts(subscriptionIds, BillingClient.ProductType.SUBS, ::finish)
        }

        if (oneTimeIds.isNotEmpty()) {
            pending.incrementAndGet()
            queryProducts(oneTimeIds, BillingClient.ProductType.INAPP, ::finish)
        }

        if (pending.get() == 0) {
            productEvents.send(emptyList<Map<String, Any?>>())
            sendState("productsLoaded")
            onComplete(okBillingResult())
        }
    }

    private fun queryProducts(
        productIds: List<String>,
        productType: String,
        onComplete: (BillingResult) -> Unit
    ) {
        logFlow("PRODUCTS", "query type=$productType ids=$productIds")
        productIds.forEach(productDetailsById::remove)
        val products =
            productIds.map { productId ->
                QueryProductDetailsParams.Product
                    .newBuilder()
                    .setProductId(productId)
                    .setProductType(productType)
                    .build()
            }
        val params =
            QueryProductDetailsParams
                .newBuilder()
                .setProductList(products)
                .build()

        billingClient?.queryProductDetailsAsync(params) { billingResult, queryResult ->
            logFlow(
                "PRODUCTS",
                "query result type=$productType ${resultSummary(billingResult)} " +
                    "fetched=${queryResult.productDetailsList.size} " +
                    "unfetched=${queryResult.unfetchedProductList.size}"
            )
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                queryResult.productDetailsList.forEach { details ->
                    productDetailsById[details.productId] = details
                }
                queryResult.unfetchedProductList.forEach { unfetched ->
                    logFlow(
                        "PRODUCTS",
                        "Product unavailable: ${unfetched.productId}, " +
                            "status=${unfetched.statusCode}"
                    )
                }
            } else {
                sendState("error", error = billingResult.debugMessage)
            }
            onComplete(billingResult)
        }
    }

    private fun refreshPurchasesInternal(
        sendEvent: Boolean,
        onComplete: ((BillingResult) -> Unit)? = null
    ) {
        logFlow("REFRESH", "start sendEvent=$sendEvent")
        val pending = AtomicInteger(2)
        val purchases = linkedMapOf<String, Purchase>()
        var firstError: BillingResult? = null

        fun finish(
            billingResult: BillingResult,
            list: List<Purchase>
        ) {
            logFlow(
                "REFRESH",
                "partial ${resultSummary(billingResult)} count=${list.size}"
            )
            if (billingResult.responseCode != BillingClient.BillingResponseCode.OK &&
                firstError == null
            ) {
                firstError = billingResult
            }

            list
                .filter(converter::containsConfiguredProduct)
                .forEach { purchase ->
                    when (purchase.purchaseState) {
                        Purchase.PurchaseState.PURCHASED ->
                            purchases[purchase.purchaseToken] = purchase
                        Purchase.PurchaseState.PENDING ->
                            sendState(
                                "purchasePending",
                                productId = converter.primaryProductId(purchase)
                            )
                    }
                }

            if (pending.decrementAndGet() == 0) {
                val queryError = firstError
                if (queryError != null) {
                    // A failed query is unknown state, not an empty entitlement set.
                    sendState("error", error = queryError.debugMessage)
                    onComplete?.invoke(queryError)
                    return
                }

                logFlow("REFRESH", "combined purchased count=${purchases.size}")
                if (deferAcknowledgement) {
                    validPurchasesByToken.clear()
                    validPurchasesByToken.putAll(purchases)
                    purchases.values.forEach { purchase ->
                        latestPurchasesByToken[purchase.purchaseToken] = purchase
                    }
                    if (sendEvent) {
                        sendTransactionSnapshot()
                        sendState("purchasesLoaded")
                    }
                    logFlow(
                        "REFRESH",
                        "complete verificationCandidates=${validPurchasesByToken.size}"
                    )
                    onComplete?.invoke(okBillingResult())
                    return
                }
                acknowledgePurchases(purchases.values.toList()) { acknowledgeResult ->
                    if (acknowledgeResult.responseCode != BillingClient.BillingResponseCode.OK) {
                        sendState("error", error = acknowledgeResult.debugMessage)
                        onComplete?.invoke(acknowledgeResult)
                        return@acknowledgePurchases
                    }

                    val leaseExpiry = System.currentTimeMillis() + CLIENT_ENTITLEMENT_LEASE_MS
                    purchases.values.forEach { purchase ->
                        latestPurchasesByToken[purchase.purchaseToken] = purchase
                        if (!converter.isLifetimePurchase(purchase)) {
                            entitlementLeaseExpiryByToken[purchase.purchaseToken] = leaseExpiry
                        }
                    }
                    // Replace valid purchases only after both queries and acknowledgements pass.
                    validPurchasesByToken.clear()
                    validPurchasesByToken.putAll(purchases)
                    if (sendEvent) {
                        sendTransactionSnapshot()
                        sendState("purchasesLoaded")
                    }
                    logFlow(
                        "REFRESH",
                        "complete valid=${validPurchasesByToken.size} " +
                            "latest=${latestPurchasesByToken.size}"
                    )
                    onComplete?.invoke(okBillingResult())
                }
            }
        }

        queryPurchases(BillingClient.ProductType.SUBS, ::finish)
        queryPurchases(BillingClient.ProductType.INAPP, ::finish)
    }

    private fun queryPurchases(
        productType: String,
        onComplete: (BillingResult, List<Purchase>) -> Unit
    ) {
        logFlow("REFRESH", "query purchases type=$productType")
        val params =
            QueryPurchasesParams
                .newBuilder()
                .setProductType(productType)
                .build()
        billingClient?.queryPurchasesAsync(params) { billingResult, purchases ->
            logFlow(
                "REFRESH",
                "query purchases type=$productType ${resultSummary(billingResult)} " +
                    "count=${purchases.size}"
            )
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                onComplete(billingResult, purchases)
            } else {
                onComplete(billingResult, emptyList())
            }
        } ?: onComplete(
            errorBillingResult(
                BillingClient.BillingResponseCode.SERVICE_DISCONNECTED,
                "Billing client is unavailable"
            ),
            emptyList()
        )
    }

    private fun acknowledgePurchases(
        purchases: List<Purchase>,
        onComplete: (BillingResult) -> Unit
    ) {
        val pendingAcknowledgements =
            purchases.filter { purchase ->
                purchase.purchaseState == Purchase.PurchaseState.PURCHASED &&
                    !purchase.isAcknowledged
            }
        if (pendingAcknowledgements.isEmpty()) {
            logFlow("ACK", "no pending acknowledgement count=${purchases.size}")
            onComplete(okBillingResult())
            return
        }

        logFlow("ACK", "start count=${pendingAcknowledgements.size}")
        val client = billingClient
        if (client == null) {
            onComplete(
                errorBillingResult(
                    BillingClient.BillingResponseCode.SERVICE_DISCONNECTED,
                    "Billing client is unavailable"
                )
            )
            return
        }

        val pending = AtomicInteger(pendingAcknowledgements.size)
        var firstError: BillingResult? = null
        pendingAcknowledgements.forEach { purchase ->
            logFlow("ACK", "request ${purchaseSummary(purchase)}")
            val params =
                AcknowledgePurchaseParams
                    .newBuilder()
                    .setPurchaseToken(purchase.purchaseToken)
                    .build()
            client.acknowledgePurchase(params) { billingResult ->
                logFlow(
                    "ACK",
                    "result productId=${converter.primaryProductId(purchase) ?: "unknown"} " +
                        "token=${logger.maskedSuffix(purchase.purchaseToken)} " +
                        resultSummary(billingResult)
                )
                if (billingResult.responseCode != BillingClient.BillingResponseCode.OK &&
                    firstError == null
                ) {
                    firstError = billingResult
                }
                if (pending.decrementAndGet() == 0) {
                    onComplete(firstError ?: okBillingResult())
                }
            }
        }
    }

    private fun orderedProductDetails(): List<ProductDetails> =
        converter.orderedProducts(productDetailsById)

    private fun transactionMap(purchase: Purchase): Map<String, Any?> =
        converter.transactionMap(
            purchase = purchase,
            productDetailsById = productDetailsById,
            entitlementLeaseExpiryByToken = entitlementLeaseExpiryByToken
        )

    private fun sendTransactionSnapshot() {
        transactionEvents.send(
            mapOf(
                "validTransactions" to validTransactionMaps(),
                "latestTransactions" to latestTransactionMaps()
            )
        )
    }

    private fun sendState(
        type: String,
        productId: String? = null,
        transaction: Map<String, Any?>? = null,
        error: String? = null
    ) {
        val token = transaction?.get("appTransactionID") ?: transaction?.get("originalID")
        logFlow(
            "EVENT",
            "type=$type productId=${productId ?: "none"} " +
                "token=${logger.maskedSuffix(token?.toString())} " +
                "error=${error?.take(160) ?: "none"}"
        )
        val event = mutableMapOf<String, Any?>("type" to type)
        productId?.let { event["productId"] = it }
        transaction?.let { event["transaction"] = it }
        error?.let {
            event["error"] = it
            event["errorMessage"] = it
            event["errorDetail"] = it
        }
        stateEvents.send(event)
    }

    private fun purchaseSummary(purchase: Purchase): String =
        logger.purchaseSummary(
            purchase = purchase,
            primaryProductId = converter.primaryProductId(purchase)
        )

    private fun resultSummary(result: BillingResult): String =
        logger.billingResultSummary(result)

    private fun logFlow(
        stage: String,
        message: String
    ) {
        logger.log(stage, message)
    }

    private fun okBillingResult(): BillingResult =
        BillingResult
            .newBuilder()
            .setResponseCode(BillingClient.BillingResponseCode.OK)
            .build()

    private fun errorBillingResult(
        responseCode: Int,
        message: String
    ): BillingResult =
        BillingResult
            .newBuilder()
            .setResponseCode(responseCode)
            .setDebugMessage(message)
            .build()

    private companion object {
        /**
         * BillingClient does not expose authoritative subscription expiry. While asynchronous
         * backend reconciliation is pending, a successful acknowledged purchase uses a bounded
         * client entitlement lease.
         */
        const val CLIENT_ENTITLEMENT_LEASE_MS = 24L * 60L * 60L * 1000L
    }
}
