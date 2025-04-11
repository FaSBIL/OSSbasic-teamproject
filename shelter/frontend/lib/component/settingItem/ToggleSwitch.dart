import 'package:flutter/material.dart';
import '../../theme/color.dart';

class ToggleSwitch extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final Duration animationDuration;


  const ToggleSwitch({
    Key? key,
    required this.isOn,
    this.onChanged,
    this.width = 55,
    this.height = 35,
    this.activeColor = AppColors.blue,
    this.inactiveColor = AppColors.lightGray,
    this.animationDuration = const Duration(milliseconds: 200),
  }) :super(key: key);

  @override
  Widget build(BuildContext context){
    final bool isDisable = onChanged == null;

    return GestureDetector(
      onTap: isDisable ? null : () => onChanged!(!isOn),
      child: AnimatedContainer(
        duration: animationDuration,
        width:  width,
        height: height,
        padding: const EdgeInsets.all(4),
        decoration:  BoxDecoration(
          color: isOn ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: AnimatedAlign(
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          duration: animationDuration,
          curve: Curves.easeInOut,
          child: Container(
            width : height - 8,
            height : height - 8,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          )
        ),
      ),
    );
  }
}