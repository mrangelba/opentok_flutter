import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opentok_flutter/opentok_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('opentok_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await OpentokFlutter.platformVersion, '42');
  });
}
