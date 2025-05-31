import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../controllers/tts_controller.dart';

void onServicedStart(ServiceInstance service) async{
  final tts = TTSController();
  await tts.initTTS();
}

void onStart(ServiceInstance service) {
  // Android에만 통지 표시를 유지
  if(service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "안내 서비스 실행 중",
      content: "앱이 닫혀도 계속 안내됩니다",
    );
  }

  // 음성 내비게이션을 시작하거나 반복 처리 추가 가능
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

Future<void> initializeService() async{
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false, //사용자가 전환할 경우 false
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: '안내 서비스 실행 중',
      initialNotificationContent: '앱이 닫혀도 계속 안내됩니다',
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: (service) async => true,
    )
  );

  await service.startService();
}