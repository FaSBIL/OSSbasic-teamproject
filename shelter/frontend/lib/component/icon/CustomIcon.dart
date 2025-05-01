import 'package:flutter/material.dart';
import '../../theme/color.dart';

class CustomIcon extends StatelessWidget {
  final IconData iconData;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final double size;
  final double borderWidth;
  final double padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool isClickable;

  const CustomIcon({
    Key? key,
    required this.iconData,
    this.color = AppColors.black,
    this.size = 25.0,
    this.onTap,
    this.isClickable = false,
    this.backgroundColor = AppColors.white,
    this.borderColor = AppColors.white,
    this.borderWidth = 0.0,
    this.padding = 6.0,
    this.borderRadius = 100.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          iconData,
          color: color,
          size: size,
        ),
      ),
    );
  }
}