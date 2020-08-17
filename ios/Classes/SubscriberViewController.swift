//
//  SubscriberViewController.swift
//  opentok_flutter
//
//  Created by Marcelo Rangel on 17/08/20.
//

import Foundation
import OpenTok
import os
import SnapKit

class SubscriberViewController: NSObject, FlutterPlatformView {
    private var frame: CGRect!
    private var openTokView: UIView!
    private var methodCallHandler: MethodCallHandlerImpl!

    public init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, methodCallHandler: MethodCallHandlerImpl) {
        self.frame = frame
        self.methodCallHandler = methodCallHandler

        openTokView = UIView(frame: self.frame)
        openTokView.isOpaque = true

        super.init()
    }

    deinit {
        if self.methodCallHandler.loggingEnabled {
            print("[DEINIT] SubscriberViewController")
        }
    }

    public func view() -> UIView {
        return methodCallHandler?.provider?.subscriberView ?? openTokView
    }
}
