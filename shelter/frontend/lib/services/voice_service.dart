import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  bool isMutedModeEnabled = false; //음소거 시에도 재생 여부
  bool _isEnabled = true;          // 음성 안내 전체 ON/OFF 제어용
  bool _isMuted = false;           // 현재 디바이스가 음소거 상태라고 가정 (실제連携には別途設定が必要)
  double _volume = 0.5;            // 현재 음량 값

  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5); //잃기 속도
    await _tts.setVolume(0.5); // 초기 음량
  }

  Future<void> speak(String text) async {
    if(!_isEnabled) return;
    if(_isMuted & !isMutedModeEnabled) return;

    await _tts.setVolume(_volume);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _tts.setVolume(volume); // 0.0 ~ 1.0
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  void setMuted(bool muted) {
    _isMuted = muted;
  }
}