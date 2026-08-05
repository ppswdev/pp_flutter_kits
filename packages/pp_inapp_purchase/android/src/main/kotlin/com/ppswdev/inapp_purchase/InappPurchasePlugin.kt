package com.ppswdev.inapp_purchase

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Flutter channel entry point for the Android Google Play Billing implementation. */
class InappPurchasePlugin(
    private val platformVersionProvider: () -> String = {
        "Android ${android.os.Build.VERSION.RELEASE}"
    }
) :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var stateEventChannel: EventChannel
    private lateinit var productsEventChannel: EventChannel
    private lateinit var transactionsEventChannel: EventChannel

    private val stateEvents = BillingStreamHandler()
    private val productEvents = BillingStreamHandler()
    private val transactionEvents = BillingStreamHandler()

    private var billingManager: GooglePlayBillingManager? = null
    private var configuredProductIds = emptyList<String>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        channel.setMethodCallHandler(this)

        stateEventChannel = EventChannel(binding.binaryMessenger, STATE_EVENT_CHANNEL)
        productsEventChannel = EventChannel(binding.binaryMessenger, PRODUCTS_EVENT_CHANNEL)
        transactionsEventChannel =
            EventChannel(binding.binaryMessenger, TRANSACTIONS_EVENT_CHANNEL)

        stateEventChannel.setStreamHandler(stateEvents)
        productsEventChannel.setStreamHandler(productEvents)
        transactionsEventChannel.setStreamHandler(transactionEvents)

        billingManager =
            GooglePlayBillingManager(
                context = binding.applicationContext,
                stateEvents = stateEvents,
                productEvents = productEvents,
                transactionEvents = transactionEvents
            )
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> result.success(platformVersionProvider())
            "configure" -> configure(call, result)
            "getAllProducts" ->
                result.success(billingManager?.allProductMaps().orEmpty())
            "getNonConsumablesProducts" ->
                result.success(billingManager?.nonConsumableProductMaps().orEmpty())
            "getConsumablesProducts" -> result.success(emptyList<Map<String, Any?>>())
            "getNonRenewablesProducts" -> result.success(emptyList<Map<String, Any?>>())
            "getAutoRenewablesProducts" ->
                result.success(billingManager?.autoRenewableProductMaps().orEmpty())
            "getProduct" ->
                result.success(
                    billingManager?.productMap(call.argument<String>("productId"))
                )
            "purchase" -> purchase(call, result)
            "completePurchaseVerification" ->
                requireManager(result)?.completePurchaseVerification(
                    purchaseToken = call.argument<String>("purchaseToken"),
                    approved = call.argument<Boolean>("approved") ?: false,
                    emitPurchaseSuccess =
                        call.argument<Boolean>("emitPurchaseSuccess") ?: false,
                    result = result
                )
            "restorePurchases" ->
                requireManager(result)?.restorePurchases(result)
            "refreshPurchases" ->
                requireManager(result)?.refreshPurchases(result)
            "getValidPurchasedTransactions" ->
                result.success(billingManager?.validTransactionMaps().orEmpty())
            "getLatestTransactions" ->
                result.success(billingManager?.latestTransactionMaps().orEmpty())
            "isPurchased" ->
                result.success(
                    billingManager?.isPurchased(call.argument<String>("productId")) ?: false
                )
            "isFamilyShared" -> result.success(false)
            "isEligibleForIntroOffer" ->
                result.success(
                    billingManager?.isEligibleForIntroOffer(
                        call.argument<String>("productId")
                    ) ?: false
                )
            "isSubscribedButFreeTrailCancelled" -> result.success(false)
            "checkSubscriptionStatus" ->
                result.success(billingManager?.hasActiveSubscription() ?: false)
            "getProductForVipTitle" ->
                result.success(
                    billingManager?.vipTitle(
                        productId = call.argument<String>("productId"),
                        periodType = call.argument<String>("periodType"),
                        languageCode = call.argument<String>("langCode")
                    ) ?: ""
                )
            "getProductForVipSubtitle" ->
                result.success(
                    billingManager?.vipSubtitle(
                        productId = call.argument<String>("productId"),
                        periodType = call.argument<String>("periodType"),
                        languageCode = call.argument<String>("langCode")
                    ) ?: ""
                )
            "getProductForVipButtonText" ->
                result.success(
                    billingManager?.vipButtonText(
                        productId = call.argument<String>("productId"),
                        languageCode = call.argument<String>("langCode")
                    ) ?: ""
                )
            "showManageSubscriptionsSheet" ->
                requireManager(result)?.showManageSubscriptions(result)
            "presentOfferCodeRedeemSheet" -> result.success(false)
            "requestReview" -> result.success(null)
            else -> result.notImplemented()
        }
    }

    private fun configure(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        configuredProductIds = call.argument<List<String>>("productIds").orEmpty()
        val manager = requireManager(result) ?: return
        manager.configure(
            configuration =
                BillingConfiguration(
                    productIds = configuredProductIds,
                    lifetimeIds =
                        call
                            .argument<List<String>>("lifetimeIds")
                            .orEmpty()
                            .toSet(),
                    autoSortProducts =
                        call.argument<Boolean>("autoSortProducts") ?: true,
                    showLog = call.argument<Boolean>("showLog") ?: true,
                    deferAcknowledgement =
                        call.argument<Boolean>("deferAndroidAcknowledgement") ?: false
                ),
            result = result
        )
    }

    private fun purchase(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val productId = call.argument<String>("productId")
        val manager = billingManager
        if (manager != null) {
            manager.purchase(productId, result)
            return
        }

        // Keep argument validation available before engine attachment for tests and defensive calls.
        if (productId.isNullOrBlank()) {
            result.error("missing_product_id", "productId is required", null)
            return
        }
        if (!configuredProductIds.contains(productId)) {
            result.error(
                "product_not_configured",
                "Product is not configured: $productId",
                null
            )
            return
        }
        requireManager(result)
    }

    private fun requireManager(result: MethodChannel.Result): GooglePlayBillingManager? {
        val manager = billingManager
        if (manager == null) {
            result.error(
                "billing_setup_failed",
                "Android Billing manager is not attached",
                null
            )
        }
        return manager
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        stateEventChannel.setStreamHandler(null)
        productsEventChannel.setStreamHandler(null)
        transactionsEventChannel.setStreamHandler(null)
        billingManager?.close()
        billingManager = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        billingManager?.attachActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        billingManager?.detachActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        billingManager?.attachActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        billingManager?.detachActivity()
    }

    private companion object {
        const val METHOD_CHANNEL = "inapp_purchase"
        const val STATE_EVENT_CHANNEL = "inapp_purchase/state_events"
        const val PRODUCTS_EVENT_CHANNEL = "inapp_purchase/products_events"
        const val TRANSACTIONS_EVENT_CHANNEL = "inapp_purchase/transactions_events"
    }
}
