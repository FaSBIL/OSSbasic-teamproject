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
                overlayColor: AppColors.lightGray.withAlpha(50),
                thumbShape: const _CustomThumbShape(),
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

class _CustomThumbShape extends SliderComponentShape {
  const _CustomThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(28, 28);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) {
    final canvas = context.canvas;

    canvas.drawCircle(
      center.translate(0, 2),
      14,
      Paint()
        ..color = Colors.black.withAlpha(40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawCircle(
      center,
      12,
      Paint()..color = Colors.white,
    );
  }
}

