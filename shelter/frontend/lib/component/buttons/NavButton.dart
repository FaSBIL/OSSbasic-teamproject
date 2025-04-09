import 'package:flutter/material.dart';
import '../../theme/color.dart';

class NavButton extends StatelessWidget {
  final String text;

  const NavButton({
    Key? key,
    required this.text,
  }) : super(key: key);

  void _handleNavPress(){
    // 안내 시작 버튼 클릭 시 처리 로직 구현 예정
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handleNavPress,
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