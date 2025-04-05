import 'package:flutter/material.dart'; // Flutter의 기본 UI 위젯들을 사용하기 위해 material 패키지를 가져옴

// ShelterCard: 대피소 정보를 보여주는 카드 UI 컴포넌트
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
      padding: const EdgeInsets.all(16), // 카드 내부 여백
      decoration: BoxDecoration(
        color: Colors.white, // 배경색 흰색
        borderRadius: BorderRadius.circular(16), // 테두리 둥글게
        boxShadow: const [
          // 카드에 그림자 효과
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          // 대피소 위치 아이콘
          const Icon(Icons.location_on, size: 40, color: Colors.red),
          const SizedBox(width: 16), // 아이콘과 텍스트 사이 간격
          // 텍스트 영역 (남은 공간 모두 차지함)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
              children: [
                // 대피소 이름 (굵고 크기 크게)
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // 대피소 주소
                Text(address),
                // 거리 정보 (작고 회색 글씨)
                Text(
                  distance,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
