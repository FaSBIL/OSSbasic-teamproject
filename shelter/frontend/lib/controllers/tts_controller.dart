import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TTS (텍스트 음성 변환) 제어용 클래스
class TTSController {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isVoiceEnabled = true;
  double _currentVolume = 1.0;


  /// TTS 초기화: 언어, 속도, 볼륨, 피치 설정
  Future<void> initTTS() async {
    // 저장된 상태 가져오기
    final prefs = await SharedPreferences.getInstance();
    _isVoiceEnabled = prefs.getBool('voiceEnabled') ?? true;
    _currentVolume = prefs.getDouble('ttsVolume') ?? 1.0;

    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(_currentVolume);
    await _flutterTts.setPitch(1.0);
  }

  bool get isVoiceEnabled => _isVoiceEnabled;
  double get currentVolume => _currentVolume;

  Future<void> setVoiceEnabled(bool enabled) async {
    _isVoiceEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voiceEnabled', enabled);
    if(!enabled){ await stop(); }
    print('[DEBUG] 保存完了: voiceEnabled = $enabled');
  }

  Future<void> setVolume(double volume) async {
    _currentVolume = volume;
    await _flutterTts.setVolume(volume);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ttsVolume', volume);
  }

  // 주어진 텍스트를 음성으로 읽음
  Future<void> speak(String text) async {
    if(!_isVoiceEnabled) return;
    await _flutterTts.speak(text);
  }

  /// 음성 재생을 중지함
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
