CameraCaptureFrameRate parseOTCameraCaptureFrameRate(String string) {
  switch (string) {
    case 'OTCameraCaptureFrameRate30FPS':
      return CameraCaptureFrameRate.OTCameraCaptureFrameRate30FPS;
    case 'OTCameraCaptureFrameRate15FPS':
      return CameraCaptureFrameRate.OTCameraCaptureFrameRate15FPS;
    case 'OTCameraCaptureFrameRate7FPS':
      return CameraCaptureFrameRate.OTCameraCaptureFrameRate7FPS;
    case 'OTCameraCaptureFrameRate1FPS':
      return CameraCaptureFrameRate.OTCameraCaptureFrameRate1FPS;
    default:
      return CameraCaptureFrameRate.OTCameraCaptureFrameRate30FPS;
  }
}

CameraCaptureResolution parseOTCameraCaptureResolution(String string) {
  switch (string) {
    case 'OTCameraCaptureResolutionLow':
      return CameraCaptureResolution.OTCameraCaptureResolutionLow;
    case 'OTCameraCaptureResolutionMedium':
      return CameraCaptureResolution.OTCameraCaptureResolutionMedium;
    case 'OTCameraCaptureResolutionHigh':
      return CameraCaptureResolution.OTCameraCaptureResolutionHigh;
    default:
      return CameraCaptureResolution.OTCameraCaptureResolutionMedium;
  }
}

StyleVideoScale parseOTStyleVideoScale(String string) {
  switch (string) {
    case 'STYLE_VIDEO_FILL':
      return StyleVideoScale.OTStyleVideoFill;
    case 'STYLE_VIDEO_FIT':
      return StyleVideoScale.OTStyleVideoFit;
    default:
      return StyleVideoScale.OTStyleVideoFill;
  }
}

String serializeOTCameraCaptureFrameRate(CameraCaptureFrameRate frameRate) {
  switch (frameRate) {
    case CameraCaptureFrameRate.OTCameraCaptureFrameRate30FPS:
      return 'OTCameraCaptureFrameRate30FPS';
    case CameraCaptureFrameRate.OTCameraCaptureFrameRate15FPS:
      return 'OTCameraCaptureFrameRate15FPS';
    case CameraCaptureFrameRate.OTCameraCaptureFrameRate7FPS:
      return 'OTCameraCaptureFrameRate7FPS';
    case CameraCaptureFrameRate.OTCameraCaptureFrameRate1FPS:
      return 'OTCameraCaptureFrameRate1FPS';
    default:
      return 'OTCameraCaptureFrameRate30FPS';
  }
}

String serializeOTCameraCaptureResolution(CameraCaptureResolution frameRate) {
  switch (frameRate) {
    case CameraCaptureResolution.OTCameraCaptureResolutionLow:
      return 'OTCameraCaptureResolutionLow';
    case CameraCaptureResolution.OTCameraCaptureResolutionMedium:
      return 'OTCameraCaptureResolutionMedium';
    case CameraCaptureResolution.OTCameraCaptureResolutionHigh:
      return 'OTCameraCaptureResolutionHigh';
    default:
      return 'OTCameraCaptureResolutionMedium';
  }
}

String serializeOTStyleVideoScale(StyleVideoScale styleVideoScale) {
  switch (styleVideoScale) {
    case StyleVideoScale.OTStyleVideoFill:
      return 'STYLE_VIDEO_FILL';
    case StyleVideoScale.OTStyleVideoFit:
      return 'STYLE_VIDEO_FIT';
    default:
      return 'STYLE_VIDEO_FILL';
  }
}

/// Note that in sessions that use the OpenTok Media Router (sessions with the
/// [media mode](http://tokbox.com/opentok/tutorials/create-session/#media-mode)
/// set to routed), lowering the frame rate proportionally reduces the bandwidth
/// the stream uses. However, in sessions that have the media mode set to
/// relayed, lowering the frame rate does not reduce the stream's bandwidth.
enum CameraCaptureFrameRate {
  /// 30 frames per second.
  OTCameraCaptureFrameRate30FPS,

  /// 15 frames per second.
  OTCameraCaptureFrameRate15FPS,

  /// 7 frames per second.
  OTCameraCaptureFrameRate7FPS,

  /// 1 frame per second.
  OTCameraCaptureFrameRate1FPS,
}

enum CameraCaptureResolution {
  /// The lowest available camera capture resolution supported in the OpenTok iOS SDK (352x288)
  /// or the closest resolution supported on the device.
  OTCameraCaptureResolutionLow,

  /// VGA resolution (640x480) or the closest resolution supported on the device.
  ///
  /// AVCaptureSessionPreset640x480
  OTCameraCaptureResolutionMedium,

  /// The highest available camera capture resolution supported in the OpenTok iOS SDK
  /// (1280x720) or the closest resolution supported on the device.
  ///
  /// AVCaptureSessionPreset1280x720
  OTCameraCaptureResolutionHigh,
}

enum StyleVideoScale {
  OTStyleVideoFill,
  OTStyleVideoFit,
}
