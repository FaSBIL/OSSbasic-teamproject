import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// 📌 현재 위치로 지도 이동하는 버튼 위젯
class CurrentLocationButton extends StatelessWidget {
  final LatLng? currentPosition; // 현재 위치
  final MapController mapController; // 지도 제어 컨트롤러

  const CurrentLocationButton({
    super.key,
    required this.currentPosition,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: "goCurrent",
      onPressed: () {
        if (currentPosition != null) {
          mapController.move(currentPosition!, 15.0); // 현재 위치로 지도 이동
        }
      },
      backgroundColor: Colors.white,
      child: const Icon(Icons.my_location),
    );
  }
}
