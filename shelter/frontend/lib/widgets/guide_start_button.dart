import 'package:flutter/material.dart';

/// 📌 안내 시작 버튼 위젯
class GuideStartButton extends StatelessWidget {
  final VoidCallback onPressed; // 버튼 클릭 시 실행할 함수

  const GuideStartButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // 실제 안내 기능 연결
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: const Text(
        "안내 시작",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
