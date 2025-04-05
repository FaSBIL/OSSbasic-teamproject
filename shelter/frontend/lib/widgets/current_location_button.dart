import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Flutter Map 패키지
import 'package:latlong2/latlong.dart'; // 위치 좌표(LatLng)를 위한 패키지

/// 📌 현재 위치로 지도 이동하는 버튼 위젯
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
    return FloatingActionButton.small(
      heroTag: "goCurrent", // 고유 태그 (FAB 중복 충돌 방지용)
      onPressed: () {
        if (currentPosition != null) {
          // 현재 위치가 null이 아니면 지도 중심을 현재 위치로 이동 (줌 레벨 15.0)
          mapController.move(currentPosition!, 15.0);
        }
      },
      backgroundColor: Colors.white, // 버튼 배경색 흰색
      child: const Icon(Icons.my_location), // 위치 아이콘
    );
  }
}
