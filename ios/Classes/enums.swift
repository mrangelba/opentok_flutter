//
//  enums.swift
//  opentok_flutter
//
//  Created by Marcelo Rangel on 17/08/20.
//

import Foundation

enum OTCameraCaptureResolution: String, Codable {
    case OTCameraCaptureResolutionLow,
         OTCameraCaptureResolutionMedium,
         OTCameraCaptureResolutionHigh
}

enum OTCameraCaptureFrameRate: String, Codable {
  case OTCameraCaptureFrameRate30FPS,
    OTCameraCaptureFrameRate15FPS,
    OTCameraCaptureFrameRate7FPS,
    OTCameraCaptureFrameRate1FPS
}
