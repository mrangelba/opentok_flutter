import 'enums.dart';

class SubscriberKitSettings {
  const SubscriberKitSettings({
    this.styleVideoScale,
  });

  final StyleVideoScale styleVideoScale;

  factory SubscriberKitSettings.fromJson(Map<String, dynamic> json) =>
      SubscriberKitSettings(
        styleVideoScale: parseOTStyleVideoScale(json['styleVideoScale']),
      );

  Map<String, dynamic> toJson() => {
        'styleVideoScale': serializeOTStyleVideoScale(styleVideoScale),
      };
}
