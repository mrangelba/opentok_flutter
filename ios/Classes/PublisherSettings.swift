//
//  PublisherSettings.swift
//  opentok_flutter
//
//  Created by Marcelo Rangel on 17/08/20.
//

import Foundation

struct PublisherSettings: Codable {
    var name: String?
    var audioTrack: Bool?
    var videoTrack: Bool?
    var audioBitrate: Int?
    var cameraResolution: OTCameraCaptureResolution?
    var cameraFrameRate: OTCameraCaptureFrameRate?
    var styleVideoScale: String?
}
