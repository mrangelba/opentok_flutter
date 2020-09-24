import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opentok_controller.dart';
import 'opentok_controller_value.dart';

class SubscriberView extends StatelessWidget {
  final OpenTokController controller;

  const SubscriberView({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OpenTokControllerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (!controller.value.isInitialized ||
            !controller.value.isSubscriberVideoEnabled) {
          return SizedBox.shrink();
        }

        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return UiKitView(
            viewType: 'plugins.flutterbr.dev/opentok_flutter/subscriber_view',
            creationParamsCodec: StandardMessageCodec(),
          );
        } else if (defaultTargetPlatform == TargetPlatform.android) {
          return AndroidView(
            viewType: 'plugins.flutterbr.dev/opentok_flutter/subscriber_view',
            creationParamsCodec: StandardMessageCodec(),
          );
        }

        return Text(
            '$defaultTargetPlatform is not yet supported by this plugin');
      },
    );
  }
}
