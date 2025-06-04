import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../../component/settingItem/ToggleSwitch.dart';
import '../../component/settingItem/VolumeSlider.dart';
import '../../controllers/tts_controller.dart';
import 'dart:io';

class VoiceGuideScreen extends StatefulWidget {
  const VoiceGuideScreen({super.key});

  @override
  State<VoiceGuideScreen> createState() => _VoiceGuideScreenState();
}

class _VoiceGuideScreenState extends State<VoiceGuideScreen> {
  final TTSController _ttsController = TTSController();

  bool isVoiceGuideOn = true;
  bool isLoading = true;
  bool isMutedModeOn = false;
  double volume = 0.5;

  @override
  void initState(){
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async{
    try {
    await _ttsController.initTTS().timeout(
      const Duration(seconds : 5),
      onTimeout: () {
        print("Android TTS 초기화가 time out 됨");
        return;
      },
    );
    } catch(e) {
      print("TTS 초기화 error : $e");
    }
    setState((){
      isVoiceGuideOn = _ttsController.isVoiceEnabled;
      volume = _ttsController.currentVolume;
      isMutedModeOn = _ttsController.allowVoiceInSilentMode;
      isLoading = false;
    });
  }

  void _onVoiceToggle(bool value) async{
    setState(() => isVoiceGuideOn = value);
    await _ttsController.setVoiceEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text('음성 안내', style: AppTextStyles.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('음성 안내', style: AppTextStyles.subtitle),
                isLoading
                  ? CircularProgressIndicator()
                  : ToggleSwitch(
                    isOn: isVoiceGuideOn,
                    onChanged: _onVoiceToggle,
                  ),
              ],
            ),
            const SizedBox(height: 20),

            Platform.isAndroid
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '음소거 시에도 음성 경보를 켜기',
                            style: AppTextStyles.subtitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ToggleSwitch(
                          isOn: isMutedModeOn,
                          onChanged: (value) async {
                            await _ttsController.setAllowVoiceInSilentMode(value);
                            setState(() => isMutedModeOn = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                )
              : const SizedBox.shrink(),

            const Text('음량 조절', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),

            VolumeSlider(
              value: volume,
              onChanged: (value) async {
                if(!isVoiceGuideOn) return;
                setState(() => volume = value);
                await _ttsController.setVolume(value);
                await _ttsController.speak("안내를 시작합니다.");
              },
              enabled: isVoiceGuideOn,
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 8),
            const Text(
              '일부 기기에서는 음소거 상태와 관계없이 음성이 항상 재생될 수 있습니다.',
              style: AppTextStyles.bodyGray
            ),
          ],
        ),
      ),
    );
  }
}
