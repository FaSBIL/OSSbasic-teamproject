import 'package:flutter/material.dart';

/// 📌 안내 시작 버튼 위젯
/// 사용자가 누르면 안내를 시작하는 동작을 수행함
class GuideStartButton extends StatelessWidget {
  // 버튼 클릭 시 실행될 콜백 함수 (필수)
  final VoidCallback onPressed;

  // 생성자: onPressed는 필수 매개변수
  const GuideStartButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // 버튼 클릭 시 콜백 함수 실행
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // 버튼 배경색: 파란색
        foregroundColor: Colors.white, // 버튼 텍스트 색상: 흰색
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // 모서리 둥글게
        ),
        minimumSize: const Size(double.infinity, 48), // 가로는 최대, 세로는 48
      ),
      child: const Text(
        "안내 시작", // 버튼에 표시될 텍스트
        style: TextStyle(
          fontSize: 16, // 텍스트 크기
          fontWeight: FontWeight.bold, // 텍스트 굵게
        ),
      ),
    );
  }
}
