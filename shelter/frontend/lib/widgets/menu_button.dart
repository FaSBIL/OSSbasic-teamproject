import 'package:flutter/material.dart';

// 메뉴 버튼 위젯 (StatelessWidget, 상태 없음)
class MenuButton extends StatelessWidget {
  // 버튼이 눌렸을 때 실행할 콜백 함수 (필수)
  final VoidCallback onPressed;

  // 생성자: onPressed 콜백은 필수로 받아야 함
  const MenuButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8), // 버튼 주변 여백
      decoration: BoxDecoration(
        color: Colors.white, // 배경색 흰색
        borderRadius: BorderRadius.circular(12), // 모서리를 둥글게
        boxShadow: [
          // 그림자 효과 설정
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 연한 검정색 그림자
            blurRadius: 6, // 그림자 흐림 정도
            offset: const Offset(0, 2), // 아래쪽으로 살짝 그림자 위치
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.menu, size: 26), // 햄버거 메뉴 아이콘
        onPressed: onPressed, // 버튼 클릭 시 콜백 실행
      ),
    );
  }
}
