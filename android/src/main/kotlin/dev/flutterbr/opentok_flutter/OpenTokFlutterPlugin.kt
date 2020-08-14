package dev.flutterbr.opentok_flutter

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry.Registrar


/** OpenTokFlutterPlugin */
class OpenTokFlutterPlugin : FlutterPlugin, ActivityAware {
    private var flutterPluginBinding: FlutterPluginBinding? = null
    private var methodCallHandler: MethodCallHandlerImpl? = null

    fun registerWith(registrar: Registrar) {
        val plugin = OpenTokFlutterPlugin()
        plugin.maybeStartListening(
                registrar.activity(),
                registrar.messenger())

        registrar.platformViewRegistry().registerViewFactory(
                "plugins.flutterbr.dev/opentok_flutter/publisher_view", PublisherViewFactory(methodCallHandler))
        registrar.platformViewRegistry().registerViewFactory(
                "plugins.flutterbr.dev/opentok_flutter/subscriber_view", SubscriberViewFactory(methodCallHandler))
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        this.flutterPluginBinding = binding
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        this.flutterPluginBinding = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        maybeStartListening(
                binding.activity,
                flutterPluginBinding?.binaryMessenger)

        flutterPluginBinding?.platformViewRegistry?.registerViewFactory(
                "plugins.flutterbr.dev/opentok_flutter/publisher_view", PublisherViewFactory(methodCallHandler))
        flutterPluginBinding?.platformViewRegistry?.registerViewFactory(
                "plugins.flutterbr.dev/opentok_flutter/subscriber_view", SubscriberViewFactory(methodCallHandler))
    }

    override fun onDetachedFromActivity() {
        if (methodCallHandler == null) {
            // Could be on too low of an SDK to have started listening originally.
            return
        }
        methodCallHandler?.stopListening()
        methodCallHandler = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    private fun maybeStartListening(
            activity: Activity,
            messenger: BinaryMessenger?) {
        methodCallHandler = MethodCallHandlerImpl(
                activity, messenger)


    }
}
