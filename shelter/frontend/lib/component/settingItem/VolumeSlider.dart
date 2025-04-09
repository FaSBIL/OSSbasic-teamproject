import 'package:flutter/material.dart';
import '../../theme/color.dart';

class VolumeSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final Color activeColor;
  final Color inactiveColor;
  final double trackHeight;

  const VolumeSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.activeColor = AppColors.blue,
    this.inactiveColor = AppColors.darkGray,
    this.trackHeight = 5.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || onChanged == null;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Row(
        children: [
          Icon(Icons.volume_mute, size: 30, color: const Color.fromARGB(79, 80, 80, 80)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: trackHeight,
                activeTrackColor: activeColor,
                inactiveTrackColor: inactiveColor.withAlpha(77),
                thumbColor: AppColors.white,
                overlayColor: AppColors.lightBlue.withAlpha(25),
              ),
              child: Slider(
                value: value,
                onChanged: isDisabled ? null : onChanged,
                min: 0.0,
                max: 1.0,
              ),
            ),
          ),
          Icon(Icons.volume_up, size: 30, color: const Color.fromARGB(79, 80, 80, 80)),
        ],
      ),
    );
  }
}