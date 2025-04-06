import 'package:flutter/material.dart';

// 검색창 위젯 (StatelessWidget으로 상태 없음)
class SearchBarWidget extends StatelessWidget {
  // 텍스트 입력이 바뀔 때 실행되는 콜백 함수 (nullable)
  final Function(String)? onChanged;

  // 생성자: onChanged 콜백을 선택적으로 받음
  const SearchBarWidget({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged, // 입력이 변경될 때 onChanged 콜백 실행
      decoration: InputDecoration(
        hintText: '대피소 검색', // 입력창 힌트 텍스트
        prefixIcon: const Icon(Icons.search), // 검색 아이콘
        filled: true, // 배경 채우기 설정
        fillColor: Colors.white, // 배경색 흰색
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 0,
        ), // 내부 여백 설정
        // 비활성 상태일 때 테두리
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),

        // 입력 중일 때 테두리
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}
