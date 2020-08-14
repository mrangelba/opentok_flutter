/// The state of a [OpenTokController].
class OpenTokControllerValue {
  const OpenTokControllerValue({
    this.isInitialized,
    this.isConnected,
    this.isPublisherVideoEnabled,
    this.isSubscriberVideoEnabled,
    this.isPublisherAudioEnabled,
    this.isSubscriberAudioEnabled,
  });

  const OpenTokControllerValue.uninitialized()
      : this(
          isInitialized: false,
          isConnected: false,
          isPublisherVideoEnabled: false,
          isSubscriberVideoEnabled: false,
          isPublisherAudioEnabled: false,
          isSubscriberAudioEnabled: false,
        );

  final bool isInitialized;
  final bool isConnected;
  final bool isPublisherVideoEnabled;
  final bool isSubscriberVideoEnabled;
  final bool isPublisherAudioEnabled;
  final bool isSubscriberAudioEnabled;

  OpenTokControllerValue copyWith({
    bool isInitialized,
    bool isConnected,
    bool isPublisherVideoEnabled,
    bool isSubscriberVideoEnabled,
    bool isPublisherAudioEnabled,
    bool isSubscriberAudioEnabled,
  }) {
    return OpenTokControllerValue(
      isInitialized: isInitialized ?? this.isInitialized,
      isConnected: isConnected ?? this.isConnected,
      isPublisherVideoEnabled:
          isPublisherVideoEnabled ?? this.isPublisherVideoEnabled,
      isSubscriberVideoEnabled:
          isSubscriberVideoEnabled ?? this.isSubscriberVideoEnabled,
      isPublisherAudioEnabled:
          isPublisherAudioEnabled ?? this.isPublisherAudioEnabled,
      isSubscriberAudioEnabled:
          isSubscriberAudioEnabled ?? this.isSubscriberAudioEnabled,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'isInitialized: $isInitialized)';
  }
}
