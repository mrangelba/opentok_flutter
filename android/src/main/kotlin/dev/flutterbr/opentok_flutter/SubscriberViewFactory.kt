package dev.flutterbr.opentok_flutter

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class SubscriberViewFactory(private var methodCallHandler: MethodCallHandlerImpl?) :
        PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        // Return the view
        return SubscriberView(context, methodCallHandler)
    }
}