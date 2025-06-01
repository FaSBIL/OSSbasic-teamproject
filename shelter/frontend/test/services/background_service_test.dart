import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service_platform_interface/flutter_background_service_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/services/background_service.dart';
import 'package:shelter/controllers/tts_controller.dart';

class FakeAndroidServiceInstance implements AndroidServiceInstance {
  bool foregroundSet = false;
  bool notifInfoSet = false;
  bool stopped = false;
  final StreamController<void> _stopController =
      StreamController<void>.broadcast();

  @override
  Future<void> setAsForegroundService() async {
    foregroundSet = true;
  }

  @override
  Future<void> setForegroundNotificationInfo({
    required String title,
    required String content,
  }) async {
    notifInfoSet = true;
  }

  @override
  Stream<Map<String, dynamic>?> on(String event) {
    if (event == 'stopService') {
      return _stopController.stream.map<Map<String, dynamic>?>((_) => null);
    }
    return const Stream<Map<String, dynamic>?>.empty();
  }

  @override
  Future<void> stopSelf() async {
    stopped = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  void emitStopServiceEvent() {
    _stopController.add(null);
  }

  void dispose() {
    _stopController.close();
  }
}

class FakeFlutterBackgroundServicePlatform
    extends FlutterBackgroundServicePlatform {
  @override
  Future<bool> configure({
    required AndroidConfiguration androidConfiguration,
    required IosConfiguration iosConfiguration,
  }) async {
    return true;
  }

  @override
  Future<bool> start() async {
    return true;
  }

  @override
  Future<void> startService() async {
    // 아무 동작 없이 완료
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // TTSController.initTTS() 중 flutter_tts 호출 방지
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ttsChannel, (MethodCall method) async {
        return null;
      });

  // AudioSessionHandler.configureAudioSession() 중 audio_session 호출 방지
  const MethodChannel audioSessionChannel = MethodChannel('audio_session');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(audioSessionChannel, (MethodCall method) async {
        return null;
      });

  // FlutterBackgroundServicePlatform.instance를 Fake로 교체
  FlutterBackgroundServicePlatform.instance =
      FakeFlutterBackgroundServicePlatform();

  group('BackgroundService onStart 테스트', () {
    test('onStart 호출 시 포그라운드 설정 및 stopService 이벤트 대응', () async {
      final fake = FakeAndroidServiceInstance();

      onStart(fake);
      expect(fake.foregroundSet, isTrue);
      expect(fake.notifInfoSet, isTrue);

      fake.emitStopServiceEvent();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(fake.stopped, isTrue);

      fake.dispose();
    });
  });

  group('BackgroundService onServicedStart 테스트', () {
    test('onServicedStart 호출 시 예외 없이 완료', () {
      final fake = FakeAndroidServiceInstance();
      expect(() => onServicedStart(fake), returnsNormally);
      fake.dispose();
    });
  });

  group('BackgroundService initializeService 테스트', () {
    test('initializeService 호출 시 예외 없이 완료', () {
      expect(() => initializeService(), returnsNormally);
    });
  });
}
