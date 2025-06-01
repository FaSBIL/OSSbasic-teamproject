import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/controllers/tts_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // flutter_tts 채널 모킹
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ttsChannel, (MethodCall method) async {
        return null;
      });

  // audio_session 채널 모킹
  const MethodChannel audioSessionChannel = MethodChannel('audio_session');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(audioSessionChannel, (MethodCall method) async {
        return null;
      });

  group('TTSController 싱글톤 동작', () {
    test('싱글톤 인스턴스 동일성 확인', () {
      final tts1 = TTSController();
      final tts2 = TTSController();
      expect(tts1, same(tts2));
    });
  });

  group('음성 활성/비활성 및 볼륨 설정', () {
    test('음성 비활성화 시 상태와 SharedPreferences 반영', () async {
      final tts = TTSController();
      expect(tts.isVoiceEnabled, isTrue);

      await tts.setVoiceEnabled(false);
      expect(tts.isVoiceEnabled, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('voiceEnabled'), isFalse);

      await tts.setVoiceEnabled(true);
      expect(tts.isVoiceEnabled, isTrue);
      expect(prefs.getBool('voiceEnabled'), isTrue);
    });

    test('볼륨 설정 시 내부 상태 및 SharedPreferences 반영', () async {
      final tts = TTSController();
      await tts.setVolume(0.75);
      expect(tts.currentVolume, closeTo(0.75, 1e-6));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('ttsVolume'), 0.75);
    });
  });

  group('speak() 호출 동작', () {
    test('음성 비활성화 상태에서 speak 호출 시 예외 없이 완료', () async {
      final tts = TTSController();
      await tts.setVoiceEnabled(false);
      await expectLater(tts.speak('예시 텍스트'), completes);
    });

    test('음성 활성화 상태에서 speak 호출 시 예외 없이 완료', () async {
      final tts = TTSController();
      await tts.setVoiceEnabled(true);
      await expectLater(tts.speak('테스트 안내입니다'), completes);
    });
  });

  group('AudioSessionHandler 테스트', () {
    test('configureAudioSession 호출 시 예외 없이 완료', () async {
      await expectLater(AudioSessionHandler.configureAudioSession(), completes);
    });
  });
}
