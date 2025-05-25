import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5); //잃기 속도
    await _tts.setVolume(0.5); // 초기 음량
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume); // 0.0 ~ 1.0
  }
}