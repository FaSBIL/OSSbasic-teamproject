import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Flutter Map 패키지
import 'package:latlong2/latlong.dart'; // 위치 좌표(LatLng)를 위한 패키지

/// 현재 위치로 지도 이동하는 버튼 위젯 (이미지 스타일)
class CurrentLocationButton extends StatelessWidget {
  // 현재 위치 좌표 (nullable → null일 수도 있음)
  final LatLng? currentPosition;

  // flutter_map에서 사용하는 지도 제어용 컨트롤러
  final MapController mapController;

  // 생성자: 현재 위치와 지도 컨트롤러를 필수로 받음
  const CurrentLocationButton({
    super.key,
    required this.currentPosition,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 버튼을 감싸는 컨테이너 → 스타일 지정
      decoration: BoxDecoration(
        color: Colors.white, // 배경색: 흰색
        shape: BoxShape.circle, // 모양: 원형
        boxShadow: [
          // 그림자 효과 추가 (이미지처럼 부드럽게)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8), // 그림자 색: 연한 검정
            blurRadius: 8, // 그림자 퍼짐 정도
            offset: const Offset(0, 4), // 그림자 위치: 아래쪽으로 약간
          ),
        ],
      ),
      // 버튼 내용: 아이콘만 있는 원형 버튼
      child: IconButton(
        icon: const Icon(Icons.my_location), // 아이콘: 현재 위치
        onPressed: () {
          // 현재 위치가 null이 아니면 지도 중심을 현재 위치로 이동 (줌 레벨 15.0)
          if (currentPosition != null) {
            mapController.move(currentPosition!, 15.0);
          }
        },
      ),
    );
  }
}
