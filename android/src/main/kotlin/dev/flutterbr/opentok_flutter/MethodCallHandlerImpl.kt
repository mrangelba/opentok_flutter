package dev.flutterbr.opentok_flutter

import android.app.Activity
import android.util.Log
import com.opentok.android.AudioDeviceManager
import com.opentok.android.BaseAudioDevice
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.serialization.json.Json

class MethodCallHandlerImpl(private var activity: Activity,
                            messenger: BinaryMessenger?) : MethodChannel.MethodCallHandler {
    private var methodChannel: MethodChannel = MethodChannel(messenger, "plugins.flutterbr.dev/opentok_flutter")
    private var loggingEnabled: Boolean = false
    var provider: VoIPProvider? = null
    private lateinit var publisherSettings: PublisherSettings
    private var subscriberSettings: SubscriberSettings? = null
    private lateinit var apiKey: String
    private lateinit var sessionId: String
    private lateinit var token: String

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                if (call.arguments == null) {
                    result.success(false)
                    return
                }

                try {
                    val args = call.arguments as? Map<*, *>

                    loggingEnabled = args?.get("loggingEnabled") as Boolean

                    val publisherArg = args["publisherSettings"] as String
                    val subscriberArg = args["subscriberSettings"] as String?
                    apiKey = args["apiKey"] as String
                    sessionId = args["sessionId"] as String
                    token = args["token"] as String

                    try {
                        publisherSettings = publisherArg.let { Json.parse(PublisherSettings.serializer(), it) }
                    } catch (e: Exception) {
                        if (loggingEnabled) {
                            Log.d("[MethodCallHandlerImpl]", "OpenTok publisher settings error: ${e.message}")
                        }
                    }

                    try {
                        if (subscriberArg != null) {
                            subscriberSettings = subscriberArg.let { Json.parse(SubscriberSettings.serializer(), it) }
                        }
                    } catch (e: Exception) {
                        if (loggingEnabled) {
                            Log.d("[MethodCallHandlerImpl]", "OpenTok subscriber settings error: ${e.message}")
                        }
                    }

                    provider = VoIPProvider(activity.applicationContext, publisherSettings, subscriberSettings, this, loggingEnabled)
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }

            "connect" -> {
                try {
                    provider?.connect(apiKey, sessionId, token)
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "disconnect" -> {
                try {
                    provider?.disconnect()
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "publishVideo" -> {
                try {
                    provider?.publishVideo()
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }

            }
            "unpublishVideo" -> {
                try {
                    provider?.unpublishVideo()
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "publishAudio" -> {
                try {
                    provider?.publishAudio()
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "unpublishAudio" -> {
                try {
                    provider?.unpublishAudio()
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "subscribeToAudio" -> {
                try {
                    provider?.subscribeToAudio()
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "unsubscribeToAudio" -> {
                try {
                    provider?.unsubscribeToAudio()
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "unsubscribeToVideo" -> {
                try {
                    provider?.unsubscribeToVideo()
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "subscribeToVideo" -> {
                try {
                    provider?.subscribeToVideo()
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "switchAudioToSpeaker" -> {
                try {
                    configureAudioSession(true)
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "switchAudioToReceiver" -> {
                try {
                    configureAudioSession(false)
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            "switchCamera" -> {
                try {
                    provider?.switchCamera()
                    result.success(true)
                } catch (ex: Exception) {
                    result.success(false)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun configureAudioSession(switchedToSpeaker: Boolean) {
        if (loggingEnabled) {
            print("[FlutterOpenTokViewController] Configure audio session")
            print("[FlutterOpenTokViewController] Switched to speaker = $switchedToSpeaker")
        }

        if (switchedToSpeaker) {
            AudioDeviceManager.getAudioDevice().outputMode = BaseAudioDevice.OutputMode.SpeakerPhone
        } else {
            AudioDeviceManager.getAudioDevice().outputMode = BaseAudioDevice.OutputMode.Handset
        }
    }


    private fun handleException(exception: java.lang.Exception, result: MethodChannel.Result) {
        channelInvokeMethod("onError", exception)
    }

    fun channelInvokeMethod(method: String, arguments: Any?) {
        methodChannel.invokeMethod(method, arguments, object : MethodChannel.Result {
            override fun notImplemented() {
                if (loggingEnabled) {
                    Log.d("[MethodCallHandlerImpl]", "Method $method is not implemented")
                }
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                if (loggingEnabled) {
                    Log.d("[MethodCallHandlerImpl]", "Method $method failed with error $errorMessage")
                }
            }

            override fun success(result: Any?) {
                if (loggingEnabled) {
                    Log.d("[MethodCallHandlerImpl]", "Method $method succeeded")
                }
            }

        })
    }

    fun stopListening() {
        methodChannel.setMethodCallHandler(null)
    }

}