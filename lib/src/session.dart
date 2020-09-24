import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Session {
  final MethodChannel _channel;

  VoidCallback onConnected;
  VoidCallback onConnectionCreated;
  VoidCallback onConnectionDestroyed;
  VoidCallback onDisconnected;
  void Function(String) onError;
  VoidCallback onReconnected;
  VoidCallback onReconnecting;
  VoidCallback onStreamDropped;
  VoidCallback onStreamReceived;
  VoidCallback onVideoReceived;

  Session(this._channel);

  void setConnectedListener(VoidCallback listener) => onConnected = listener;
  void setConnectionCreatedListener(VoidCallback listener) =>
      onConnectionCreated = listener;
  void setDisconnectedListener(VoidCallback listener) =>
      onDisconnected = listener;
  void setErrorListener(void Function(String) listener) => onError = listener;
  void setonConnectionDestroyedListener(VoidCallback listener) =>
      onConnectionDestroyed = listener;
  void setonVideoReceivedListener(VoidCallback listener) =>
      onVideoReceived = listener;
  void setReconnectedListener(VoidCallback listener) => onConnected = listener;
  void setReconnectingListener(VoidCallback listener) =>
      onReconnected = listener;
  void setStreamDroppedListener(VoidCallback listener) =>
      onStreamDropped = listener;
  void setStreamReceivedListener(VoidCallback listener) =>
      onStreamReceived = listener;
}
