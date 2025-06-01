import 'dart:async';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

/// AndroidServiceInstance 인터페이스에 맞춰 시그니처를 수정한 Fake 구현
class FakeAndroidServiceInstance implements AndroidServiceInstance {
  bool foregroundSet = false;
  bool notifInfoSet = false;
  bool stopped = false;

  // stopService 이벤트를 받을 StreamController
  final StreamController<void> _stopController =
      StreamController<void>.broadcast();

  @override
  Future<void> setAsForegroundService() async {
    // 원래는 안드로이드의 setAsForegroundService()를 호출하지만,
    // Fake에서는 단순히 상태 플래그만 토글
    foregroundSet = true;
  }

  @override
  Future<void> setForegroundNotificationInfo({
    required String title,
    required String content,
  }) async {
    // Fake에서는 단순히 상태 플래그만 토글
    notifInfoSet = true;
  }

  @override
  Stream<Map<String, dynamic>?> on(String event) {
    // 인터페이스 정의에 따라, Map<String, dynamic>? 타입의 Stream을 리턴해야 함
    // 'stopService' 이벤트일 때 우리가 만든 Controller를 통해 신호를 보냄
    if (event == 'stopService') {
      // 스트림이 emit하는 데이터는 Map<String, dynamic>? 형태여야 하므로
      // _stopController.stream이 void 데이터를 방출하므로, map을 한 번 걸어서
      // null(Map<String, dynamic>?)로 바꿔줌
      return _stopController.stream.map<Map<String, dynamic>?>((_) => null);
    }
    // 그 외 이벤트는 빈 스트림 반환
    return const Stream<Map<String, dynamic>?>.empty();
  }

  @override
  Future<void> stopSelf() async {
    // Fake에서는 단순히 상태 플래그만 토글
    stopped = true;
  }

  // 더미로 구현하거나 사용하지 않는 나머지 멤버는 noSuchMethod로 처리
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  /// 테스트 코드에서 Stream에 이벤트를 넣어주기 위한 헬퍼 메서드
  void emitStopServiceEvent() {
    _stopController.add(null);
  }

  /// 테스트가 끝나고 Controller를 닫아주기 위한 헬퍼
  void dispose() {
    _stopController.close();
  }
}
