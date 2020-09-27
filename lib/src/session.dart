import 'package:flutter/widgets.dart';

class Session {
  VoidCallback onConnected;
  void Function(String) onConnectionCreated;
  void Function(String) onConnectionDestroyed;
  VoidCallback onDisconnected;
  void Function(String) onError;
  VoidCallback onReconnected;
  VoidCallback onReconnecting;
  VoidCallback onStreamDropped;
  VoidCallback onStreamReceived;
  VoidCallback onVideoReceived;

  void setConnectedListener(VoidCallback listener) => onConnected = listener;
  void setConnectionCreatedListener(void Function(String) listener) =>
      onConnectionCreated = listener;
  void setConnectionDestroyedListener(void Function(String) listener) =>
      onConnectionDestroyed = listener;
  void setDisconnectedListener(VoidCallback listener) =>
      onDisconnected = listener;
  void setErrorListener(void Function(String) listener) => onError = listener;
  void setReconnectedListener(VoidCallback listener) => onConnected = listener;
  void setReconnectingListener(VoidCallback listener) =>
      onReconnected = listener;
  void setStreamDroppedListener(VoidCallback listener) =>
      onStreamDropped = listener;
  void setStreamReceivedListener(VoidCallback listener) =>
      onStreamReceived = listener;
  void setVideoReceivedListener(VoidCallback listener) =>
      onVideoReceived = listener;
}
