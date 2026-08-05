package com.ppswdev.inapp_purchase

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

internal class InappPurchasePluginTest {
    @Test
    fun onMethodCall_getPlatformVersion_returnsExpectedValue() {
        val plugin = InappPurchasePlugin { "Android test" }

        val call = MethodCall("getPlatformVersion", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).success("Android test")
    }

    @Test
    fun onMethodCall_purchase_rejectsUnconfiguredProductBeforeBillingFlow() {
        val plugin = InappPurchasePlugin { "Android test" }
        val call = MethodCall(
            "purchase",
            mapOf("productId" to "unknown_product")
        )
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error(
            "product_not_configured",
            "Product is not configured: unknown_product",
            null
        )
        Mockito.verifyNoMoreInteractions(mockResult)
    }
}
