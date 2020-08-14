package dev.flutterbr.opentok_flutter

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import io.flutter.plugin.platform.PlatformView

class SubscriberView(
        context: Context,
        private var methodCallHandler: MethodCallHandlerImpl?) : PlatformView {

    private var openTokView: FrameLayout = FrameLayout(context)
    private var screenHeight: Int = LinearLayout.LayoutParams.MATCH_PARENT
    private var screenWidth: Int = LinearLayout.LayoutParams.MATCH_PARENT

    init {
        openTokView.layoutParams = LinearLayout.LayoutParams(screenWidth, screenHeight)
        openTokView.setBackgroundColor(Color.TRANSPARENT)
    }

    override fun getView(): View {
        return methodCallHandler?.provider?.subscriberView ?: openTokView
    }

    override fun dispose() {

    }
}