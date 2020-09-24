import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Publisher {
  final MethodChannel _channel;

  VoidCallback onAudioStarted;
  VoidCallback onAudioStopped;
  void Function(String) onError;
  VoidCallback onStreamCreated;
  VoidCallback onStreamDestroyed;
  VoidCallback onVideoStarted;
  VoidCallback onVideoStopped;

  Publisher(this._channel);

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

  void setAudioStartedListener(VoidCallback listener) =>
      onAudioStarted = listener;
  void setAudioStoppedListener(VoidCallback listener) =>
      onAudioStopped = listener;
  void setErrorListener(void Function(String) listener) => onError = listener;
  void setStreamCreatedListener(VoidCallback listener) =>
      onStreamCreated = listener;
  void setStreamDestroyedListener(VoidCallback listener) =>
      onStreamDestroyed = listener;
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
