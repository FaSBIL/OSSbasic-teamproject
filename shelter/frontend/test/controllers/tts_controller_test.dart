import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/controllers/tts_controller.dart';

void main() {
  // Flutter 테스트 바인딩 및 SharedPreferences 모킹
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('TTSController 싱글톤 동작', () {
    test('싱글톤 인스턴스 동일성 확인', () {
      final tts1 = TTSController();
      final tts2 = TTSController();
      expect(
        tts1,
        same(tts2),
        reason: 'TTSController()는 항상 같은 인스턴스를 반환해야 합니다.',
      );
    });
  });

  group('음성 활성/비활성 및 볼륨 설정', () {
    test('음성 비활성화 시 상태와 SharedPreferences 반영', () async {
      final tts = TTSController();
      // 초기값은 true(활성)라고 가정
      expect(tts.isVoiceEnabled, isTrue);

      // 음성 비활성화
      await tts.setVoiceEnabled(false);
      expect(tts.isVoiceEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('voiceEnabled'), isFalse);

      // 음성 다시 활성화
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
      // 음성 OFF 상태이므로 내부에서 바로 리턴되어야 함
      await expectLater(tts.speak('예시 텍스트'), completes);
    });

    test('음성 활성화 상태에서 speak 호출 시 예외 없이 완료', () async {
      final tts = TTSController();
      await tts.setVoiceEnabled(true);
      // 실제 플랫폼에서 TTS가 작동하지 않아도 exception이 발생하지 않아야 함
      await expectLater(tts.speak('테스트 안내입니다'), completes);
    });
  });

  group('AudioSessionHandler 테스트', () {
    test('configureAudioSession 호출 시 예외 없이 완료', () async {
      // 내부에서 PlatformException을 잡도록 구현됨
      await expectLater(AudioSessionHandler.configureAudioSession(), completes);
    });
  });
}
