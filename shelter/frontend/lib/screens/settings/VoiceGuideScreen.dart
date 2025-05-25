import 'package:flutter/material.dart';
import '../../services/voice_service.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../../component/settingItem/ToggleSwitch.dart';
import '../../component/settingItem/VolumeSlider.dart';

class VoiceGuideScreen extends StatefulWidget {
  const VoiceGuideScreen({super.key});

  @override
  State<VoiceGuideScreen> createState() => _VoiceGuideScreenState();
}

class _VoiceGuideScreenState extends State<VoiceGuideScreen> {
  bool isVoiceGuideOn = true;
  bool isMutedModeOn = false;
  double volume = 0.5;

  final VoiceService voiceService = VoiceService();

  @override
  void initState(){
    super.initState();
    voiceService.initialize().then((_){
      voiceService.setVolume(volume);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white(context),
      appBar: AppBar(
        backgroundColor: AppColors.white(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.black(context)),
        title: Text('음성 안내', style: AppTextStyles.title(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('음성 안내', style: AppTextStyles.subtitle(context)),
                ToggleSwitch(
                  isOn: isVoiceGuideOn,
                  onChanged:(value) {
                    setState((){
                      isVoiceGuideOn = value;
                    });

                    if(!value) {
                      voiceService.stop(); // OFF시 불러오기 중단
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '음소거 시에도 음성 경보를 켜기',
                    style: AppTextStyles.subtitle(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ToggleSwitch(
                  isOn: isMutedModeOn,
                  onChanged: (value){
                    isMutedModeOn = value;
                  }
                ),
              ],
            ),
            const SizedBox(height: 32),

            Text('음량 조절', style: AppTextStyles.subtitle(context)),
            const SizedBox(height: 12),

            VolumeSlider(
              value: volume,
              enabled: isVoiceGuideOn,
              onChanged: (value) {
                setState((){
                  volume = value;
                });
                voiceService.setVolume(value);
                voiceService.speak("안내를 시작합니다"); // 시험 음성
              },
            ),
          ],
        ),
      ),
    );
  }
}
