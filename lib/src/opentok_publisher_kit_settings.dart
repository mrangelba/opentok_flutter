import 'enums.dart';

/// OTPublisherKitSettings defines settings to be used when initializing a publisher.
class PublisherKitSettings {
  const PublisherKitSettings({
    this.name,
    this.audioTrack,
    this.videoTrack,
    this.audioBitrate,
    this.cameraResolution,
    this.cameraFrameRate,
    this.styleVideoScale,
  });

  /// The name of the publisher video. The <[OTStream name]> property
  /// for a stream published by this publisher will be set to this value
  /// (on all clients). The default value is `null`.
  final String name;

  /// Whether to publish audio (YES, the default) or not (NO).
  /// If this property is set to NO, the audio subsystem will not be initialized
  /// for the publisher, and setting the <[OTPublisherKit publishAudio]> property
  /// will have no effect. If your application does not require the use of audio,
  /// it is recommended to set this Builder property rather than use the
  /// <[OTPublisherKit publishAudio]> property, which only temporarily disables
  /// the audio track.
  final bool audioTrack;

  /// Whether to publish video (YES, the default) or not (NO).
  /// If this property is set to NO, the video subsystem will not be initialized
  /// for the publisher, and setting the <[OTPublisherKit publishVideo]> property
  /// will have no effect. If your application does not require the use of video,
  /// it is recommended to set this Builder property rather than use the
  /// <[OTPublisherKit publishVideo]> property, which only temporarily disables
  /// the video track.
  final bool videoTrack;

  /// The desired bitrate for the published audio, in bits per second.
  /// The supported range of values is 6,000 - 510,000. (Invalid values are
  /// ignored.) Set this value to enable high-quality audio (or to reduce
  /// bandwidth usage with lower-quality audio).
  ///
  /// The following are recommended settings:
  ///
  /// 8,000 - 12,000 for narrowband (NB) speech
  /// 16,000 - 20,000 for wideband (WB) speech
  /// 28,000 - 40,000 for full-band (FB) speech
  /// 48,000 - 64,000 for full-band (FB) mono music
  /// 64,000 - 128,000 for full-band (FB) stereo music
  ///
  /// The default value is [OpenTokAudioBitrateDefault].
  final int audioBitrate;

  final CameraCaptureResolution cameraResolution;

  final CameraCaptureFrameRate cameraFrameRate;

  final StyleVideoScale styleVideoScale;

  factory PublisherKitSettings.fromJson(Map<String, dynamic> json) =>
      PublisherKitSettings(
        audioBitrate: json['audioBitrate'],
        audioTrack: json['audioTrack'],
        cameraFrameRate: parseOTCameraCaptureFrameRate(json['cameraFrameRate']),
        cameraResolution:
            parseOTCameraCaptureResolution(json['cameraResolution']),
        name: json['name'],
        videoTrack: json['videoTrack'],
        styleVideoScale: parseOTStyleVideoScale(json['styleVideoScale']),
      );

  Map<String, dynamic> toJson() => {
        'audioTrack': audioTrack,
        'audioBitrate': audioBitrate,
        'cameraFrameRate': serializeOTCameraCaptureFrameRate(cameraFrameRate),
        'cameraResolution':
            serializeOTCameraCaptureResolution(cameraResolution),
        'name': name,
        'videoTrack': videoTrack,
        'styleVideoScale': serializeOTStyleVideoScale(styleVideoScale),
      };
}
