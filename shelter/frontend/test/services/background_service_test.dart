import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shelter/services/background_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

// DummyAndroidServiceInstance: AndroidServiceInstance의 추상 메서드를 모두 구현
class DummyAndroidServiceInstance implements AndroidServiceInstance {
  bool setForegroundCalled = false;
  String? notifTitle;
  String? notifContent;
  bool stopSelfCalled = false;

  // stopService 이벤트를 흉내내기 위한 스트림 컨트롤러
  final StreamController<Map<String, dynamic>?> stopController =
      StreamController<Map<String, dynamic>?>.broadcast();

  @override
  Future<void> setAsForegroundService() async {
    setForegroundCalled = true;
  }

  @override
  Future<void> setForegroundNotificationInfo({
    required String title,
    required String content,
  }) async {
    notifTitle = title;
    notifContent = content;
  }

  @override
  Stream<Map<String, dynamic>?> on(String event) {
    if (event == 'stopService') {
      return stopController.stream;
    }
    return Stream<Map<String, dynamic>?>.value(null);
  }

  @override
  Future<void> stopSelf() async {
    stopSelfCalled = true;
  }

  @override
  Future<dynamic> invoke(String method, [dynamic args]) async {
    return null;
  }

  @override
  Future<bool> isForegroundService() async => true;

  @override
  Future<bool> openApp() async => true;

  @override
  Future<void> setAsBackgroundService() async {}

  @override
  Future<void> setAutoStartOnBootMode(bool enabled) async {}
}

void main() {
  setUpAll(() {
    // TTSController.initTTS 호출 시 flutter_tts 채널에서 에러가 나지 않도록 모의 설정
    const MethodChannel ttsChannel = MethodChannel('flutter_tts');
    ttsChannel.setMockMethodCallHandler((_) async => 1);
  });

  test('onStart: Android 포그라운드 서비스 설정 및 stopService 이벤트 처리', () async {
    final dummy = DummyAndroidServiceInstance();

    // onStart 호출 (동기 void 함수이므로 await 제거)
    onStart(dummy);

    // 포그라운드 서비스로 전환되었는지 확인
    expect(dummy.setForegroundCalled, isTrue);
    expect(dummy.notifTitle, isNotNull, reason: '포그라운드 알림 타이틀이 설정되어야 합니다.');
    expect(dummy.notifContent, isNotNull, reason: '포그라운드 알림 내용이 설정되어야 합니다.');

    // stopService 이벤트를 발생시켜 stopSelf()가 호출되는지 검사
    dummy.stopController.add({'dummy': 'data'});
    await Future.delayed(const Duration(milliseconds: 50));
    expect(
      dummy.stopSelfCalled,
      isTrue,
      reason: 'stopService 이벤트 수신 시 stopSelf()가 호출되어야 합니다.',
    );
  });

  test('initializeService: FlutterBackgroundService 구성 및 시작 호출', () async {
    // FlutterBackgroundService.configure와 startService 호출 검증을 위한 모의 채널
    const MethodChannel serviceChannel = MethodChannel(
      'id.flutter/background_service',
    );
    bool configured = false;
    bool started = false;

    serviceChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'configure') {
        configured = true;
      }
      if (call.method == 'start') {
        started = true;
      }
      return true;
    });

    // 실제로 서비스 초기화 함수 호출
    await initializeService();

    expect(configured, isTrue, reason: '서비스 configure()가 호출되어야 합니다.');
    expect(started, isTrue, reason: '서비스 start()가 호출되어야 합니다.');
  });
}
