import 'dart:io'; // Platform 클래스를 사용하기 위해 추가
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/controllers/tts_controller.dart';
import 'package:shelter/utils/device_audio_status.dart';

void main() {
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');
  const MethodChannel audioSessionChannel = MethodChannel('audio_session');
  const MethodChannel deviceAudioChannel = MethodChannel('device_audio_status');

  // 플래그 및 기록 변수
  bool ttsSpeakCalled = false;
  bool ttsStopCalled = false;
  String? ttsSpeakText;
  double? ttsSetVolume;
  bool audioSessionConfigured = false;
  String? deviceRingerMode;

  setUpAll(() {
    // 공통 채널 핸들러 세팅
    ttsChannel.setMockMethodCallHandler((call) async {
      switch (call.method) {
        case 'speak':
          ttsSpeakCalled = true;
          ttsSpeakText = call.arguments as String;
          return 1;
        case 'stop':
          ttsStopCalled = true;
          return 1;
        case 'setVolume':
          ttsSetVolume = call.arguments as double;
          return 1;
        case 'setLanguage':
        case 'setSpeechRate':
        case 'setPitch':
          return 1;
      }
      return null;
    });

    audioSessionChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'configureAudioSession') {
        audioSessionConfigured = true;
      }
      return true;
    });

    deviceAudioChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'getRingerMode') {
        return deviceRingerMode ?? 'normal';
      }
      return 'unknown';
    });
  });

  setUp(() {
    // 각 테스트 시작 시 상태 초기화
    ttsSpeakCalled = false;
    ttsStopCalled = false;
    ttsSpeakText = null;
    ttsSetVolume = null;
    audioSessionConfigured = false;
    deviceRingerMode = 'normal';
    // SharedPreferences 초기화
    SharedPreferences.setMockInitialValues({});
  });

  test('initTTS 호출 시 SharedPreferences 로드 및 초기값 설정 확인', () async {
    // 사전 설정: 저장된 음성 안내 설정값 정의
    SharedPreferences.setMockInitialValues({
      'voiceEnabled': false,
      'ttsVolume': 0.3,
      'allowVoiceInSilentMode': true,
    });
    final tts = TTSController();
    await tts.initTTS();

    // SharedPreferences 값들이 TTSController 내부 필드에 반영되었는지 확인
    expect(tts.isVoiceEnabled, isFalse);
    expect(tts.currentVolume, closeTo(0.3, 1e-6));
    expect(tts.allowVoiceInSilentMode, isTrue);

    // 플러그인 메소드 호출 확인
    expect(
      ttsSetVolume,
      equals(0.3),
      reason: '초기 볼륨 설정 0.3이 FlutterTts에 전달되어야 함',
    );
    expect(audioSessionConfigured, isTrue, reason: '오디오 세션 설정이 호출되어야 함');
  });

  test('setVoiceEnabled(false) 시 설정값 저장 및 음성 중지 호출', () async {
    final tts = TTSController();
    SharedPreferences.setMockInitialValues({'voiceEnabled': true});

    // 현재 음성 안내가 켜져있는 상태에서 끄기
    await tts.setVoiceEnabled(false);
    expect(tts.isVoiceEnabled, isFalse);

    // SharedPreferences에 저장되었는지 확인
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('voiceEnabled'), isFalse);

    // 음성 재생 중지(stop) 호출되었는지 확인
    expect(ttsStopCalled, isTrue);
  });

  test('setVolume 호출 시 볼륨 값 적용 및 저장', () async {
    final tts = TTSController();
    await tts.setVolume(0.8);

    // 내부 currentVolume 값 갱신 확인
    expect(tts.currentVolume, 0.8);

    // SharedPreferences에 저장되었는지 확인
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('ttsVolume'), 0.8);

    // FlutterTts.setVolume 호출되었는지 확인
    expect(ttsSetVolume, equals(0.8));
  });

  test('setAllowVoiceInSilentMode 호출 시 설정값 저장', () async {
    final tts = TTSController();
    await tts.setAllowVoiceInSilentMode(true);

    expect(tts.allowVoiceInSilentMode, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('allowVoiceInSilentMode'), isTrue);
  });

  test('백그라운드 설정 로드/저장 함수 동작 확인', () async {
    final tts = TTSController();

    // loadBackgroundSetting
    SharedPreferences.setMockInitialValues({'isBackgroundEnabled': true});
    await tts.loadBackgroundSetting();
    expect(tts.isBackgroundEnabled, isTrue);

    // saveBackgroundSetting
    await tts.saveBackgroundSetting(false);
    expect(tts.isBackgroundEnabled, isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isBackgroundEnabled'), isFalse);
  });

  test('음성 안내 speak() 동작 - 음성 OFF 상태에서는 호출되지 않음', () async {
    final tts = TTSController();
    tts.setVoiceEnabled(false);

    await tts.speak('테스트');
    expect(
      ttsSpeakCalled,
      isFalse,
      reason: '음성 안내가 비활성화 상태이므로 speak 호출되지 않아야 함',
    );
  });

  test('음성 안내 speak() 동작 - 무음모드 시 허용되지 않았으면 호출되지 않음', () async {
    final tts = TTSController();

    // 음성 안내 ON, 무음모드 허용 X, 현재 기기 모드를 'silent'(무음)로 설정
    await tts.setVoiceEnabled(true);
    await tts.setAllowVoiceInSilentMode(false);
    deviceRingerMode = 'silent';

    await tts.speak('테스트 음성');

    // 테스트 환경에서는 Platform.isAndroid 여부에 상관없이
    // deviceRingerMode가 'silent'이고 allowVoiceInSilentMode=false면 speak 호출이 스킵되어야 함
    expect(
      ttsSpeakCalled,
      isFalse,
      reason: '무음 모드이고 음성안내 허용 안함 조건에서는 speak 호출되지 않아야 함',
    );
  });

  test('음성 안내 speak() 동작 - 정상 조건에서 TTS speak 호출', () async {
    final tts = TTSController();

    await tts.setVoiceEnabled(true);
    deviceRingerMode = 'normal'; // 일반 모드

    await tts.speak('Hello World');
    expect(ttsSpeakCalled, isTrue);
    expect(ttsSpeakText, 'Hello World');
  });

  test('stop() 호출 시 TTS 정지 명령 전송', () async {
    final tts = TTSController();

    // 임의로 speakCalled 리셋 후 stop 호출
    ttsStopCalled = false;
    await tts.stop();
    expect(
      ttsStopCalled,
      isTrue,
      reason: 'stop() 호출 시 flutter_tts.stop()이 실행되어야 함',
    );
  });
}
