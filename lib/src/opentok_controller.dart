import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'opentok_controller_value.dart';
import 'opentok_publisher_kit_settings.dart';
import 'opentok_subscriber_kit_settings.dart';
import 'publisher.dart';
import 'session.dart';
import 'subscriber.dart';

class OpenTokController extends ValueNotifier<OpenTokControllerValue> {
  static const _channel =
      const MethodChannel('plugins.flutterbr.dev/opentok_flutter');

  OpenTokController() : super(const OpenTokControllerValue.uninitialized()) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  final session = Session(_channel);
  final subscriber = Subscriber(_channel);
  final publisher = Publisher(_channel);

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
    try {
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
    } catch (e) {
      print(e);
    }
  }

  Future<bool> connect() async {
    try {
      var result = await _channel.invokeMethod('connect');

      value = value.copyWith(isConnected: result);

      return result;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      var result = await _channel.invokeMethod('disconnect');

      value = value.copyWith(isConnected: false);

      return result;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Destroys the instance and releases all resources used by the OpenTok SDK.
  ///
  /// This method is useful for apps that occasionally make voice or video calls, to free up resources for other operations when not making calls.
  /// Once the app calls destroy to destroy the created instance, you cannot use any method or callback in the SDK.
  @override
  Future<void> dispose() async {
    try {
      await disconnect();

      _removeMethodCallHandler();
    } catch (e) {
      print(e);
    }

    super.dispose();
  }

  VoidCallback onWillConnect;

  // CallHandler
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onWillConnect':
        if (onWillConnect != null) {
          onWillConnect();
        }
        break;

      case 'onSessionConnected':
        if (session.onConnected != null) {
          session.onConnected();
        }
        break;

      case 'onSessionDisconnected':
        if (session.onDisconnected != null) {
          session.onDisconnected();
        }
        break;

      case 'onSessionStreamDropped':
        if (session.onStreamDropped != null) {
          session.onStreamDropped();
        }
        break;

      case 'onSessionStreamReceived':
        if (session.onStreamReceived != null) {
          session.onStreamReceived();
        }
        break;

      case 'onSessionVideoReceived':
        if (session.onVideoReceived != null) {
          session.onVideoReceived();
        }
        break;

      case 'onSessionError':
        if (session.onError != null) {
          session.onError(call.arguments);
        }
        break;

      case 'onPublisherStreamCreated':
        if (publisher.onStreamCreated != null) {
          publisher.onStreamCreated();
        }
        break;

      case 'onPublisherStreamDestroyed':
        if (publisher.onStreamDestroyed != null) {
          publisher.onStreamDestroyed();
        }
        break;

      case 'onPublisherError':
        if (publisher.onError != null) {
          publisher.onError(call.arguments);
        }
        break;

      case 'onSubscriberConnected':
        if (subscriber.onConnected != null) {
          subscriber.onConnected();
        }
        break;

      case 'onSubscriberDisconnected':
        if (subscriber.onDisconnected != null) {
          subscriber.onDisconnected();
        }
        break;

      case 'onSubscriberError':
        if (subscriber.onError != null) {
          subscriber.onError(call.arguments);
        }
        break;

      case 'onPublisherVideoStarted':
        {
          value = value.copyWith(isPublisherVideoEnabled: true);

          if (publisher.onVideoStarted != null) {
            publisher.onVideoStarted();
          }
          break;
        }
      case 'onPublisherAudioStarted':
        {
          value = value.copyWith(isPublisherAudioEnabled: true);

          if (publisher.onAudioStarted != null) {
            publisher.onAudioStarted();
          }
          break;
        }

      case 'onPublisherVideoStopped':
        {
          value = value.copyWith(isPublisherVideoEnabled: false);

          if (publisher.onVideoStopped != null) {
            publisher.onVideoStopped();
          }
          break;
        }
      case 'onPublisherAudioStopped':
        {
          value = value.copyWith(isPublisherAudioEnabled: false);

          if (publisher.onAudioStopped != null) {
            publisher.onAudioStopped();
          }
          break;
        }

      case 'onSubscriberVideoStarted':
        {
          value = value.copyWith(isSubscriberVideoEnabled: true);

          if (subscriber.onVideoStarted != null) {
            subscriber.onVideoStarted();
          }
          break;
        }
      case 'onSubscriberAudioStarted':
        {
          value = value.copyWith(isSubscriberAudioEnabled: true);

          if (subscriber.onAudioStarted != null) {
            subscriber.onAudioStarted();
          }
          break;
        }

      case 'onSubscriberVideoStopped':
        {
          value = value.copyWith(isSubscriberVideoEnabled: false);

          if (subscriber.onVideoStopped != null) {
            subscriber.onVideoStopped();
          }
          break;
        }
      case 'onSubscriberAudioStopped':
        {
          value = value.copyWith(isSubscriberAudioEnabled: false);

          if (subscriber.onAudioStopped != null) {
            subscriber.onAudioStopped();
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
