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
        var loggingEnabled: Boolean) :
        Session.SessionListener,
        Session.ReconnectionListener,
        Session.ConnectionListener,
        PublisherKit.PublisherListener,
        PublisherKit.VideoStatsListener,
        SubscriberKit.SubscriberListener,
        SubscriberKit.StreamListener,
        SubscriberKit.VideoListener {

    private var session: Session? = null
    private var publisher: Publisher? = null
    private var subscriber: Subscriber? = null
    private var videoReceived: Boolean = false
    private var startTestTime: Double = 0.0
    private val timeVideoTest = 15
    private val timeWindow = 15

    private var prevVideoPacketsLost = 0L
    private var prevVideoPacketsSent = 0L
    private var prevVideoTimestamp = 0L
    private var prevVideoBytes = 0L
    private var videoPLRatio = 0.0
    private var videoBandwidth = 0L
    private var publisherAudioOnly = false
    private var publisherVideoQualityWarning = false

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
        session?.setConnectionListener(this)
        session?.setReconnectionListener(this)
        session?.connect(token)
    }

    fun disconnect() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Disconnecting from session")
        }

        session?.disconnect()
    }

    fun unpublishAudio() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Mute publisher audio")
        }

        if (publisher != null) {
            publisher?.publishAudio = false
            channel.channelInvokeMethod("onPublisherAudioStopped", null)
        }
    }

    fun publishAudio() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "UnMute publisher audio")
        }

        if (publisher != null) {
            publisher?.publishAudio = true
            channel.channelInvokeMethod("onPublisherAudioStarted", null)
        }
    }

    fun unsubscribeToAudio() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Mute subscriber audio")
        }

        if (subscriber != null) {
            subscriber?.subscribeToAudio = false
            channel.channelInvokeMethod("onSubscriberAudioStopped", null)
        }
    }

    fun subscribeToAudio() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "UnMute subscriber audio")
        }

        if (subscriber != null) {
            subscriber?.subscribeToAudio = true
            channel.channelInvokeMethod("onSubscriberAudioStarted", null)
        }
    }

    fun publishVideo() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Enable publisher video")
        }

        if (publisher != null) {
            publisher?.publishVideo = true
            channel.channelInvokeMethod("onPublisherVideoStarted", null)
        }
    }

    fun unpublishVideo() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Disable publisher video")
        }

        if (publisher != null) {
            publisher?.publishVideo = false
            channel.channelInvokeMethod("onPublisherVideoStopped", null)
        }
    }

    fun subscribeToVideo() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Enable subscriber video")
        }

        if (subscriber != null) {
            subscriber?.subscribeToVideo = true
            channel.channelInvokeMethod("onSubscriberVideoStarted", null)
        }
    }

    fun unsubscribeToVideo() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Disable subscriber video")
        }

        if (subscriber != null) {
            subscriber?.subscribeToVideo = false
            channel.channelInvokeMethod("onSubscriberVideoStopped", null)
        }
    }

    fun switchCamera() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "Switch Camera")
        }

        publisher?.cycleCamera()
    }

    /// Private
    private fun publish() {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[VOIPProvider] publish")
        }

        publisher = Publisher.Builder(context)
                .audioTrack(publisherSettings.audioTrack ?: true)
                .videoTrack(publisherSettings.videoTrack ?: true)
                .audioBitrate(publisherSettings.audioBitrate ?: 40000)
                .name(publisherSettings.name ?: "")
                .frameRate(parseCameraCaptureFrameRate(publisherSettings.cameraFrameRate))
                .resolution(parseCameraCaptureResolution(publisherSettings.cameraResolution))
                .build()

        publisher?.setPublisherListener(this)
        publisher?.setVideoStatsListener(this)
        publisher?.setStyle(STYLE_VIDEO_SCALE, publisherSettings.styleVideoScale
                ?: STYLE_VIDEO_FILL)
        publisher?.audioFallbackEnabled = publisherSettings.audioFallback ?: true

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
        subscriber?.setVideoListener(this)
        subscriber?.setStreamListener(this)
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

        channel.channelInvokeMethod("onSessionError", error?.message)
    }

    /// PublisherListener

    override fun onStreamCreated(p0: PublisherKit?, stream: Stream?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[PublisherListener] onStreamCreated")
        }

        channel.channelInvokeMethod("onPublisherStreamCreated", stream?.streamId)
        channel.channelInvokeMethod("onPublisherVideoStarted", null)
        channel.channelInvokeMethod("onPublisherAudioStarted", null)
    }

    override fun onStreamDestroyed(p0: PublisherKit?, stream: Stream?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[PublisherListener] onStreamDestroyed")
        }

        channel.channelInvokeMethod("onPublisherStreamDestroyed", stream?.streamId)
        channel.channelInvokeMethod("onPublisherVideoStopped", null)
        channel.channelInvokeMethod("onPublisherAudioStopped", null)

        unpublish()
    }

    override fun onError(p0: PublisherKit?, error: OpentokError?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[PublisherListener] onError ${error?.message}")
        }

        channel.channelInvokeMethod("onPublisherError", error?.message)
    }

    /// SubscriberListener

    override fun onConnected(p0: SubscriberKit?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SubscriberListener] onConnected")
        }

        channel.channelInvokeMethod("onSubscriberConnected", null)
        channel.channelInvokeMethod("onSubscriberVideoStarted", null)
        channel.channelInvokeMethod("onSubscriberAudioStarted", null)
    }

    override fun onDisconnected(p0: SubscriberKit?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SubscriberListener] onDisconnected")
        }

        unsubscribe()

        channel.channelInvokeMethod("onSubscriberDisconnected", null)
    }

    override fun onError(p0: SubscriberKit?, error: OpentokError?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[SubscriberListener] onError ${error?.message}")
        }

        channel.channelInvokeMethod("onSubscriberError", error?.message)
    }

    // StreamListener

    override fun onReconnected(p0: SubscriberKit?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[StreamListener] onReconnected")
        }

        channel.channelInvokeMethod("onSubscriberReconnected", null)
    }

    /// ReconnectionListener

    override fun onReconnected(p0: Session?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[ReconnectionListener] onReconnected")
        }

        channel.channelInvokeMethod("onSessionReconnected", null)
    }

    override fun onReconnecting(p0: Session?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[ReconnectionListener] onReconnecting")
        }

        channel.channelInvokeMethod("onSessionReconnecting", null)
    }

    /// ConnectionListener

    override fun onConnectionDestroyed(p0: Session?, p1: Connection?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[ConnectionListener] onConnectionDestroyed")
        }

        channel.channelInvokeMethod("onSessionConnectionDestroyed", p1?.connectionId)
    }

    override fun onConnectionCreated(p0: Session?, p1: Connection?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[ConnectionListener] onConnectionCreated")
        }

        channel.channelInvokeMethod("onSessionConnectionCreated", p1?.connectionId)
    }

    /// VideoListener

    override fun onVideoDataReceived(p0: SubscriberKit?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[VideoListener] onVideoDataReceived")
        }

        channel.channelInvokeMethod("onSubscriberVideoDataReceived", null)
    }

    override fun onVideoEnabled(p0: SubscriberKit?, p1: String?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[VideoListener] onVideoEnabled")
        }

        channel.channelInvokeMethod("onSubscriberVideoEnabled", p1)

        if (p1 != SubscriberKit.VIDEO_REASON_QUALITY) {
            channel.channelInvokeMethod("onSubscriberVideoStarted", null)
        }
    }

    override fun onVideoDisableWarning(p0: SubscriberKit?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[VideoListener] onVideoDisableWarning")
        }

        channel.channelInvokeMethod("onSubscriberVideoDisableWarning", null)
    }

    override fun onVideoDisableWarningLifted(p0: SubscriberKit?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[VideoListener] onVideoDisableWarningLifted")
        }

        channel.channelInvokeMethod("onSubscriberVideoDisableWarningLifted", null)
    }

    override fun onVideoDisabled(p0: SubscriberKit?, p1: String?) {
        if (loggingEnabled) {
            Log.d("[VOIPProvider]", "[VideoListener] onVideoDisabled")
        }

        channel.channelInvokeMethod("onSubscriberVideoDisabled", p1)

        if (p1 != SubscriberKit.VIDEO_REASON_QUALITY) {
            channel.channelInvokeMethod("onSubscriberVideoStopped", null)
        }
    }

    /// VideoStatsListener

    override fun onVideoStats(subscriber: PublisherKit?, stats: Array<out PublisherKit.PublisherVideoStats>?) {
        if (subscriber?.publishVideo == true && stats != null) {
            if (startTestTime == 0.0) {
                startTestTime = System.currentTimeMillis().toDouble() / 1000;
            }

            checkVideoStats(stats[0]);
        }
    }

    private fun checkVideoStats(stats: PublisherKit.PublisherVideoStats) {
        val videoTimestamp = (stats.timeStamp / 1000).toLong()

        //initialize values
        if (prevVideoTimestamp == 0L) {
            prevVideoTimestamp = videoTimestamp
            prevVideoBytes = stats.videoBytesSent
        }

        if (videoTimestamp - prevVideoTimestamp >= timeWindow) {
            //calculate video packets lost ratio
            if (prevVideoPacketsSent != 0L) {
                val pl = stats.videoPacketsLost - prevVideoPacketsLost
                val pr = stats.videoPacketsSent - prevVideoPacketsSent
                val pt = pl + pr

                if (pt > 0) {
                    videoPLRatio = (pl.toDouble() / pt.toDouble())
                }
            }

            prevVideoPacketsLost = stats.videoPacketsLost
            prevVideoPacketsSent = stats.videoPacketsSent

            //calculate video bandwidth
            videoBandwidth = (8 * (stats.videoPacketsSent - prevVideoBytes) / (videoTimestamp - prevVideoTimestamp))
            prevVideoTimestamp = videoTimestamp
            prevVideoBytes = stats.videoPacketsSent

            if (loggingEnabled) {
                Log.i("[VOIPProvider]", "Video bandwidth (bps): " + videoBandwidth.toString() + " Video Bytes Sent: " + stats.videoPacketsSent.toString() + " Video packet lost: " + stats.videoPacketsLost.toString() + " Video packet loss ratio: " + videoPLRatio.toString())
            }

            channel.channelInvokeMethod("onPublisherVideoBandwidth", videoBandwidth)

            //check quality of the video call after timeVideoTest seconds
            if ((System.currentTimeMillis() / 1000 - startTestTime) > timeVideoTest) {
                checkVideoQuality();
            }
        }
    }

    private fun checkVideoQuality() {
        if (session != null) {
            if (videoPLRatio >= 0.15) {
                if (!publisherAudioOnly) {
                    publisherAudioOnly = true
                    publisherVideoQualityWarning = false
                    channel.channelInvokeMethod("onPublisherVideoDisabled", SubscriberKit.VIDEO_REASON_QUALITY)
                }
            } else if (videoBandwidth < 350.0 || videoPLRatio > 0.03) {
                if (!publisherAudioOnly && !publisherVideoQualityWarning) {
                    publisherVideoQualityWarning = true
                    channel.channelInvokeMethod("onPublisherVideoDisableWarning", null)
                }
            } else {
                if (publisherVideoQualityWarning) {
                    publisherVideoQualityWarning = false
                    channel.channelInvokeMethod("onPublisherVideoDisableWarningLifted", null)
                }

                if (publisherAudioOnly) {
                    publisherAudioOnly = false
                    channel.channelInvokeMethod("onPublisherVideoEnabled", SubscriberKit.VIDEO_REASON_QUALITY)
                }
            }
        }
    }

}
