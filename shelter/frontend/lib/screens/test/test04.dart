import 'package:flutter/material.dart';
import '../../controllers/tts_controller.dart';
import '../settings/VoiceGuideScreen.dart';

class VoiceGuideMinimalTestScreen extends StatefulWidget {
  const VoiceGuideMinimalTestScreen({super.key});

  @override
  State<VoiceGuideMinimalTestScreen> createState() => _VoiceGuideMinimalTestScreenState();
}

class _VoiceGuideMinimalTestScreenState extends State<VoiceGuideMinimalTestScreen> {
  final TTSController _ttsController = TTSController();
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _loadVoiceSetting();
  }

  Future<void> _loadVoiceSetting() async {
    await _ttsController.initTTS(); // ← 音量・音声ON/OFFの読み込み済み
    setState(() {
      _isReady = true;
    });
  }

  void _speak() async {
    if (!_ttsController.isVoiceEnabled) {
      print('[DEBUG] 음성 OFF로 재생되지 않음');
      return;
    }

    print('[DEBUG] 음성 재생을 시작함');

    await _ttsController.speak("현재 위치부터 목적지까지 안내를 시작합니다.");
  }

  void _goToSetting() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VoiceGuideScreen()),
    );

    setState(() => _isReady = false);
    await _loadVoiceSetting(); // ← 再読込
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('안내 테스트')),
      body: Center(
        child: _isReady
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.volume_up),
                    label: const Text("안내를 시작합니다"),
                    onPressed: _speak,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text("설정 화면으로"),
                    onPressed: _goToSetting,
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}