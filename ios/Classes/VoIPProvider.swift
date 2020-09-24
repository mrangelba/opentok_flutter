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
    
    fileprivate var providerSession: OTSession!
    fileprivate var providerPublisher: OTPublisher!
    fileprivate var providerSubscriber: OTSubscriber!
    fileprivate var videoReceived: Bool = false
    
    var subscriberView: UIView? {
        return providerSubscriber?.view
    }
    
    var publisherView: UIView? {
        return providerPublisher?.view
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

        providerSession = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
        var error: OTError?
        defer {
            process(error: error)
        }

        providerSession?.connect(withToken: token, error: &error)
    }

    func disconnect() throws {
        if providerSession != nil {
            providerSession.disconnect(nil)
        }
    }

    func unpublishAudio() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Enable publisher audio", type: .info)
        }

        if providerPublisher != nil {
            providerPublisher.publishAudio = false
        }
        
        channel?.channelInvokeMethod("onPublisherAudioStopped", arguments: nil)
    }

    func publishAudio() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Unmute publisher audio", type: .info)
        }

        if providerPublisher != nil {
            providerPublisher.publishAudio = true
        }
        
        channel?.channelInvokeMethod("onPublisherAudioStarted", arguments: nil)
    }

    func subscribeToAudio() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Mute subscriber audio", type: .info)
        }

        if providerSubscriber != nil {
            providerSubscriber.subscribeToAudio = false
        }
    }

    func unsubscribeToAudio() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Unmute subscriber audio", type: .info)
        }

        if providerSubscriber != nil {
            providerSubscriber.subscribeToAudio = true
        }
    }

    func publisherVideo() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Enable publisher video", type: .info)
        }

        if providerPublisher != nil {
            let videoPermission = AVCaptureDevice.authorizationStatus(for: .video)
            let videoEnabled = (videoPermission == .authorized)

            providerPublisher.publishVideo = videoEnabled
            channel?.channelInvokeMethod("onPublisherVideoStarted", arguments: nil)
        }
    }

    func unpublisherVideo() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Disable publisher video", type: .info)
        }

        if providerPublisher != nil {
            providerPublisher.publishVideo = false
            
            channel?.channelInvokeMethod("onPublisherVideoStopped", arguments: nil)
        }
    }

    func subscribeToVideo() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Disable subscriber video", type: .info)
        }

        if providerSubscriber != nil {
            providerSubscriber.subscribeToVideo = false
        }
    }

    func unsubscribeToVideo() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Enable subscriber video", type: .info)
        }

        if providerSubscriber != nil {
            providerSubscriber.subscribeToVideo = true
        }
    }
    
    func switchCamera() throws {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Switch camera", type: .info)
        }
        if providerPublisher.cameraPosition == .front {
            providerPublisher.cameraPosition = .back
        } else {
            providerPublisher.cameraPosition = .front
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
        
        providerPublisher = OTPublisher(delegate: self, settings: settings)
        
        if (publisherSettings?.styleVideoScale != nil) {
            if (publisherSettings?.styleVideoScale == "STYLE_VIDEO_FIT") {
                providerPublisher.viewScaleBehavior = .fit
            } else {
                providerPublisher.viewScaleBehavior = .fill
            }
        }
        
        providerPublisher.cameraPosition = .front

        // Publish publisher to session
        var providerError: OTError?

        providerSession.publish(providerPublisher, error: &providerError)

        guard providerError == nil else {
            if self.loggingEnabled {
                os_log("[VoIPProvider] %s", type: .info, providerError.debugDescription)
            }
            return
        }
    }

    func unpublish() {
        if providerPublisher != nil {
            if self.loggingEnabled {
                os_log("[VoIPProvider] Unpublish")
            }

            providerSession.unpublish(providerPublisher, error: nil)
            providerPublisher = nil
        }
    }

    func subscribe(toStream stream: OTStream) {
        if self.loggingEnabled {
            os_log("[VoIPProvider] Subscribe to stream %s", type: .info, stream.name ?? "<No stream name>")
        }

        providerSubscriber = OTSubscriber(stream: stream, delegate: self)
        if (subscriberSettings?.styleVideoScale != nil) {
            if (subscriberSettings?.styleVideoScale == "STYLE_VIDEO_FIT") {
                providerSubscriber.viewScaleBehavior = .fit
            } else {
                providerSubscriber.viewScaleBehavior = .fill
            }
        }
        providerSession.subscribe(providerSubscriber, error: nil)
    }

    func unsubscribe() {
        if subscriber != nil {
            if self.loggingEnabled {
                os_log("[VoIPProvider] Unsubscribe")
            }

            channel?.channelInvokeMethod("onSubscriberDisconnected", arguments: nil)
            channel?.channelInvokeMethod("onSubscriberVideoStopped", arguments: nil)
            channel?.channelInvokeMethod("onSubscriberAudioStopped", arguments: nil)

            providerSession.unsubscribe(providerSubscriber, error: nil)
            
            providerSubscriber = nil
        }
    }

}

extension VoIPProvider: OTSessionDelegate {
    public func sessionDidConnect(_ session: OTSession) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
        publish()
        
        channel?.channelInvokeMethod("onSessionConnected", arguments: nil)
    }

    public func sessionDidReconnect(_ session: OTSession) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
    }

    public func sessionDidDisconnect(_ session: OTSession) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)

        unsubscribe()
        unpublish()

        if providerSession != nil {
            providerSession = nil
        }

        videoReceived = false

        channel?.channelInvokeMethod("onSessionDisconnected", arguments: nil)
    }

    public func sessionDidBeginReconnecting(_ session: OTSession) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
    }

    public func session(_ session: OTSession, didFailWithError error: OTError) {
        os_log("[OTSessionDelegate] %s %s", type: .info, #function, error)
        
        channel?.channelInvokeMethod("onSessionError", arguments: nil)
    }

    public func session(_ session: OTSession, streamCreated stream: OTStream) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)

        subscribe(toStream: stream)

        channel?.channelInvokeMethod("onSessionStreamReceived", arguments: nil)
        if (stream.hasVideo) {
            channel?.channelInvokeMethod("onSessionVideoReceived", arguments: nil)
        }
    }

    public func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)

        unsubscribe()
        
        channel?.channelInvokeMethod("onSessionStreamDropped", arguments: nil)
    }

    public func session(_ session: OTSession, connectionCreated connection: OTConnection) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
    }

    public func session(_ session: OTSession, connectionDestroyed connection: OTConnection) {
        os_log("[OTSessionDelegate] %s", type: .info, #function)
    }

    public func session(_ session: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        os_log("[OTSessionDelegate] %s %s %s %s", type: .info, #function, type ?? "<No signal type>", connection ?? "<Nil connection>", string ?? "<No string>")
    }
}

extension VoIPProvider: OTPublisherDelegate {
    public func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        os_log("[OTPublisherDelegate] %s", type: .info, #function)

        channel?.channelInvokeMethod("onPublisherStreamCreated", arguments: nil)
        
        if (stream.hasVideo) {
            channel?.channelInvokeMethod("onPublisherVideoStarted", arguments: nil)
        }

        if (stream.hasAudio) {
            channel?.channelInvokeMethod("onPublisherAudioStarted", arguments: nil)
        }
    }

    public func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        os_log("[OTPublisherDelegate] %s", type: .info, #function)
        
        channel?.channelInvokeMethod("onPublisherStreamDestroyed", arguments: nil)
        channel?.channelInvokeMethod("onPublisherVideoStopped", arguments: nil)
        channel?.channelInvokeMethod("onPublisherAudioStopped", arguments: nil)

        unpublish()
    }

    public func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        os_log("[OTPublisherDelegate] %s %s", type: .info, #function, error.description)
        
        channel?.channelInvokeMethod("onPublisherError", arguments: nil)
    }

    public func publisher(_ publisher: OTPublisher, didChangeCameraPosition position: AVCaptureDevice.Position) {
        os_log("[OTPublisherDelegate] %s %d", type: .info, #function, position.rawValue)
    }
}

extension VoIPProvider: OTSubscriberKitDelegate {
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        channel?.channelInvokeMethod("onSubscriberConnected", arguments: nil)

        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] %@", type: .info, #function)
        }
                
        if (subscriber.stream?.hasVideo != nil) {
            channel?.channelInvokeMethod("onSubscriberVideoStarted", arguments: nil)
        }

        if (subscriber.stream?.hasAudio != nil) {
            channel?.channelInvokeMethod("onSubscriberAudioStarted", arguments: nil)
        }
    }
    
    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        channel?.channelInvokeMethod("onSubscriberError", arguments: nil)
        
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriber %@", type: .info, error)
        }
    }
    
    public func subscriberDidReconnect(toStream subscriber: OTSubscriberKit) {
        channel?.channelInvokeMethod("onSubscriberReconnected", arguments: nil)
        
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] %@", type: .info, #function)
        }
    }
    
    public func subscriberVideoDisableWarning(_ subscriber: OTSubscriberKit) {
        channel?.channelInvokeMethod("onSubscriberVideoDisableWarning", arguments: nil)
        
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoDisableWarning %@", type: .info, #function)
        }
    }
    
    public func subscriberDidDisconnect(fromStream subscriber: OTSubscriberKit) {
        channel?.channelInvokeMethod("onSubscriberDisconnected", arguments: nil)
        
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] %@", type: .info, #function)
        }
        
        unsubscribe()
    }
    
    public func subscriberVideoDisableWarningLifted(_ subscriber: OTSubscriberKit) {
        channel?.channelInvokeMethod("onSubscriberVideoDisableWarningLifted", arguments: nil)
        
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoDisableWarningLifted %@", type: .info, #function)
        }
    }
    
    public func subscriberVideoEnabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        channel?.channelInvokeMethod("onSubscriberVideoEnabled", arguments: nil)
        
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoEnabled %d", type: .info, reason.rawValue)
        }
    }
    
    public func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        channel?.channelInvokeMethod("onSubscriberVideoDisabled", arguments: nil)
        
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoDisabled %d", type: .info, reason.rawValue)
        }
    }
}

