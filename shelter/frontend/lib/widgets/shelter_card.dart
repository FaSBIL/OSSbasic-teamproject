import 'package:flutter/material.dart'; // Flutter의 기본 UI 위젯들을 사용하기 위해 material 패키지를 가져옴

/// ShelterCard: 대피소 정보를 보여주는 카드 UI 컴포넌트 (아이콘 제거, 테두리 포함)
class ShelterCard extends StatelessWidget {
  // 카드에 표시할 대피소의 이름, 주소, 거리 정보를 외부에서 받아옴
  final String name;
  final String address;
  final String distance;

  // 생성자: 세 개의 필수 매개변수를 받아야 함 (required)
  const ShelterCard({
    super.key,
    required this.name,
    required this.address,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // 화면 너비의 90%로 지정
      constraints: const BoxConstraints(
        minHeight: 100, // 카드 높이를 최소 100px 이상으로 보장
      ),
      padding: const EdgeInsets.all(16), // 카드 내부 여백
      decoration: BoxDecoration(
        color: Colors.white, // 배경색 흰색
        borderRadius: BorderRadius.circular(16), // 테두리 둥글게
        border: Border.all(
          // 검은 테두리 추가
          color: Colors.black,
          width: 2,
        ),
        boxShadow: const [
          // 카드 그림자 효과 (아래 방향으로 살짝)
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4), // 아래로 약간 그림자
          ),
        ],
      ),
      // 텍스트만 수직으로 정렬
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          // 대피소 이름 (굵고 크기 크게)
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4), // 줄 간격
          // 대피소 주소
          Text(address, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          // 거리 정보 (작고 회색 글씨)
          Text(
            distance,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
