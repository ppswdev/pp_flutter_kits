package com.ppswdev.inapp_purchase

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/** Delivers Billing events to Flutter safely on Android's main thread. */
internal class BillingStreamHandler : EventChannel.StreamHandler {
    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }
    private var sink: EventChannel.EventSink? = null

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?
    ) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun send(event: Any) {
        mainHandler.post {
            sink?.success(event)
        }
    }
}
