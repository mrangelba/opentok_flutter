//
//  PublisherViewFactory.swift
//  opentok_flutter
//
//  Created by Marcelo Rangel on 17/08/20.
//

import Foundation

class PublisherViewFactory: NSObject, FlutterPlatformViewFactory {
    private var methodCallHandler: MethodCallHandlerImpl!

    init(methodCallHandler: MethodCallHandlerImpl) {
        self.methodCallHandler = methodCallHandler
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let viewController: PublisherViewController! = PublisherViewController(frame: frame,
                                                                             viewIdentifier: viewId,
                                                                             arguments: args,
                                                                             methodCallHandler: methodCallHandler)

        return viewController
    }
}
