import 'package:flutter/material.dart';
import 'dart:async';

import 'package:opentok_flutter/opentok_flutter.dart';
import 'package:opentok_flutter_example/settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = OpenTokController();

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _initialize();
  }

  @override
  void dispose() {
    Wakelock.disable();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (await Permission.camera.request().isGranted) {
      print('Permission Camera');
    }

    if (await Permission.microphone.request().isGranted) {
      print('Permission Microphone');
    }

    var _publisherSettings = PublisherKitSettings(
      name: "Marcelo",
      audioTrack: true,
      videoTrack: true,
      audioBitrate: 40000,
      cameraResolution: CameraCaptureResolution.OTCameraCaptureResolutionHigh,
      cameraFrameRate: CameraCaptureFrameRate.OTCameraCaptureFrameRate30FPS,
    );

    // listeners
    _controller.session.setConnectedListener(() => print('Session connected'));
    _controller.session.setConnectionCreatedListener(
        (connectionId) => print('Session connection created => $connectionId'));
    _controller.session.setDisconnectedListener(() {});
    _controller.session
        .setErrorListener((error) => print('Session error => $error'));
    _controller.session
        .setReconnectedListener(() => print('Session reconnected'));
    _controller.session
        .setReconnectingListener(() => print('Session reconnecting'));
    _controller.session
        .setStreamDroppedListener(() => print('Session stream dropped'));
    _controller.session
        .setStreamReceivedListener(() => print('Session stream received'));
    _controller.session.setConnectionDestroyedListener((connectionId) =>
        print('Session connection destroyed => $connectionId'));
    _controller.session
        .setVideoReceivedListener(() => print('Session video received'));

    _controller.addListener(() {
      setState(() {});
    });

    await _controller.initialize(
      token: TOKEN,
      apiKey: API_KEY,
      sessionId: SESSION_ID,
      publisherSettings: _publisherSettings,
    );

    await _controller.connect();
  }

  void _togglePublisherVideo() async {
    if (_controller.value.isPublisherVideoEnabled) {
      await _controller?.publisher?.disableVideo();
    } else {
      await _controller?.publisher?.enableVideo();
    }
  }

  void _onToggleMute() async {
    if (_controller.value.isPublisherAudioEnabled) {
      await _controller?.publisher?.disableAudio();
    } else {
      await _controller?.publisher?.enableAudio();
    }
  }

  void _onSwitchCamera() async {
    await _controller?.publisher?.switchCamera();
  }

  Widget _toolbar() {
    return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: () => _togglePublisherVideo(),
              child: Icon(
                _controller.value.isPublisherVideoEnabled
                    ? Icons.videocam_off
                    : Icons.videocam,
                color: _controller.value.isPublisherVideoEnabled
                    ? Colors.blueAccent
                    : Colors.white,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: _controller.value.isPublisherVideoEnabled
                  ? Colors.white
                  : Colors.blueAccent,
              padding: const EdgeInsets.all(12.0),
            ),
            RawMaterialButton(
              onPressed: () => _onToggleMute(),
              child: Icon(
                _controller.value.isPublisherAudioEnabled
                    ? Icons.mic_off
                    : Icons.mic,
                color: _controller.value.isPublisherAudioEnabled
                    ? Colors.blueAccent
                    : Colors.white,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: _controller.value.isPublisherAudioEnabled
                  ? Colors.white
                  : Colors.blueAccent,
              padding: const EdgeInsets.all(12.0),
            ),
            RawMaterialButton(
              onPressed: () => _onSwitchCamera(),
              child: Icon(
                Icons.switch_camera,
                color: Colors.blueAccent,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  if (_controller.value.isSubscriberVideoEnabled)
                    Flexible(
                      child: SubscriberView(controller: _controller),
                      flex: 1,
                    ),
                  if (_controller.value.isPublisherVideoEnabled)
                    Flexible(
                      child: Container(
                        color: Colors.white,
                        child: Stack(
                          children: [
                            PublisherView(controller: _controller),
                            StreamBuilder<bool>(
                              stream:
                                  _controller.publisher.videoDisabledQuality,
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data) {
                                  return Positioned(
                                    top: 32,
                                    right: 16,
                                    child: Icon(
                                      Icons.signal_cellular_off,
                                      color: Colors.red,
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                            StreamBuilder<double>(
                              stream: _controller.publisher.videoBandwidth,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Positioned(
                                    top: 64,
                                    right: 16,
                                    child: Text(
                                      snapshot.data.toString(),
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                      flex: 1,
                    ),
                ],
              ),
              _toolbar(),
            ],
          ),
        ),
      ),
    );
  }
}
