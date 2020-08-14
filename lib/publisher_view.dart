import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opentok_flutter/opentok_controller.dart';
import 'package:opentok_flutter/opemtok_controller_value.dart';

class PublisherView extends StatelessWidget {
  final OpenTokController controller;

  const PublisherView({Key key, @required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OpenTokControllerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (!controller.value.isInitialized ||
            !controller.value.isPublisherVideoEnabled) {
          return SizedBox.shrink();
        }

        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return UiKitView(
            viewType: 'plugins.flutterbr.dev/opentok_flutter/publisher_view',
            creationParamsCodec: StandardMessageCodec(),
          );
        } else if (defaultTargetPlatform == TargetPlatform.android) {
          return AndroidView(
            viewType: 'plugins.flutterbr.dev/opentok_flutter/publisher_view',
            creationParamsCodec: StandardMessageCodec(),
          );
        }

        return Text(
            '$defaultTargetPlatform is not yet supported by this plugin');
      },
    );
  }
}
