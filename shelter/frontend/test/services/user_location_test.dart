import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/services/user_location.dart';

void main() {
  const MethodChannel geoChannel = MethodChannel(
    'flutter.baseflow.com/geolocator',
  );

  setUp(() {
    // 기본 채널 핸들러 초기화 (await 제거)
    geoChannel.setMockMethodCallHandler(null);
    // SharedPreferences 초기화 (await 제거)
    SharedPreferences.setMockInitialValues({});
  });

  test('getCurrentLocation - 위치 서비스 비활성화 시 예외 발생', () async {
    // 위치 서비스 비활성화 흐름 모의 (await 제거)
    geoChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'isLocationServiceEnabled') return false;
      return null;
    });

    final service = UserLocationService();
    // 위치 서비스 비활성화 예외 검증
    await expectLater(
      service.getCurrentLocation(),
      throwsException,
      reason: '위치 서비스 비활성화 시 Exception이 throw되어야 함',
    );
  });

  test('getCurrentLocation - 정상 흐름 시 Position 반환', () async {
    // 위치 서비스 활성화 + 권한 허용 + 현재 위치 반환 모의 (await 제거)
    geoChannel.setMockMethodCallHandler((call) async {
      switch (call.method) {
        case 'isLocationServiceEnabled':
          return true;
        case 'checkPermission':
          return 2; // 권한 허용 (while in use)
        case 'getCurrentPosition':
          return {
            'latitude': 37.5,
            'longitude': 126.9,
            'timestamp': 0,
            'accuracy': 5.0,
            'altitude': 10.0,
            'heading': 0.0,
            'speed': 0.0,
            'speed_accuracy': 0.0,
          };
      }
      return null;
    });

    final service = UserLocationService();
    final position = await service.getCurrentLocation();
    expect(position.latitude, closeTo(37.5, 1e-6));
    expect(position.longitude, closeTo(126.9, 1e-6));
  });

  test('getNearestLocation - JSON 로드 실패 시 예외 처리', () async {
    final service = UserLocationService();
    try {
      await service.getNearestLocation(0.0, 0.0);
      fail('예외가 발생해야 합니다.');
    } catch (e) {
      final message = e.toString();
      expect(
        message.contains('지역명을 찾는 중 오류 발생'),
        isTrue,
        reason: 'JSON 로드 실패 시 오류 메시지를 포함해야 함',
      );
    }
  });
}
