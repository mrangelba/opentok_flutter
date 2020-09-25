import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class Subscriber {
  final MethodChannel _channel;
  final _videoDisabledQualityController = BehaviorSubject<bool>.seeded(false);

  VoidCallback onAudioStarted;
  VoidCallback onAudioStopped;
  VoidCallback onConnected;
  VoidCallback onDisconnected;
  void Function(String) onError;
  VoidCallback onReconnected;
  VoidCallback onVideoDataReceived;
  VoidCallback onVideoDisableWarning;
  VoidCallback onVideoDisableWarningLifted;
  VoidCallback onVideoStarted;
  VoidCallback onVideoStopped;
  void Function(String) _onVideoDisabled;
  void Function(String) _onVideoEnabled;

  Subscriber(this._channel);

  Stream<bool> get videoDisabledQuality =>
      _videoDisabledQualityController.stream;

  /// Disables the subscribers audio.
  Future<bool> disableAudio() async {
    try {
      return await _channel.invokeMethod('unsubscribeToAudio');
    } catch (e) {
      print(e);

      return false;
    }
  }

  /// Disables the subscribers video.
  Future<bool> disableVideo() async {
    try {
      return await _channel.invokeMethod('unsubscribeToVideo');
    } catch (e) {
      print(e);

      return false;
    }
  }

  void dispose() {
    _videoDisabledQualityController.close();
  }

  /// Enables the subscribers audio.
  Future<bool> enableAudio() async {
    try {
      return await _channel.invokeMethod('subscribeToAudio');
    } catch (e) {
      print(e);

      return false;
    }
  }

  /// Enables the subscribers video.
  Future<bool> enableVideo() async {
    try {
      return await _channel.invokeMethod('subscribeToVideo');
    } catch (e) {
      print(e);

      return false;
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
  void setConnectedListener(VoidCallback listener) => onConnected = listener;
  void setDisconnectedListener(VoidCallback listener) =>
      onDisconnected = listener;
  void setErrorListener(void Function(String) listener) => onError = listener;
  void setReconnectedListener(VoidCallback listener) =>
      onReconnected = listener;
  void setVideoDataReceivedListener(VoidCallback listener) =>
      onVideoDataReceived = listener;
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
}
