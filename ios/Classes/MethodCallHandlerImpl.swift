//
//  MethodCallHandlerImpl.swift
//  opentok_flutter
//
//  Created by Marcelo Rangel on 17/08/20.
//

import Foundation
import OpenTok
import os

public class MethodCallHandlerImpl{
    private let registrar: FlutterPluginRegistrar!
    private var channel: FlutterMethodChannel!
    private var apiKey: String?
    private var sessionId: String?
    private var token: String?
    private var publisherSettings: PublisherSettings?
    private var subscriberSettings: SubscriberSettings?
    public var loggingEnabled: Bool = false
    public var provider: VoIPProvider!

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        channel = FlutterMethodChannel(name: "plugins.flutterbr.dev/opentok_flutter", binaryMessenger: registrar.messenger())
        
        channel.setMethodCallHandler {
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.onMethodCall(call: call, result: result)
        }
    }
    
    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "initialize" {
            guard let args = call.arguments else {
                return
            }

            if let methodArgs = args as? [String: Any] {
                let publisherArg = methodArgs["publisherSettings"] as! String
                let subscriberArg = methodArgs["subscriberSettings"] as? String
                self.loggingEnabled = methodArgs["loggingEnabled"] as? Bool
                
                do {
                    let jsonDecoder = JSONDecoder()

                    self.publisherSettings = try jsonDecoder.decode(PublisherSettings.self, from: publisherArg.data(using: .utf8)!)
                    
                    if (subscriberArg != nil) {
                        self.subscriberSettings = try jsonDecoder.decode(SubscriberSettings.self, from: subscriberArg!.data(using: .utf8)!)
                    }
                    
                } catch {
                    if self.loggingEnabled {
                        print("OpenTok publisher settings error: \(error.localizedDescription)")
                    }
                }
                
                self.apiKey = methodArgs["apiKey"] as? String
                self.sessionId = methodArgs["sessionId"] as? String
                self.token = methodArgs["token"] as? String
                
                provider = VoIPProvider(publisherSettings: self.publisherSettings,
                                        subscriberSettings:self.subscriberSettings,
                                        channel: self,
                                        loggingEnabled: self.loggingEnabled);
                result(true)
            } else {
                result(false)
            }
        } else if call.method == "connect" {
            do {
                try provider?.connect(apiKey: self.apiKey!, sessionId: self.sessionId!, token: self.token!)
                result(true)
            } catch {
                result(false)
            }
        } else if call.method == "destroy" {
            do {
                try provider?.disconnect()
                result(true)
            } catch {
                result(false)
            }
        } else if call.method == "enablePublisherVideo" {
            do {
                try provider?.enablePublisherVideo()
                result(true)
            } catch {
                result(false)
            }
        } else if call.method == "disablePublisherVideo" {
            do {
                try provider?.disablePublisherVideo()
                result(true)
            } catch {
                result(false)
            }
        } else if call.method == "unmutePublisherAudio" {
            do {
                try provider?.unmutePublisherAudio()
                result(true)
            } catch {
                result(false)
            }
        } else if call.method == "mutePublisherAudio" {
            do {
                try provider?.mutePublisherAudio()
                result(true)
            } catch {
                result(false)
            }
        } else if call.method == "muteSubscriberAudio" {
            do {
                try provider?.muteSubscriberAudio()
                result(true)
            } catch {
                result(false)
            }
        } else if call.method == "unmuteSubscriberAudio" {
            do {
                try provider?.unmuteSubscriberAudio()
                result(true)
            } catch {
                result(false)
            }
        } else if call.method == "switchAudioToSpeaker" {
            do {
                try configureAudioSession(switchedToSpeaker: true)
                result(true)
            } catch {
                result(false)
            }
        } else if call.method == "switchAudioToReceiver" {
            do {
                try configureAudioSession(switchedToSpeaker: false)
                result(true)
            } catch {
                result(false)
            }
        } else if call.method == "switchCamera" {
            do {
                try provider.switchCamera()
                result(true)
            } catch {
                result(false)
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    func channelInvokeMethod(_ method: String, arguments: Any?) {
        channel.invokeMethod(method, arguments: arguments) {
            (result: Any?) -> Void in
            if let error = result as? FlutterError {
                if self.loggingEnabled {
                    if #available(iOS 10.0, *) {
                        os_log("%@ failed: %@", type: .error, method, error.message!)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            } else if FlutterMethodNotImplemented.isEqual(result) {
                if self.loggingEnabled {
                    if #available(iOS 10.0, *) {
                        os_log("%@ not implemented", type: .error)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
    
    fileprivate func configureAudioSession(switchedToSpeaker: Bool) throws {
        if self.loggingEnabled {
            print("[FlutterOpenTokViewController] Configure audio session")
            print("[FlutterOpenTokViewController] Switched to speaker = \(switchedToSpeaker)")
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.mixWithOthers, .allowBluetooth])
        } catch {
            if self.loggingEnabled {
                print("[FlutterOpenTokViewController] Session setCategory error: \(error)")
            }
        }

        do {
            try AVAudioSession.sharedInstance().setMode(switchedToSpeaker ? AVAudioSession.Mode.videoChat : AVAudioSession.Mode.voiceChat)
        } catch {
            if self.loggingEnabled {
                print("[FlutterOpenTokViewController] Session setMode error: \(error)")
            }
        }

        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(switchedToSpeaker ? .speaker : .none)
        } catch {
            if self.loggingEnabled {
                print("[FlutterOpenTokViewController] Session overrideOutputAudioPort error: \(error)")
            }
        }

        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            if self.loggingEnabled {
                print("[FlutterOpenTokViewController] Session setActive error: \(error)")
            }
        }
    }
}
