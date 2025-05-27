import 'package:flutter_tts/flutter_tts.dart';

// TTS (텍스트 음성 변환) 제어용 클래스
class TTSController {
  final FlutterTts _flutterTts = FlutterTts();

  /// TTS 초기화: 언어, 속도, 볼륨, 피치 설정
  Future<void> initTTS() async {
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // 주어진 텍스트를 음성으로 읽음
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  /// 음성 재생을 중지함
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
