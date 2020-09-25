import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class Publisher {
  final MethodChannel _channel;
  final _videoDisabledQualityController = BehaviorSubject<bool>.seeded(false);
  final _videoBandwidthController = BehaviorSubject<double>.seeded(0.0);

  VoidCallback onAudioStarted;
  VoidCallback onAudioStopped;
  void Function(String) onError;
  void Function(String) onStreamCreated;
  void Function(String) onStreamDestroyed;
  VoidCallback onVideoStarted;
  VoidCallback onVideoStopped;
  VoidCallback onVideoDisableWarning;
  VoidCallback onVideoDisableWarningLifted;
  void Function(String) _onVideoDisabled;
  void Function(String) _onVideoEnabled;
  void Function(double) _onVideoBandwidth;

  Publisher(this._channel);

  Stream<double> get videoBandwidth => _videoBandwidthController.stream;

  Stream<bool> get videoDisabledQuality =>
      _videoDisabledQualityController.stream;

  /// Unmute the publisher audio module.
  ///
  /// The audio module is enabled by default.
  Future<bool> disableAudio() async {
    try {
      return await _channel.invokeMethod('unpublishAudio');
    } catch (e) {
      print(e);

      return false;
    }
  }

  /// Disables the publishers video module.
  ///
  /// The audio module is enabled by default.
  Future<bool> disableVideo() async {
    try {
      return await _channel.invokeMethod('unpublishVideo');
    } catch (e) {
      print(e);

      return false;
    }
  }

  void dispose() {
    _videoDisabledQualityController.close();
    _videoBandwidthController.close();
  }

  /// Mute the publisher audio module.
  ///
  /// The audio module is enabled by default.
  Future<bool> enableAudio() async {
    try {
      return await _channel.invokeMethod('publishAudio');
    } catch (e) {
      print(e);

      return false;
    }
  }

  /// Enables the subscriber video module.
  ///
  /// The audio module is enabled by default.
  Future<bool> enableVideo() async {
    try {
      return await _channel.invokeMethod('publishVideo');
    } catch (e) {
      print(e);

      return false;
    }
  }

  void onVideoBandwidth(double bandwidth) {
    if (!_videoBandwidthController.isClosed) {
      _videoBandwidthController.add(bandwidth);
    }

    if (_onVideoBandwidth != null) {
      _onVideoBandwidth(bandwidth);
    }
  }

  void onVideoDisabled(String reason) {
    if (reason == 'quality' && !_videoDisabledQualityController.isClosed) {
      _videoDisabledQualityController.add(true);
    }

    if (_onVideoDisabled != null) {
      _onVideoDisabled(reason);
    }
  }

  void onVideoEnabled(String reason) {
    if (reason == 'quality' && !_videoDisabledQualityController.isClosed) {
      _videoDisabledQualityController.add(false);
    }

    if (_onVideoEnabled != null) {
      _onVideoEnabled(reason);
    }
  }

  void setAudioStartedListener(VoidCallback listener) =>
      onAudioStarted = listener;
  void setAudioStoppedListener(VoidCallback listener) =>
      onAudioStopped = listener;
  void setErrorListener(void Function(String) listener) => onError = listener;
  void setStreamCreatedListener(void Function(String) listener) =>
      onStreamCreated = listener;
  void setStreamDestroyedListener(void Function(String) listener) =>
      onStreamDestroyed = listener;
  void setVideoBandwidthListener(void Function(double) listener) =>
      _onVideoBandwidth = listener;
  void setVideoDisabledListener(void Function(String) listener) =>
      _onVideoDisabled = listener;
  void setVideoDisableWarningLiftedListener(VoidCallback listener) =>
      onVideoDisableWarningLifted = listener;
  void setVideoDisableWarningListener(VoidCallback listener) =>
      onVideoDisableWarning = listener;
  void setVideoEnabledListener(void Function(String) listener) =>
      _onVideoEnabled = listener;
  void setVideoStartedListener(VoidCallback listener) =>
      onVideoStarted = listener;
  void setVideoStoppedListener(VoidCallback listener) =>
      onVideoStopped = listener;

  /// Switch the audio output to use phone
  Future<bool> switchAudioToPhone() async {
    try {
      return await _channel.invokeMethod("switchAudioToReceiver");
    } catch (e) {
      print(e);

      return false;
    }
  }

  /// Switch the audio output to use speakers
  Future<bool> switchAudioToSpeaker() async {
    try {
      return await _channel.invokeMethod("switchAudioToSpeaker");
    } catch (e) {
      print(e);

      return false;
    }
  }

  // Camera Control
  /// Switches between front and rear cameras.
  Future<bool> switchCamera() async {
    try {
      return await _channel.invokeMethod('switchCamera');
    } catch (e) {
      print(e);

      return false;
    }
  }
}
