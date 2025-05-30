import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

// TTS (텍스트 음성 변환) 제어용 클래스
class TTSController {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isVoiceEnabled = true;
  double _currentVolume = 1.0;
  bool _allowVoiceInSilentMode = false;


  /// TTS 초기화: 언어, 속도, 볼륨, 피치 설정
  Future<void> initTTS() async {
    // 저장된 상태 가져오기
    final prefs = await SharedPreferences.getInstance();
    _isVoiceEnabled = prefs.getBool('voiceEnabled') ?? true;
    _currentVolume = prefs.getDouble('ttsVolume') ?? 1.0;
    _allowVoiceInSilentMode = prefs.getBool('allowVoiceInSilentMode') ?? false;

    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(_currentVolume);
    await _flutterTts.setPitch(1.0);
  }

  bool get isVoiceEnabled => _isVoiceEnabled;
  double get currentVolume => _currentVolume;
  bool get allowVoiceInSilentMode => _allowVoiceInSilentMode;

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

  Future<void> setAllowVoiceInSilentMode(bool allowed) async {
    _allowVoiceInSilentMode = allowed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allowVoiceInSilentMode', allowed);
  }

  // 주어진 텍스트를 음성으로 읽음
  Future<void> speak(String text) async {
    if(!_isVoiceEnabled) return;
    if(!_allowVoiceInSilentMode){
      // Android: 사일런트 모드인지 체크(Platform Channel)
      // iOS: 체크불능 → 항상재생 or skip 2택
      if(await _isInSilentMode()){
      print('[DEBUG]매너 모드 중이므로 건너뛰기');
      return;
      }
    }
    await _flutterTts.speak(text);
  }

  /// 음성 재생을 중지함
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<bool> _isInSilentMode() async {
    if(Platform.isAndroid) {
      final mode = await DeviceAudioStatus.getRingerMode();
      return mode == 'silent' || mode == 'vibrate';
    } else if (Platform.isIOS) {
      // iOS에서는 취득할 수 없기 때문에 false를 반환합니다(즉, 항상 재생가능하다고 판단)
      return false;
    }
    return false;
  }
}
