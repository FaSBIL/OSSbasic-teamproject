import 'package:flutter/material.dart';
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
                ToggleSwitch(
                  isOn: isVoiceGuideOn,
                  onChanged: (value) => setState(() => isVoiceGuideOn = value),
                ),
              ],
            ),
            const SizedBox(height: 20),

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
                  onChanged: (value) => setState(() => isMutedModeOn = value),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text('음량 조절', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),

            VolumeSlider(
              value: volume,
              onChanged: (value) => setState(() => volume = value),
              enabled: isVoiceGuideOn,
            ),
          ],
        ),
      ),
    );
  }
}
