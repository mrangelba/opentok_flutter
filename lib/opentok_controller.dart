import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'opemtok_controller_value.dart';
import 'opentok_publisher_kit_settings.dart';
import 'opentok_subscriber_kit_settings.dart';

class OpenTokController extends ValueNotifier<OpenTokControllerValue> {
  static const _channel =
      const MethodChannel('plugins.flutterbr.dev/opentok_flutter');

  OpenTokController() : super(const OpenTokControllerValue.uninitialized()) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  // Core Methods
  /// Creates an OpenTok instance.
  ///
  /// The OpenTok SDK only supports one instance at a time, therefore the app should create one object only.
  /// Only users with the same api key, session id and token can join the same channel and call each other.
  Future<void> initialize({
    @required String apiKey,
    @required String sessionId,
    @required String token,
    @required PublisherKitSettings publisherSettings,
    SubscriberKitSettings subscriberSettings,
  }) async {
    var result = await _channel.invokeMethod('initialize', {
      'apiKey': apiKey,
      'sessionId': sessionId,
      'token': token,
      'subscriberSettings': subscriberSettings == null
          ? null
          : jsonEncode(subscriberSettings.toJson()),
      'publisherSettings': jsonEncode(publisherSettings.toJson()),
      'loggingEnabled': true,
    });

    value = value.copyWith(isInitialized: result);

    return result;
  }

  Future<bool> connect() async {
    var result = await _channel.invokeMethod('connect');

    value = value.copyWith(isConnected: result);

    return result;
  }

  Future<bool> disconnect() async {
    var result = await _channel.invokeMethod('disconnect');

    value = value.copyWith(isConnected: false);

    return result;
  }

  /// Destroys the instance and releases all resources used by the OpenTok SDK.
  ///
  /// This method is useful for apps that occasionally make voice or video calls, to free up resources for other operations when not making calls.
  /// Once the app calls destroy to destroy the created instance, you cannot use any method or callback in the SDK.
  @override
  Future<void> dispose() async {
    _removeMethodCallHandler();
    await disconnect();
    super.dispose();
  }

  /// Unmute the publisher audio module.
  ///
  /// The audio module is enabled by default.
  Future<bool> unmutePublisherAudio() async {
    return await _channel.invokeMethod('unmutePublisherAudio');
  }

  /// Mute the publisher audio module.
  ///
  /// The audio module is enabled by default.
  Future<bool> mutePublisherAudio() async {
    return await _channel.invokeMethod('mutePublisherAudio');
  }

  /// Enables the subscriber video module.
  ///
  /// The audio module is enabled by default.
  Future<bool> enablePublisherVideo() async {
    return await _channel.invokeMethod('enablePublisherVideo');
  }

  /// Disables the publishers video module.
  ///
  /// The audio module is enabled by default.
  Future<bool> disablePublisherVideo() async {
    return await _channel.invokeMethod('disablePublisherVideo');
  }

  /// Disables the subscribers audio.
  Future<bool> muteSubscriberAudio() async {
    return await _channel.invokeMethod('muteSubscriberAudio');
  }

  /// Enables the subscribers audio.
  Future<bool> unmuteSubscriberAudio() async {
    return await _channel.invokeMethod('unmuteSubscriberAudio');
  }

  /// Switch the audio output to use speakers
  Future<bool> switchAudioToSpeaker() async {
    return await _channel.invokeMethod("switchAudioToSpeaker");
  }

  /// Switch the audio output to use phone
  Future<bool> switchAudioToPhone() async {
    return await _channel.invokeMethod("switchAudioToReceiver");
  }

  // Camera Control
  /// Switches between front and rear cameras.
  Future<bool> switchCamera() async {
    return await _channel.invokeMethod('switchCamera');
  }

  VoidCallback onWillConnect;
  VoidCallback onSessionError;
  VoidCallback onSessionConnected;
  VoidCallback onSessionDisconnected;
  VoidCallback onSessionStreamDropped;
  VoidCallback onSessionStreamReceived;
  VoidCallback onPublisherStreamCreated;
  VoidCallback onSessionVideoReceived;
  VoidCallback onPublisherStreamDestroyed;
  VoidCallback onPublisherError;
  VoidCallback onSubscriberConnected;
  VoidCallback onSubscriberDisconnected;
  VoidCallback onSubscriberError;
  VoidCallback onPublisherAudioStarted;
  VoidCallback onPublisherVideoStarted;
  VoidCallback onPublisherAudioStopped;
  VoidCallback onPublisherVideoStopped;
  VoidCallback onSubscriberAudioStarted;
  VoidCallback onSubscriberVideoStarted;
  VoidCallback onSubscriberAudioStopped;
  VoidCallback onSubscriberVideoStopped;

  // CallHandler
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    Map values = call.arguments;

    switch (call.method) {
      case 'onWillConnect':
        if (onWillConnect != null) {
          onWillConnect();
        }
        break;

      case 'onSessionConnected':
        if (onSessionConnected != null) {
          onSessionConnected();
        }
        break;

      case 'onSessionDisconnected':
        if (onSessionDisconnected != null) {
          onSessionDisconnected();
        }
        break;

      case 'onSessionStreamDropped':
        if (onSessionStreamDropped != null) {
          onSessionStreamDropped();
        }
        break;

      case 'onSessionStreamReceived':
        if (onSessionStreamReceived != null) {
          onSessionStreamReceived();
        }
        break;

      case 'onSessionVideoReceived':
        if (onSessionVideoReceived != null) {
          onSessionVideoReceived();
        }
        break;

      case 'onSessionError':
        if (onSessionError != null) {
          onSessionError();
        }
        break;

      case 'onPublisherStreamCreated':
        if (onPublisherStreamCreated != null) {
          onPublisherStreamCreated();
        }
        break;

      case 'onPublisherStreamDestroyed':
        if (onPublisherStreamDestroyed != null) {
          onPublisherStreamDestroyed();
        }
        break;

      case 'onPublisherError':
        if (onPublisherError != null) {
          onPublisherError();
        }
        break;

      case 'onSubscriberConnected':
        if (onSubscriberConnected != null) {
          onSubscriberConnected();
        }
        break;

      case 'onSubscriberDisconnected':
        if (onSubscriberDisconnected != null) {
          onSubscriberDisconnected();
        }
        break;

      case 'onSubscriberError':
        if (onSubscriberError != null) {
          onSubscriberError();
        }
        break;

      case 'onPublisherVideoStarted':
        {
          value = value.copyWith(isPublisherVideoEnabled: true);

          if (onPublisherVideoStarted != null) {
            onPublisherVideoStarted();
          }
          break;
        }
      case 'onPublisherAudioStarted':
        {
          value = value.copyWith(isPublisherAudioEnabled: true);

          if (onPublisherAudioStarted != null) {
            onPublisherAudioStarted();
          }
          break;
        }

      case 'onPublisherVideoStopped':
        {
          value = value.copyWith(isPublisherVideoEnabled: false);

          if (onPublisherVideoStopped != null) {
            onPublisherVideoStopped();
          }
          break;
        }
      case 'onPublisherAudioStopped':
        {
          value = value.copyWith(isPublisherAudioEnabled: false);

          if (onPublisherAudioStopped != null) {
            onPublisherAudioStopped();
          }
          break;
        }

      case 'onSubscriberVideoStarted':
        {
          value = value.copyWith(isSubscriberVideoEnabled: true);

          if (onSubscriberVideoStarted != null) {
            onSubscriberVideoStarted();
          }
          break;
        }
      case 'onSubscriberAudioStarted':
        {
          value = value.copyWith(isSubscriberAudioEnabled: true);

          if (onSubscriberAudioStarted != null) {
            onSubscriberAudioStarted();
          }
          break;
        }

      case 'onSubscriberVideoStopped':
        {
          value = value.copyWith(isSubscriberVideoEnabled: false);

          if (onSubscriberVideoStopped != null) {
            onSubscriberVideoStopped();
          }
          break;
        }
      case 'onSubscriberAudioStopped':
        {
          value = value.copyWith(isSubscriberAudioEnabled: false);

          if (onSubscriberAudioStopped != null) {
            onSubscriberAudioStopped();
          }
          break;
        }

      default:
        throw MissingPluginException();
    }
  }

  void _removeMethodCallHandler() {
    _channel.setMethodCallHandler(null);
  }
}
