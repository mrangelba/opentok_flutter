import Flutter
import UIKit

public class SwiftOpenTokFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let publisherViewFactory = PublisherViewFactory(registrar: registrar)

        registrar.register(publisherViewFactory as FlutterPlatformViewFactory, withId: "plugins.flutterbr.dev/opentok_flutter/publisher_view")
    }
}
