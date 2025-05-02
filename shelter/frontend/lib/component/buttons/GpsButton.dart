import 'package:flutter/material.dart';
import '../../theme/color.dart';

class GpsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GpsButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.5,
      shape: const CircleBorder(),
      color: AppColors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.my_location,
            color: AppColors.lightBlue,
            size: 24.0,
          ),
        ),
      ),
    );
  }
}
