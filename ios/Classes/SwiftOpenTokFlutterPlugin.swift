//
//  SwiftOpenTokFlutterPlugin.swift
//  opentok_flutter
//
//  Created by Marcelo Rangel on 17/08/20.
//

import Flutter
import UIKit

public class SwiftOpenTokFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodCallHandler: MethodCallHandlerImpl! = MethodCallHandlerImpl(registrar: registrar)
    let publisheViewFactory = PublisherViewFactory(methodCallHandler: methodCallHandler)
    let subscriberViewFactory = SubscriberViewFactory(methodCallHandler: methodCallHandler)

    registrar.register(publisheViewFactory as FlutterPlatformViewFactory, withId: "plugins.flutterbr.dev/opentok_flutter/publisher_view")
    registrar.register(subscriberViewFactory as FlutterPlatformViewFactory, withId: "plugins.flutterbr.dev/opentok_flutter/subscriber_view")
  }

}
