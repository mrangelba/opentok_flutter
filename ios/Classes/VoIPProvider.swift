//
//  VoIPProvider.swift
//  opentok_flutter
//
//  Created by Marcelo Rangel on 17/08/20.
//

import Foundation
import OpenTok
import os.log

public class VoIPProvider: NSObject {
    private var publisherSettings: PublisherSettings?
    private var subscriberSettings: SubscriberSettings?
    private var channel: MethodCallHandlerImpl?
    private var loggingEnabled: Bool = false
    
    fileprivate var session: OTSession!
    fileprivate var publisher: OTPublisher!
    fileprivate var subscriber: OTSubscriber!
    fileprivate var videoReceived: Bool = false
    
    var subscriberView: UIView? {
        return subscriber?.view
    }
    
    var publisherView: UIView? {
        return publisher?.view
    }

    init(publisherSettings: PublisherSettings?,
         subscriberSettings: SubscriberSettings?,
         channel: MethodCallHandlerImpl,
         loggingEnabled: Bool) {
        super.init()
        self.publisherSettings = publisherSettings
        self.subscriberSettings = subscriberSettings
        self.channel = channel
        self.loggingEnabled = loggingEnabled
    }

    deinit {
        if self.loggingEnabled {
            os_log("[VoIPProvider][DEINIT] OpenTokVoIPImpl", type: .info)
        }
    }

    private func process(error err: OTError?) {
        if let e = err {
            if self.loggingEnabled {
                os_log("[VoIPProvider] %s", type: .info, e.localizedDescription)
            }
        }
    }
    
    func connect(apiKey: String, sessionId: String, token: String) throws {
        channel?.channelInvokeMethod("onWillConnect", arguments: nil)
        
        if self.loggingEnabled {
            os_log("[VoIPProvider] Create OTSession", type: .info)
            os_log("[VoIPProvider] API key: %s", type: .info, apiKey)
            os_log("[VoIPProvider] Session ID: %s", type: .info, sessionId)
            os_log("[VoIPProvider] Token: %s", type: .info, token)
        }

        if apiKey == "" || sessionId == "" || token == "" {
            return
        }

        session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
        var error: OTError?
        defer {
            process(error: error)
        }

        session?.connect(withToken: token, error: &error)
    }

    func disconnect() throws {
        if session != nil {
            session.disconnect(nil)
        }
    }

    func mutePublisherAudio() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Enable publisher audio", type: .info)
        }

        if publisher != nil {
            publisher.publishAudio = false
        }
        
        channel?.channelInvokeMethod("onPublisherAudioStopped", arguments: nil)
    }

    func unmutePublisherAudio() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Unmute publisher audio", type: .info)
        }

        if publisher != nil {
            publisher.publishAudio = true
        }
        
        channel?.channelInvokeMethod("onPublisherAudioStarted", arguments: nil)
    }

    func muteSubscriberAudio() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Mute subscriber audio", type: .info)
        }

        if subscriber != nil {
            subscriber.subscribeToAudio = false
        }
    }

    func unmuteSubscriberAudio() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Unmute subscriber audio", type: .info)
        }

        if subscriber != nil {
            subscriber.subscribeToAudio = true
        }
    }

    func enablePublisherVideo() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Enable publisher video", type: .info)
        }

        if publisher != nil {
            let videoPermission = AVCaptureDevice.authorizationStatus(for: .video)
            let videoEnabled = (videoPermission == .authorized)

            publisher.publishVideo = videoEnabled
            channel?.channelInvokeMethod("onPublisherVideoStarted", arguments: nil)
        }
    }

    func disablePublisherVideo() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Disable publisher video", type: .info)
        }

        if publisher != nil {
            publisher.publishVideo = false
            
            channel?.channelInvokeMethod("onPublisherVideoStopped", arguments: nil)
        }
    }
    
    func switchCamera() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Switch camera", type: .info)
        }
        if publisher.cameraPosition == .front {
            publisher.cameraPosition = .back
        } else {
            publisher.cameraPosition = .front
        }
    }
    
}

private extension VoIPProvider {
    func publish() {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Publish", type: .info)
        }

        let settings = OTPublisherSettings()

        settings.name = self.publisherSettings?.name ?? UIDevice.current.name
        settings.videoTrack = self.publisherSettings?.videoTrack ?? true
        settings.audioTrack = self.publisherSettings?.audioTrack ?? true
        switch self.publisherSettings?.cameraResolution {
            case .none:
                settings.cameraResolution = .high
            case .some(.OTCameraCaptureResolutionLow):
                settings.cameraResolution = .low
            case .some(.OTCameraCaptureResolutionMedium):
                settings.cameraResolution = .medium
            case .some(.OTCameraCaptureResolutionHigh):
                settings.cameraResolution = .high
        }
        
        switch self.publisherSettings?.cameraFrameRate {
            case .none:
                settings.cameraFrameRate = .rate30FPS
            case .some(.OTCameraCaptureFrameRate1FPS):
                settings.cameraFrameRate = .rate1FPS
            case .some(.OTCameraCaptureFrameRate30FPS):
                settings.cameraFrameRate = .rate30FPS
            case .some(.OTCameraCaptureFrameRate15FPS):
                settings.cameraFrameRate = .rate15FPS
            case .some(.OTCameraCaptureFrameRate7FPS):
                settings.cameraFrameRate = .rate7FPS
        }
        
        if self.loggingEnabled {
            os_log("[VoIPProvider] Settings: %@", type: .info, settings.description)
        }
        
        publisher = OTPublisher(delegate: self, settings: settings)
        
        if (publisherSettings?.styleVideoScale != nil) {
            if (publisherSettings?.styleVideoScale == "STYLE_VIDEO_FIT") {
                publisher.viewScaleBehavior = .fit
            } else {
                publisher.viewScaleBehavior = .fill
            }
        }
        
        publisher.cameraPosition = .front

        // Publish publisher to session
        var error: OTError?

        session.publish(publisher, error: &error)

        guard error == nil else {
            if self.loggingEnabled {
                os_log("[VoIPProvider] %s", type: .info, error.debugDescription)
            }
            return
        }
    }

    func unpublish() {
        if publisher != nil {
            if self.loggingEnabled {
                os_log("[VoIPProvider] Unpublish")
            }

            session.unpublish(publisher, error: nil)
            publisher = nil
        }
    }

    func subscribe(toStream stream: OTStream) {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Subscribe to stream %s", type: .info, stream.name ?? "<No stream name>")
        }

        subscriber = OTSubscriber(stream: stream, delegate: self)
        if (subscriberSettings?.styleVideoScale != nil) {
            if (subscriberSettings?.styleVideoScale == "STYLE_VIDEO_FIT") {
                subscriber.viewScaleBehavior = .fit
            } else {
                subscriber.viewScaleBehavior = .fill
            }
        }
        session.subscribe(subscriber, error: nil)
    }

    func unsubscribe() {
        if subscriber != nil {
            if self.loggingEnabled {
                os_log("[VoIPProvider] Unsubscribe")
            }

            session.unsubscribe(subscriber, error: nil)
            
            channel?.channelInvokeMethod("onSubscriberDisconnected", arguments: nil)
            channel?.channelInvokeMethod("onSubscriberVideoStopped", arguments: nil)
            channel?.channelInvokeMethod("onSubscriberAudioStopped", arguments: nil)
            subscriber = nil
        }
    }

}

extension VoIPProvider: OTSessionDelegate {
    public func sessionDidConnect(_: OTSession) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
        publish()
        
        channel?.channelInvokeMethod("onSessionConnected", arguments: nil)
    }

    public func sessionDidReconnect(_: OTSession) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
    }

    public func sessionDidDisconnect(_: OTSession) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)

        unsubscribe()
        unpublish()

        if session != nil {
            session = nil
        }

        videoReceived = false

        channel?.channelInvokeMethod("onSessionDisconnected", arguments: nil)
    }

    public func sessionDidBeginReconnecting(_: OTSession) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
    }

    public func session(_: OTSession, didFailWithError error: OTError) {
        os_log("[OTSessionDelegate] %s %s", type: .info, #function, error)
        
        channel?.channelInvokeMethod("onSessionError", arguments: nil)
    }

    public func session(_: OTSession, streamCreated stream: OTStream) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)

        subscribe(toStream: stream)

        channel?.channelInvokeMethod("onSessionStreamReceived", arguments: nil)
        if (stream.hasVideo) {
            channel?.channelInvokeMethod("onSessionVideoReceived", arguments: nil)
        }
    }

    public func session(_: OTSession, streamDestroyed stream: OTStream) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
        
        channel?.channelInvokeMethod("onSessionStreamDropped", arguments: nil)
    }

    public func session(_: OTSession, connectionCreated connection: OTConnection) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
    }

    public func session(_: OTSession, connectionDestroyed connection: OTConnection) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
    }

    public func session(_: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        os_log("[OTSessionDelegate] %s %s %s %s", type: .info, #function, type ?? "<No signal type>", connection ?? "<Nil connection>", string ?? "<No string>")
    }
}

extension VoIPProvider: OTPublisherDelegate {
    public func publisher(_: OTPublisherKit, streamCreated stream: OTStream) {
        os_log("[OTPublisherDelegate] %s", type: .info, #function)

        channel?.channelInvokeMethod("onPublisherStreamCreated", arguments: nil)
        
        if (stream.hasVideo) {
            channel?.channelInvokeMethod("onPublisherVideoStarted", arguments: nil)
        }

        if (stream.hasAudio) {
            channel?.channelInvokeMethod("onPublisherAudioStarted", arguments: nil)
        }
    }

    public func publisher(_: OTPublisherKit, streamDestroyed stream: OTStream) {
        os_log("[OTPublisherDelegate] %s", type: .info, #function)
        
        channel?.channelInvokeMethod("onPublisherStreamDestroyed", arguments: nil)
        channel?.channelInvokeMethod("onPublisherVideoStopped", arguments: nil)
        channel?.channelInvokeMethod("onPublisherAudioStopped", arguments: nil)

        unpublish()
    }

    public func publisher(_: OTPublisherKit, didFailWithError error: OTError) {
        os_log("[OTPublisherDelegate] %s %s", type: .info, #function, error.description)
        
        channel?.channelInvokeMethod("onPublisherError", arguments: nil)
    }

    public func publisher(_: OTPublisher, didChangeCameraPosition position: AVCaptureDevice.Position) {
        os_log("[OTPublisherDelegate] %s %d", type: .info, #function, position.rawValue)
    }
}

extension VoIPProvider: OTSubscriberDelegate {
    public func subscriberDidConnect(toStream stream: OTSubscriberKit) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] %@", type: .info, #function)
        }
        
        channel?.channelInvokeMethod("onSubscriberConnected", arguments: nil)

        if (stream.stream?.hasVideo != nil) {
            channel?.channelInvokeMethod("onSubscriberVideoStarted", arguments: nil)
        }

        if (stream.stream?.hasAudio != nil) {
            channel?.channelInvokeMethod("onSubscriberAudioStarted", arguments: nil)
        }
    }

    public func subscriberDidReconnect(toStream _: OTSubscriberKit) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] %@", type: .info, #function)
        }
    }

    public func subscriberDidDisconnect(fromStream _: OTSubscriberKit) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] %@", type: .info, #function)
        }
        
        unsubscribe()
    }

    public func subscriber(_: OTSubscriberKit, didFailWithError error: OTError) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriber %@", type: .info, error)
        }
        
        channel?.channelInvokeMethod("onSubscriberError", arguments: nil)
    }

    public func subscriberVideoEnabled(_: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoEnabled %d", type: .info, reason.rawValue)
        }
    }

    public func subscriberVideoDisabled(_: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoDisabled %d", type: .info, reason.rawValue)
        }
        
        channel?.channelInvokeMethod("onSubscriberVideoStopped", arguments: nil)
    }

    public func subscriberVideoDataReceived(_: OTSubscriber) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoDataReceived", type: .info)
        }
    }
}

