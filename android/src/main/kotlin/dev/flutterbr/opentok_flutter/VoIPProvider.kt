package dev.flutterbr.opentok_flutter

import android.content.Context
import android.util.Log
import android.view.View
import com.opentok.android.*
import com.opentok.android.BaseVideoRenderer.STYLE_VIDEO_FILL
import com.opentok.android.BaseVideoRenderer.STYLE_VIDEO_SCALE

class VoIPProvider(
        var context: Context,
        private var publisherSettings: PublisherSettings,
        var subscriberSettings: SubscriberSettings?,
        var channel: MethodCallHandlerImpl,
        var loggingEnabled: Boolean) : Session.SessionListener, PublisherKit.PublisherListener, SubscriberKit.SubscriberListener {

    private var session: Session? = null
    private var publisher: Publisher? = null
    private var subscriber: Subscriber? = null
    private var videoReceived: Boolean = false

    val subscriberView: View?
        get() {
            return subscriber?.view
        }

    val publisherView: View?
        get() {
            return publisher?.view
        }


    fun connect(apiKey: String, sessionId: String, token: String) {
        channel.channelInvokeMethod("onWillConnect", null)

        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[OpenTokVoIPImpl] Create OTSession")
            Log.d("[VOIPProvider]", "[OpenTokVoIPImpl] API key: $apiKey")
            Log.d("[VOIPProvider]", "[OpenTokVoIPImpl] Session ID: $sessionId")
            Log.d("[VOIPProvider]", "[OpenTokVoIPImpl] Token: $token")
        }

        if (apiKey == "" || sessionId == "" || token == "") {
            return
        }

        session = Session.Builder(context, apiKey, sessionId).build()
        session?.setSessionListener(this)
        session?.connect(token)
    }

    fun disconnect() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Disconnecting from session")
        }

        session?.disconnect()
    }

    fun mutePublisherAudio() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Mute publisher audio")
        }

        publisher?.publishAudio = false
        channel.channelInvokeMethod("onPublisherAudioStopped", null)
    }

    fun unmutePublisherAudio() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "UnMute publisher audio")
        }

        publisher?.publishAudio = true
        channel.channelInvokeMethod("onPublisherAudioStarted", null)
    }

    fun muteSubscriberAudio() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Mute subscriber audio")
        }

        subscriber?.subscribeToAudio = false
    }

    fun unmuteSubscriberAudio() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "UnMute subscriber audio")
        }

        subscriber?.subscribeToAudio = true
    }

    fun enablePublisherVideo() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Enable publisher video")
        }

        publisher?.publishVideo = true
        channel.channelInvokeMethod("onPublisherVideoStarted", null)
    }

    fun disablePublisherVideo() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Disable publisher video")
        }

        publisher?.publishVideo = false
        channel.channelInvokeMethod("onPublisherVideoStopped", null)
    }

    fun switchCamera() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Switch Camera")
        }

        publisher?.cycleCamera()
    }

    /// SessionListener
    override fun onConnected(session: Session?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SessionListener] onConnected")
        }
        publish()

        channel.channelInvokeMethod("onSessionConnected", null)
    }

    override fun onDisconnected(session: Session?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SessionListener] onDisconnected")
        }

        unsubscribe()
        unpublish()
        this.session = null
        videoReceived = false

        channel.channelInvokeMethod("onSessionDisconnected", null)
    }

    override fun onStreamDropped(session: Session?, stream: Stream?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SessionListener] onStreamDropped")
        }
        unsubscribe()
        channel.channelInvokeMethod("onSessionStreamDropped", null)
    }

    override fun onStreamReceived(session: Session?, stream: Stream?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SessionListener] onStreamReceived")
        }
        stream?.let { subscribe(it) }
        channel.channelInvokeMethod("onSessionStreamReceived", null)

        if (stream?.hasVideo() == true) {
            channel.channelInvokeMethod("onSessionVideoReceived", null)
        }
    }

    override fun onError(session: Session?, error: OpentokError?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SessionListener] onError ${error?.message}")
        }

        channel.channelInvokeMethod("onSessionError", null)
    }

    /// PublisherListener

    override fun onStreamCreated(p0: PublisherKit?, stream: Stream?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[PublisherListener] onStreamCreated")
        }
        channel.channelInvokeMethod("onPublisherStreamCreated", null)

        if (stream?.hasVideo() == true) {
            channel.channelInvokeMethod("onPublisherVideoStarted", null)
        }

        if (stream?.hasAudio() == true) {
            channel.channelInvokeMethod("onPublisherAudioStarted", null)
        }
    }

    override fun onStreamDestroyed(p0: PublisherKit?, stream: Stream?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[PublisherListener] onStreamDestroyed")
        }

        channel.channelInvokeMethod("onPublisherStreamDestroyed", null)
        channel.channelInvokeMethod("onPublisherVideoStopped", null)
        channel.channelInvokeMethod("onPublisherAudioStopped", null)

        unpublish()
    }

    override fun onError(p0: PublisherKit?, error: OpentokError?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[PublisherListener] onError ${error?.message}")
        }

        channel.channelInvokeMethod("onPublisherError", null)
    }

    /// SubscriberListener

    override fun onConnected(p0: SubscriberKit?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SubscriberListener] onConnected")
        }

        channel.channelInvokeMethod("onSubscriberConnected", null)

        if (p0?.stream?.hasVideo() == true) {
            channel.channelInvokeMethod("onSubscriberVideoStarted", null)
        }

        if (p0?.stream?.hasAudio() == true) {
            channel.channelInvokeMethod("onSubscriberAudioStarted", null)
        }
    }

    override fun onDisconnected(p0: SubscriberKit?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SubscriberListener] onDisconnected")
        }

        channel.channelInvokeMethod("onSubscriberDisconnected", null)
        channel.channelInvokeMethod("onSubscriberVideoStopped", null)
        channel.channelInvokeMethod("onSubscriberAudioStopped", null)
    }

    override fun onError(p0: SubscriberKit?, error: OpentokError?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SubscriberListener] onError ${error?.message}")
        }

        channel.channelInvokeMethod("onSubscriberError", null)
    }

    /// Private
    private fun publish() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[VOIPProvider] publish")
        }

        publisher = Publisher.Builder(context)
                .audioTrack(publisherSettings.audioTrack ?: true)
                .videoTrack(publisherSettings.videoTrack ?: true)
                .audioBitrate(publisherSettings.audioBitrate ?: 400000)
                .name(publisherSettings.name ?: "")
                .frameRate(parseCameraCaptureFrameRate(publisherSettings.cameraFrameRate))
                .resolution(parseCameraCaptureResolution(publisherSettings.cameraResolution))
                .build()

        publisher?.setPublisherListener(this)
        publisher?.setStyle(STYLE_VIDEO_SCALE, publisherSettings.styleVideoScale
                ?: STYLE_VIDEO_FILL)
        session?.publish(publisher)
    }

    private fun parseCameraCaptureFrameRate(value: String?): Publisher.CameraCaptureFrameRate {
        return when (value) {
            "OTCameraCaptureFrameRate15FPS" -> {
                Publisher.CameraCaptureFrameRate.FPS_15
            }
            "OTCameraCaptureFrameRate7FPS" -> {
                Publisher.CameraCaptureFrameRate.FPS_7
            }
            "OTCameraCaptureFrameRate1FPS" -> {
                Publisher.CameraCaptureFrameRate.FPS_1
            }
            else -> Publisher.CameraCaptureFrameRate.FPS_30
        }
    }

    private fun parseCameraCaptureResolution(value: String?): Publisher.CameraCaptureResolution {
        return when (value) {
            "OTCameraCaptureResolutionLow" -> {
                Publisher.CameraCaptureResolution.LOW
            }
            "OTCameraCaptureResolutionMedium" -> {
                Publisher.CameraCaptureResolution.MEDIUM
            }
            else -> Publisher.CameraCaptureResolution.HIGH
        }
    }

    private fun unpublish() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[VOIPProvider] unpublish")
        }
        if (publisher != null) {
            session?.unpublish(publisher)
            publisher = null
        }
    }

    private fun subscribe(stream: Stream) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[VOIPProvider] subscribe")
        }

        subscriber = Subscriber.Builder(context, stream).build()
        subscriber?.setSubscriberListener(this)
        subscriber?.setStyle(STYLE_VIDEO_SCALE, subscriberSettings?.styleVideoScale
                ?: STYLE_VIDEO_FILL)
        session?.subscribe(subscriber)
    }

    private fun unsubscribe() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", " unsubscribe")
        }

        session?.unsubscribe(subscriber)

        if (subscriber != null) {
            subscriber = null

            channel.channelInvokeMethod("onSubscriberDisconnected", null)
            channel.channelInvokeMethod("onSubscriberVideoStopped", null)
            channel.channelInvokeMethod("onSubscriberAudioStopped", null)
        }
    }

}
