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
   
    fileprivate var startTestTime: Double = 0.0
    fileprivate let timeVideoTest: Double = 15.0
    fileprivate let timeWindow: Double = 15.0
    fileprivate var prevVideoPacketsLost: Int64 = 0
    fileprivate var prevVideoPacketsSent: Int64 = 0
    fileprivate var prevVideoTimestamp: Double = 0.0
    fileprivate var prevVideoBytes: Int64 = 0
    fileprivate var videoPLRatio: Double = 0.0
    fileprivate var videoBandwidth: Double = 0.0
    fileprivate var publisherAudioOnly = false
    fileprivate var publisherVideoQualityWarning = false
    
    
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

    func publishVideo() throws {
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

    func unpublishVideo() throws {
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
        settings.audioBitrate = self.publisherSettings?.audioBitrate ?? 40000
        
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
        
        providerPublisher.networkStatsDelegate = self;
        providerPublisher.audioFallbackEnabled = self.publisherSettings?.audioFallback ?? true
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
        if providerSubscriber != nil {
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
        if self.loggingEnabled {
            os_log("[OTSessionDelegate] %s", type: .info, #function)
        }
        publish()
        
        channel?.channelInvokeMethod("onSessionConnected", arguments: nil)
    }

    public func sessionDidReconnect(_ session: OTSession) {
        if self.loggingEnabled {
            os_log("[OTSessionDelegate] %s", type: .info, #function)
        }
        
        channel?.channelInvokeMethod("onSessionReconnected", arguments: nil)
    }

    public func sessionDidDisconnect(_ session: OTSession) {
        if self.loggingEnabled {
            os_log("[OTSessionDelegate] %s", type: .info, #function)
        }

        unsubscribe()
        unpublish()

        if providerSession != nil {
            providerSession = nil
        }

        videoReceived = false

        channel?.channelInvokeMethod("onSessionDisconnected", arguments: nil)
    }

    public func sessionDidBeginReconnecting(_ session: OTSession) {
        if self.loggingEnabled {
            os_log("[OTSessionDelegate] %s", type: .info, #function)
        }
        
        channel?.channelInvokeMethod("onSessionReconnecting", arguments: nil)
    }

    public func session(_ session: OTSession, didFailWithError error: OTError) {
        if self.loggingEnabled {
            os_log("[OTSessionDelegate] %s %s", type: .info, #function, error)
        }
        
        channel?.channelInvokeMethod("onSessionError", arguments: error.description)
    }

    public func session(_ session: OTSession, streamCreated stream: OTStream) {
        if self.loggingEnabled {
            os_log("[OTSessionDelegate] %s", type: .info, #function)
        }

        subscribe(toStream: stream)

        channel?.channelInvokeMethod("onSessionStreamReceived", arguments: nil)
        
        if (stream.hasVideo) {
            channel?.channelInvokeMethod("onSessionVideoReceived", arguments: nil)
        }
    }

    public func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        if self.loggingEnabled {
            os_log("[OTSessionDelegate] %s", type: .info, #function)
        }

        unsubscribe()
        
        channel?.channelInvokeMethod("onSessionStreamDropped", arguments: nil)
    }

    public func session(_ session: OTSession, connectionCreated connection: OTConnection) {
        if self.loggingEnabled {
            os_log("[OTSessionDelegate] %s", type: .info, #function)
        }
        
        channel?.channelInvokeMethod("onSessionConnectionCreated", arguments: connection.connectionId)
    }

    public func session(_ session: OTSession, connectionDestroyed connection: OTConnection) {
        if self.loggingEnabled {
            os_log("[OTSessionDelegate] %s", type: .info, #function)
        }
        
        channel?.channelInvokeMethod("onSessionConnectionDestroyed", arguments: connection.connectionId)
    }

    public func session(_ session: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        if self.loggingEnabled {
            os_log("[OTSessionDelegate] %s %s %s %s", type: .info, #function, type ?? "<No signal type>", connection ?? "<Nil connection>", string ?? "<No string>")
        }
    }
}

extension VoIPProvider: OTPublisherDelegate {
    public func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        if self.loggingEnabled {
            os_log("[OTPublisherDelegate] %s", type: .info, #function)
        }

        channel?.channelInvokeMethod("onPublisherStreamCreated", arguments: stream.streamId)
        channel?.channelInvokeMethod("onPublisherVideoStarted", arguments: nil)
        channel?.channelInvokeMethod("onPublisherAudioStarted", arguments: nil)
    }

    public func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        if self.loggingEnabled {
            os_log("[OTPublisherDelegate] %s", type: .info, #function)
        }
        
        channel?.channelInvokeMethod("onPublisherStreamDestroyed", arguments: stream.streamId)
        channel?.channelInvokeMethod("onPublisherVideoStopped", arguments: nil)
        channel?.channelInvokeMethod("onPublisherAudioStopped", arguments: nil)

        unpublish()
    }

    public func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        if self.loggingEnabled {
            os_log("[OTPublisherDelegate] %s %s", type: .info, #function, error.description)
        }
        
        channel?.channelInvokeMethod("onPublisherError", arguments: error.description)
    }

    public func publisher(_ publisher: OTPublisher, didChangeCameraPosition position: AVCaptureDevice.Position) {
        if self.loggingEnabled {
            os_log("[OTPublisherDelegate] %s %d", type: .info, #function, position.rawValue)
        }
    }
}

extension VoIPProvider: OTPublisherKitNetworkStatsDelegate {
    private func checkVideoStats(stats: OTPublisherKitVideoNetworkStats) {
        let videoTimestamp: Double = (stats.timestamp / 1000)

        //initialize values
        if (self.prevVideoTimestamp == 0) {
            self.prevVideoTimestamp = videoTimestamp
            self.prevVideoBytes = stats.videoBytesSent
        }

        if (videoTimestamp - self.prevVideoTimestamp >= self.timeWindow) {
            //calculate video packets lost ratio
            if (self.prevVideoPacketsSent != 0) {
                let pl: Double = Double(stats.videoPacketsLost - self.prevVideoPacketsLost)
                let pr: Double = Double(stats.videoPacketsSent - self.prevVideoPacketsSent)
                let pt: Double = pl + pr

                if (pt > 0) {
                    self.videoPLRatio = (pl / pt)
                }
            }

            self.prevVideoPacketsLost = stats.videoPacketsLost
            self.prevVideoPacketsSent = stats.videoPacketsSent

            //calculate video bandwidth
            self.videoBandwidth = (8.0 * Double(stats.videoPacketsSent - self.prevVideoBytes) / (videoTimestamp - self.prevVideoTimestamp))
            self.prevVideoTimestamp = videoTimestamp
            self.prevVideoBytes = stats.videoPacketsSent

            if self.loggingEnabled {
                os_log("[OTPublisherDelegate] Video bandwidth (bps): %f", type: .info, self.videoBandwidth.rounded())
                os_log("[OTPublisherDelegate] Video Bytes Sent: %d", type: .info, stats.videoPacketsSent)
                os_log("[OTPublisherDelegate] Video packet lost: %d", type: .info, stats.videoPacketsLost)
                os_log("[OTPublisherDelegate] Video packet loss ratio: %f", type: .info, self.videoPLRatio)
            }

            channel?.channelInvokeMethod("onPublisherVideoBandwidth", arguments: self.videoBandwidth.rounded() )

            //check quality of the video call after timeVideoTest seconds
            if ((Date().timeIntervalSince1970 - startTestTime) > self.timeVideoTest) {
                checkVideoQuality();
            }
        }
    }
    
    private func checkVideoQuality() {
        if (self.providerSession != nil) {
            if (self.videoPLRatio >= 0.15) {
                if (!self.publisherAudioOnly) {
                    self.publisherAudioOnly = true
                    self.publisherVideoQualityWarning = false
                    channel?.channelInvokeMethod("onPublisherVideoDisabled", arguments: "quality")
                }
            } else if (self.videoBandwidth < 350.0 || self.videoPLRatio > 0.03) {
                if (!self.publisherAudioOnly && !self.publisherVideoQualityWarning) {
                    publisherVideoQualityWarning = true
                    channel?.channelInvokeMethod("onPublisherVideoDisableWarning", arguments: nil)
                }
            } else {
                if (self.publisherVideoQualityWarning) {
                    self.publisherVideoQualityWarning = false
                    channel?.channelInvokeMethod("onPublisherVideoDisableWarningLifted", arguments: nil)
                }

                if (self.publisherAudioOnly) {
                    self.publisherAudioOnly = false
                    channel?.channelInvokeMethod("onPublisherVideoEnabled", arguments: "quality")
                }
            }
        }
    }
    
    public func publisher(_ publisher: OTPublisherKit, videoNetworkStatsUpdated stats: [OTPublisherKitVideoNetworkStats]) {
        if (publisher.publishVideo == true) {
            if (self.startTestTime == 0.0) {
                self.startTestTime = Date().timeIntervalSince1970;
            }

            self.checkVideoStats(stats: stats[0]);
        }
    }
}

extension VoIPProvider: OTSubscriberKitDelegate {
    private func reasonValueToString(reason: OTSubscriberVideoEventReason) -> String {
        switch reason {
            case .codecNotSupported:
                return "codecNotSupported";
            case .publisherPropertyChanged:
                return "publishVideo";
            case .qualityChanged:
                return "quality";
            case .subscriberPropertyChanged:
                return "subscribeToVideo";
             default:
                return "codecNotSupported";
        }
    }
    
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] %@", type: .info, #function)
        }

        channel?.channelInvokeMethod("onSubscriberConnected", arguments: nil)
        channel?.channelInvokeMethod("onSubscriberVideoStarted", arguments: nil)
        channel?.channelInvokeMethod("onSubscriberAudioStarted", arguments: nil)
    }
    
    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriber %@", type: .info, error)
        }
        
        channel?.channelInvokeMethod("onSubscriberError", arguments: error.description)
    }
    
    public func subscriberDidReconnect(toStream subscriber: OTSubscriberKit) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] %@", type: .info, #function)
        }
        
        channel?.channelInvokeMethod("onSubscriberReconnected", arguments: nil)
    }
    
    public func subscriberVideoDisableWarning(_ subscriber: OTSubscriberKit) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoDisableWarning %@", type: .info, #function)
        }
        
        channel?.channelInvokeMethod("onSubscriberVideoDisableWarning", arguments: nil)
    }
    
    public func subscriberDidDisconnect(fromStream subscriber: OTSubscriberKit) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] %@", type: .info, #function)
        }
        
        channel?.channelInvokeMethod("onSubscriberDisconnected", arguments: nil)
        
        unsubscribe()
    }
    
    public func subscriberVideoDisableWarningLifted(_ subscriber: OTSubscriberKit) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoDisableWarningLifted %@", type: .info, #function)
        }
        
        channel?.channelInvokeMethod("onSubscriberVideoDisableWarningLifted", arguments: nil)
    }
    
    public func subscriberVideoEnabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoEnabled %d", type: .info, reason.rawValue)
        }
        
        channel?.channelInvokeMethod("onSubscriberVideoEnabled", arguments: reasonValueToString(reason: reason))
        
        if (reason != .qualityChanged) {
            channel?.channelInvokeMethod("onSubscriberVideoStarted", arguments: nil)
        }
    }
    
    public func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        if self.loggingEnabled {
            os_log("[OTSubscriberDelegate] subscriberVideoDisabled %d", type: .info, reason.rawValue)
        }
        
        channel?.channelInvokeMethod("onSubscriberVideoDisabled", arguments: reasonValueToString(reason: reason))
        
        if (reason != .qualityChanged) {
            channel?.channelInvokeMethod("onSubscriberVideoStopped", arguments: nil)
        }
    }
}

