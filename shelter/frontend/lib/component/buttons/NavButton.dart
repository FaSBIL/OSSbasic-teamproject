import 'package:flutter/material.dart';
import '../../theme/color.dart';

class NavButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const NavButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // 외부에서 받은 콜백 사용
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        textStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      child: Text(text),
    );
  }
}