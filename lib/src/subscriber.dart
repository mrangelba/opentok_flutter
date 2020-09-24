import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Subscriber {
  final MethodChannel _channel;

  VoidCallback onAudioStarted;
  VoidCallback onAudioStopped;
  VoidCallback onConnected;
  VoidCallback onDisconnected;
  void Function(String) onError;
  VoidCallback onReconnected;
  VoidCallback onVideoDataReceived;
  VoidCallback onVideoDisabled;
  VoidCallback onVideoDisableWarning;
  VoidCallback onVideoDisableWarningLifted;
  VoidCallback onVideoEnabled;
  VoidCallback onVideoStarted;
  VoidCallback onVideoStopped;

  Subscriber(this._channel);

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
  void setVideoDisabledListener(VoidCallback listener) =>
      onVideoDisabled = listener;
  void setVideoDisableWarningLiftedListener(VoidCallback listener) =>
      onVideoDisableWarningLifted = listener;
  void setVideoDisableWarningListener(VoidCallback listener) =>
      onVideoDisableWarning = listener;
  void setVideoEnabledListener(VoidCallback listener) =>
      onVideoEnabled = listener;
  void setVideoStartedListener(VoidCallback listener) =>
      onVideoStarted = listener;
  void setVideoStoppedListener(VoidCallback listener) =>
      onVideoStopped = listener;
}
