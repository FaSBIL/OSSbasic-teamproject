import 'package:flutter/material.dart';

// 로딩 중일 때 표시되는 인디케이터 위젯 (StatelessWidget)
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key}); // 생성자

  @override
  Widget build(BuildContext context) {
    return const Center(
      // 가운데에 로딩 인디케이터(CircularProgressIndicator) 배치
      child: CircularProgressIndicator(),
    );
  }
}
