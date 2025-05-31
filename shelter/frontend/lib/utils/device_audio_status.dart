import 'package:flutter/services.dart';

/// Android의 AudioManager를 통해 현재 벨소리 모드(silent, vibrate, normal)를 가져옵니다.
/// iOS에서는 지원되지 않음

class DeviceAudioStatus {
  static const MethodChannel _channel = MethodChannel('device_audio_status');

  static Future<String> getRingerMode() async {
    try{
      final String mode = await _channel.invokeMethod('getRingerMode');
      return mode;
    } catch(e){
      print('[ERROR] getRingerMode 실패: $e');
      return 'unknown';
    }
  }
}