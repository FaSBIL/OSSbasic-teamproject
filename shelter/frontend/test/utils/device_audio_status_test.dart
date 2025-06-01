import 'dart:io'; // Platform 클래스를 사용하기 위해 추가
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shelter/utils/device_audio_status.dart';

void main() {
  const MethodChannel deviceAudioChannel = MethodChannel('device_audio_status');

  setUpAll(() {
    // MethodChannel 핸들러 설정
    deviceAudioChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'getRingerMode') {
        // 호출 시마다 다른 모드를 리턴하도록 구성 가능
        return 'vibrate'; // 예시로 'vibrate' 모드 반환
      }
      return null;
    });
  });

  test('벨소리 모드 가져오기 - 정상 호출 시 모드 문자열 반환', () async {
    final mode = await DeviceAudioStatus.getRingerMode();
    expect(mode, equals('vibrate'), reason: '모의 Handler에서 vibrate를 반환하도록 설정');
  });

  test('벨소리 모드 가져오기 - 예외 발생 시 unknown 반환', () async {
    // Exception 발생하도록 채널 핸들러 변경 (await 제거)
    deviceAudioChannel.setMockMethodCallHandler((call) async {
      throw PlatformException(code: 'ERROR', message: 'Failed to get mode');
    });
    final mode = await DeviceAudioStatus.getRingerMode();
    expect(mode, equals('unknown'), reason: '예외 발생 시 "unknown"을 반환해야 함');
  });
}
